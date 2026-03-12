/// Subject type tracking for the Jock compiler.
///
/// Ports the `++jt` door from jock.hoon (lines 1426-1653).
/// The compiler maintains a `Jype` that describes the structure of the current
/// Nock subject, enabling resolution of symbolic limb references to numeric
/// axis addresses.
use jock_parser::{CoreBody, Jlimb, JatomType, Jype, JypeLeaf, LambdaArgument};

use crate::error::CompileError;

// ── Axis arithmetic ─────────────────────────────────────────────

/// Nock axis composition: compute the absolute axis within axis `a` at
/// sub-position `b`.
///
/// `peg(a, 1) = a`, `peg(a, 2) = 2*a`, `peg(a, 3) = 2*a+1`, etc.
pub fn peg(a: u64, b: u64) -> u64 {
    if b == 0 {
        panic!("peg: b must be nonzero");
    }
    if b == 1 {
        return a;
    }
    // Find the highest set bit position in b (0-indexed).
    let bit_len = 63 - b.leading_zeros() as u64;
    // Strip the highest bit to get the "path" bits.
    let mask = b & !(1u64 << bit_len);
    (a << bit_len) | mask
}

// ── Helper constructors ─────────────────────────────────────────

/// The untyped/unknown type placeholder. Mirrors Hoon `++untyped-j`.
pub fn untyped_j() -> Jype {
    Jype::Leaf {
        leaf: Box::new(JypeLeaf::None { name: None }),
        name: String::new(),
    }
}

/// Construct a core type from a lambda argument and optional context.
/// Mirrors Hoon `++lam-j`.
pub fn lam_j(arg: LambdaArgument, context: Option<Jype>) -> Jype {
    Jype::Leaf {
        leaf: Box::new(JypeLeaf::Core {
            body: CoreBody::lambda(arg),
            context: context.map(Box::new),
        }),
        name: String::new(),
    }
}

/// Check if a name is a type name (starts with uppercase).
/// Mirrors Hoon `++is-type`.
pub fn is_type(name: &str) -> bool {
    name.chars()
        .next()
        .is_some_and(|c| c.is_ascii_uppercase())
}

/// Push a type onto the head of a subject type, creating [new, old].
pub fn cons_type(head: &Jype, tail: &Jype) -> Jype {
    Jype::Cell {
        p: Box::new(head.clone()),
        q: Box::new(tail.clone()),
        name: String::new(),
    }
}

/// The default initial subject type: `[%atom %string %.n]^%$`.
pub fn default_subject_type() -> Jype {
    Jype::Leaf {
        leaf: Box::new(JypeLeaf::Atom {
            typ: JatomType::String,
            constant: false,
        }),
        name: String::new(),
    }
}

// ── Wing resolution ─────────────────────────────────────────────

/// A resolved wing reference: either a simple axis (leg) or a core arm+axis pair.
/// Mirrors Hoon `+$jwing` (jock.hoon lines 1420-1424).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Jwing {
    /// Leg: direct axis reference (will become Nock 0).
    Leg(u64),
    /// Arm: fire arm at `arm_axis` within core at `core_axis` (will become Nock 9).
    Arm { arm_axis: u64, core_axis: u64 },
}

/// Result of resolving a limb path.
#[derive(Debug, Clone)]
pub enum LimbResult {
    /// Direct resolution to a type and wing path.
    Direct { typ: Jype, wings: Vec<Jwing> },
    /// Resolution reached a Hoon library boundary — remaining limbs need Hoon resolution.
    Hoon {
        typ: Jype,
        remaining: Vec<Jlimb>,
        wings: Vec<Jwing>,
    },
}

// ── Subject type operations ─────────────────────────────────────

/// Resolve a list of `Jlimb` references against a subject type to find the
/// corresponding axis (or arm+core pair).
///
/// Port of `++get-limb` (jock.hoon lines 1431-1508).
pub fn get_limb(jyp: &Jype, limbs: &[Jlimb]) -> Result<LimbResult, CompileError> {
    if limbs.is_empty() {
        return Err(CompileError::LimbNotFound("no limb requested".into()));
    }

    let mut current_type = jyp.clone();
    let mut res: Vec<Jwing> = Vec::new();
    let mut ret: Jwing = Jwing::Leg(1); // default: self (axis 1)

    let mut idx = 0;
    while idx < limbs.len() {
        let limb = &limbs[idx];

        // Resolve the current limb to an axis within current_type.
        let axi: Option<Jwing> = match limb {
            Jlimb::Name(_) | Jlimb::Type(_) => {
                let name = match limb {
                    Jlimb::Name(n) => n.as_str(),
                    Jlimb::Type(t) => t.as_str(),
                    _ => unreachable!(),
                };
                axis_at_name(&current_type, name)
            }
            Jlimb::Axis(a) => Some(Jwing::Leg(*a)),
        };

        let axi = match axi {
            Some(a) => a,
            None => {
                return Err(CompileError::LimbNotFound(format!(
                    "limb {:?} not found in type {:?}",
                    limb, current_type
                )));
            }
        };

        // Navigate into the type at the resolved axis.
        let effective_axis = match &axi {
            Jwing::Leg(a) => *a,
            Jwing::Arm { arm_axis, core_axis } => peg(*core_axis, *arm_axis),
        };

        let new_type = type_at_axis(&current_type, effective_axis);

        match new_type {
            Some(ref nt) => {
                // Check for class instance method access pattern:
                // Looking for a name limb that resolves to a Limb type with a Type reference,
                // and there are more limbs to resolve.
                if matches!(limb, Jlimb::Name(_)) && idx + 1 < limbs.len() {
                    if let Jype::Leaf { leaf, .. } = nt {
                        if let JypeLeaf::Limb(inner) = leaf.as_ref() {
                            if !inner.is_empty() && matches!(inner[0], Jlimb::Type(_)) {
                                // This is an instance reference — return so caller
                                // can handle method dispatch.
                                let new_ret = match &axi {
                                    Jwing::Leg(a) => match &ret {
                                        Jwing::Leg(r) => Jwing::Leg(peg(*r, *a)),
                                        arm => arm.clone(),
                                    },
                                    _ => axi.clone(),
                                };

                                let wings = if ret == Jwing::Leg(1) && res.is_empty() {
                                    vec![new_ret]
                                } else if res.is_empty() {
                                    vec![new_ret]
                                } else {
                                    vec![res[0].clone()]
                                };

                                return Ok(LimbResult::Direct {
                                    typ: nt.clone(),
                                    wings,
                                });
                            }
                        }
                    }
                }
            }
            None => {
                return Err(CompileError::LimbNotFound(format!(
                    "no type at axis {effective_axis} in {:?}",
                    current_type
                )));
            }
        }

        // Advance: either navigate into a core or continue axis descent.
        match &axi {
            Jwing::Arm { .. } => {
                // For arm references, push onto resolution list.
                if let Some(nt) = new_type {
                    current_type = call_core_from_type(&nt);
                    res.push(axi);
                }
            }
            Jwing::Leg(a) => {
                // Update the accumulated axis.
                if let Jwing::Leg(r) = &mut ret {
                    if *r == 1 && res.is_empty() {
                        *r = *a;
                    } else if res.is_empty() {
                        *r = peg(*r, *a);
                    }
                }
                if let Some(nt) = new_type {
                    current_type = nt;
                }
            }
        }

        idx += 1;
    }

    // Build the final wing list.
    let wings = if ret == Jwing::Leg(1) {
        if res.is_empty() {
            vec![Jwing::Leg(1)]
        } else {
            let mut w = res;
            w.reverse();
            w
        }
    } else if res.is_empty() {
        vec![ret]
    } else {
        vec![res[0].clone()]
    };

    Ok(LimbResult::Direct {
        typ: current_type,
        wings,
    })
}

/// Find the type at a given axis within a Jype tree.
///
/// Port of `++type-at-axis` (jock.hoon lines 1511-1529).
pub fn type_at_axis(jyp: &Jype, axis: u64) -> Option<Jype> {
    if axis == 0 {
        return None;
    }
    if axis == 1 {
        return Some(jyp.clone());
    }

    // Decompose axis into a path of left/right decisions.
    let path = axis_to_path(axis);

    let mut current = jyp.clone();
    for (i, dir) in path.iter().enumerate() {
        match &current {
            Jype::Cell { p, q, .. } => {
                if *dir == 0 {
                    current = *p.clone();
                } else {
                    current = *q.clone();
                }
            }
            Jype::Leaf { leaf, .. } => {
                match leaf.as_ref() {
                    JypeLeaf::Core { .. } => {
                        let called = call_core_from_type(&current);
                        let remaining_axis = path_to_axis(&path[i..]);
                        return type_at_axis(&called, remaining_axis);
                    }
                    JypeLeaf::State { p } => {
                        current = *p.clone();
                        // Continue descent — re-check current direction.
                        match &current {
                            Jype::Cell { p: cp, q: cq, .. } => {
                                if *dir == 0 {
                                    current = *cp.clone();
                                } else {
                                    current = *cq.clone();
                                }
                            }
                            _ => return None,
                        }
                    }
                    _ => return None,
                }
            }
        }
    }

    Some(current.with_name(String::new()))
}

/// Search a type tree for a named field, returning its wing (axis or arm reference).
///
/// Port of `++axis-at-name` (jock.hoon lines 1532-1567).
pub fn axis_at_name(jyp: &Jype, name: &str) -> Option<Jwing> {
    axis_at_name_inner(jyp, name, Jwing::Arm { arm_axis: 0, core_axis: 1 })
}

fn axis_at_name_inner(jyp: &Jype, name: &str, axi: Jwing) -> Option<Jwing> {
    // If the current type's name matches, return the axis.
    if jyp_name(jyp) == name {
        return match &axi {
            Jwing::Arm { arm_axis: 0, core_axis } => Some(Jwing::Leg(*core_axis)),
            _ => Some(axi),
        };
    }

    match jyp {
        Jype::Leaf { leaf, .. } => {
            match leaf.as_ref() {
                JypeLeaf::Core { body, context } => {
                    match body {
                        CoreBody::Lambda(_) => {
                            let called = call_core_from_leaf(leaf, context);
                            axis_at_name_inner(&called, name, axi)
                        }
                        CoreBody::Arms(arms) => {
                            let is_leg = matches!(axi, Jwing::Arm { arm_axis: 0, .. });
                            if !is_leg {
                                return None;
                            }
                            let core_axis = match &axi {
                                Jwing::Arm { core_axis, .. } => *core_axis,
                                Jwing::Leg(a) => *a,
                            };

                            // Search arms for the name.
                            let mut arm_axis = 2u64;
                            for (arm_name, _arm_type) in arms {
                                if arm_name == name {
                                    return Some(Jwing::Arm { arm_axis, core_axis });
                                }
                                arm_axis = arm_axis * 2 + 1;
                            }

                            // Search in context.
                            if let Some(ctx) = context {
                                return axis_at_name_inner(
                                    ctx,
                                    name,
                                    Jwing::Arm { arm_axis: 0, core_axis: core_axis * 2 + 1 },
                                );
                            }
                            None
                        }
                    }
                }
                _ => None,
            }
        }
        Jype::Cell { p, q, name: cell_name, .. } => {
            if !cell_name.is_empty() {
                return None;
            }

            // Unnamed cell: search both branches.
            let left_axis = match &axi {
                Jwing::Arm { arm_axis: 0, core_axis } => {
                    Jwing::Arm { arm_axis: 0, core_axis: core_axis * 2 }
                }
                Jwing::Arm { arm_axis, core_axis } => {
                    Jwing::Arm { arm_axis: arm_axis * 2, core_axis: *core_axis }
                }
                Jwing::Leg(a) => Jwing::Leg(a * 2),
            };
            let right_axis = match &axi {
                Jwing::Arm { arm_axis: 0, core_axis } => {
                    Jwing::Arm { arm_axis: 0, core_axis: core_axis * 2 + 1 }
                }
                Jwing::Arm { arm_axis, core_axis } => {
                    Jwing::Arm { arm_axis: arm_axis * 2 + 1, core_axis: *core_axis }
                }
                Jwing::Leg(a) => Jwing::Leg(a * 2 + 1),
            };

            let left = axis_at_name_inner(p, name, left_axis);
            if left.is_some() {
                return left;
            }
            axis_at_name_inner(q, name, right_axis)
        }
    }
}

/// Find the `$` (buc/self) reference for recursion.
///
/// Port of `++find-buc` (jock.hoon lines 1570-1586).
pub fn find_buc(jyp: &Jype) -> Option<(Jype, u64)> {
    find_buc_inner(jyp, 1)
}

fn find_buc_inner(jyp: &Jype, axis: u64) -> Option<(Jype, u64)> {
    match jyp {
        Jype::Leaf { leaf, .. } => {
            match leaf.as_ref() {
                JypeLeaf::Core { body: CoreBody::Lambda(_), .. } => {
                    Some((jyp.clone(), axis))
                }
                _ => None,
            }
        }
        Jype::Cell { p, q, .. } => {
            let left = find_buc_inner(p, axis * 2);
            if left.is_some() {
                return left;
            }
            find_buc_inner(q, axis * 2 + 1)
        }
    }
}

/// Construct the subject type when a core is called.
///
/// Port of `++call-core` (jock.hoon lines 1589-1618).
pub fn call_core_from_type(jyp: &Jype) -> Jype {
    match jyp {
        Jype::Leaf { leaf, .. } => call_core_from_leaf(leaf, &leaf_context(leaf)),
        _ => jyp.clone(),
    }
}

fn leaf_context(leaf: &JypeLeaf) -> Option<Box<Jype>> {
    match leaf {
        JypeLeaf::Core { context, .. } => context.clone(),
        _ => None,
    }
}

pub fn call_core_from_leaf(leaf: &JypeLeaf, context: &Option<Box<Jype>>) -> Jype {
    match leaf {
        JypeLeaf::Core { body, .. } => {
            match body {
                CoreBody::Lambda(arg) => {
                    let out_type = (*arg.out).clone();
                    match (&arg.inp, context) {
                        (None, None) => {
                            Jype::Cell {
                                p: Box::new(out_type),
                                q: Box::new(untyped_j()),
                                name: String::new(),
                            }
                        }
                        (None, Some(ctx)) => {
                            Jype::Cell {
                                p: Box::new(out_type),
                                q: ctx.clone(),
                                name: String::new(),
                            }
                        }
                        (Some(inp), None) => {
                            Jype::Cell {
                                p: Box::new(out_type),
                                q: inp.clone(),
                                name: String::new(),
                            }
                        }
                        (Some(inp), Some(ctx)) => {
                            Jype::Cell {
                                p: Box::new(out_type),
                                q: Box::new(Jype::Cell {
                                    p: inp.clone(),
                                    q: ctx.clone(),
                                    name: String::new(),
                                }),
                                name: String::new(),
                            }
                        }
                    }
                }
                CoreBody::Arms(arms) => {
                    if arms.is_empty() {
                        return match context {
                            Some(ctx) => *ctx.clone(),
                            None => untyped_j(),
                        };
                    }
                    let mut iter = arms.iter();
                    let (first_name, first_type) = iter.next().unwrap();
                    let mut ret = first_type.clone().with_name(first_name.clone());

                    for (arm_name, arm_type) in iter {
                        let t = arm_type.clone().with_name(arm_name.clone());
                        ret = Jype::Cell {
                            p: Box::new(t),
                            q: Box::new(ret),
                            name: String::new(),
                        };
                    }

                    match context {
                        Some(ctx) => Jype::Cell {
                            p: Box::new(ret),
                            q: ctx.clone(),
                            name: String::new(),
                        },
                        None => ret,
                    }
                }
            }
        }
        _ => untyped_j(),
    }
}

/// Check type compatibility and return unified type.
///
/// Port of `++unify` (jock.hoon lines 1625-1651).
pub fn unify(target: &Jype, source: &Jype) -> Option<Jype> {
    match (target, source) {
        (
            Jype::Cell { p: tp, q: tq, name: tn, .. },
            Jype::Cell { p: sp, q: sq, .. },
        ) => {
            let p = unify(tp, sp)?;
            let q = unify(tq, sq)?;
            Some(Jype::Cell {
                p: Box::new(p),
                q: Box::new(q),
                name: tn.clone(),
            })
        }
        (Jype::Cell { .. }, Jype::Leaf { leaf, .. }) => {
            if matches!(leaf.as_ref(), JypeLeaf::None { .. }) {
                Some(target.clone())
            } else {
                None
            }
        }
        (Jype::Leaf { leaf, name, .. }, Jype::Cell { .. }) => {
            if matches!(leaf.as_ref(), JypeLeaf::None { .. }) {
                Some(source.clone().with_name(name.clone()))
            } else {
                None
            }
        }
        (
            Jype::Leaf { leaf: tl, name: tn, .. },
            Jype::Leaf { leaf: sl, .. },
        ) => {
            if matches!(tl.as_ref(), JypeLeaf::None { .. }) {
                return Some(source.clone().with_name(tn.clone()));
            }
            if matches!(sl.as_ref(), JypeLeaf::None { .. }) {
                return Some(target.clone());
            }
            if std::mem::discriminant(tl.as_ref()) == std::mem::discriminant(sl.as_ref()) {
                Some(target.clone())
            } else {
                None
            }
        }
    }
}

// ── Internal helpers ────────────────────────────────────────────

/// Get the name from a Jype.
pub fn jyp_name(jyp: &Jype) -> &str {
    jyp.name()
}

/// Decompose an axis into a path of 0 (head) and 1 (tail) directions.
fn axis_to_path(axis: u64) -> Vec<u64> {
    if axis <= 1 {
        return vec![];
    }
    let mut path = Vec::new();
    let mut a = axis;
    while a > 1 {
        path.push(a & 1);
        a >>= 1;
    }
    path.reverse();
    path
}

/// Reconstruct an axis from a path.
fn path_to_axis(path: &[u64]) -> u64 {
    let mut axis = 1u64;
    for &dir in path {
        axis = axis * 2 + dir;
    }
    axis
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_peg() {
        assert_eq!(peg(1, 1), 1);
        assert_eq!(peg(2, 1), 2);
        assert_eq!(peg(1, 2), 2);
        assert_eq!(peg(1, 3), 3);
        assert_eq!(peg(2, 2), 4);
        assert_eq!(peg(2, 3), 5);
        assert_eq!(peg(3, 2), 6);
        assert_eq!(peg(3, 3), 7);
        assert_eq!(peg(2, 4), 8);
        assert_eq!(peg(2, 5), 9);
    }

    #[test]
    fn test_axis_to_path() {
        assert_eq!(axis_to_path(1), vec![]);
        assert_eq!(axis_to_path(2), vec![0]);
        assert_eq!(axis_to_path(3), vec![1]);
        assert_eq!(axis_to_path(4), vec![0, 0]);
        assert_eq!(axis_to_path(5), vec![0, 1]);
        assert_eq!(axis_to_path(6), vec![1, 0]);
        assert_eq!(axis_to_path(7), vec![1, 1]);
    }

    #[test]
    fn test_is_type() {
        assert!(is_type("Point"));
        assert!(is_type("Foo"));
        assert!(!is_type("foo"));
        assert!(!is_type("point"));
        assert!(!is_type(""));
    }
}
