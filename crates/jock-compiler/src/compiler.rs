/// Main Jock-to-Nock compilation logic.
///
/// Ports the `++cj` door and `++mint` arm from jock.hoon (lines 1655-2444).
/// The compiler is a recursive tree-walker that maintains a subject type (`Jype`)
/// and produces Nock instructions for each AST node.
use jock_parser::{
    AfterIf, Comparator, CoreBody, Jlimb, Jock, JatomType, Jype, JypeLeaf, Lambda,
    LambdaArgument, Operator,
};
use jock_tokenizer::{AtomVariant, Jatom};

use crate::error::CompileError;
use crate::nock::{HintTag, Nock, Noun};
use crate::subject::{
    self, Jwing, LimbResult, cons_type, find_buc,
    get_limb, is_type, lam_j, peg, unify, untyped_j,
};

/// Compile a Jock AST node to Nock, given the current subject type.
///
/// Returns `(nock_formula, result_type)`.
pub fn mint(j: &Jock, jyp: &Jype) -> Result<(Nock, Jype), CompileError> {
    match j {
        // ── Cell (pair) ──────────────────────────────────────────
        Jock::Cell { p, q } => {
            let (p_nock, p_jyp) = mint(p, jyp)?;
            let (q_nock, q_jyp) = mint(q, jyp)?;
            Ok((
                Nock::autocons(p_nock, q_nock),
                cons_type(&p_jyp, &q_jyp),
            ))
        }

        // ── Let binding ──────────────────────────────────────────
        Jock::Let { typ, val, next } => {
            let (val_nock, val_jyp) = mint(val, jyp)?;

            // Infer the bound type via unification.
            let inferred = infer_let_type(typ, &val_jyp, jyp)?;
            let new_subject = cons_type(&inferred, jyp);

            let (next_nock, next_jyp) = mint(next, &new_subject)?;
            Ok((Nock::push(val_nock, next_nock), next_jyp))
        }

        // ── Function definition ──────────────────────────────────
        Jock::Func { typ, body, next } => {
            let (body_nock, body_jyp) = mint(body, jyp)?;

            let inferred = unify(typ, &body_jyp).unwrap_or(body_jyp);
            let new_subject = cons_type(&inferred, jyp);

            let (next_nock, next_jyp) = mint(next, &new_subject)?;
            Ok((Nock::push(body_nock, next_nock), next_jyp))
        }

        // ── Method (within a class) ──────────────────────────────
        Jock::Method { typ, body } => {
            let (body_nock, body_jyp) = mint(body, jyp)?;
            let _inferred = unify(typ, &body_jyp);
            Ok((body_nock, body_jyp))
        }

        // ── Class definition ─────────────────────────────────────
        Jock::Class { state, arms } => {
            mint_class(state, arms, jyp)
        }

        // ── Edit (state mutation) ────────────────────────────────
        Jock::Edit { limb, val, next } => {
            // Resolve the limb to get the axis.
            let (_, axis) = resolve_limb_to_axis(limb, jyp)?;

            let (val_nock, _val_jyp) = mint(val, jyp)?;
            let (next_nock, next_jyp) = mint(next, jyp)?;

            Ok((
                Nock::then(
                    Nock::edit(axis, val_nock, Nock::Axis(1)),
                    next_nock,
                ),
                next_jyp,
            ))
        }

        // ── Increment ────────────────────────────────────────────
        Jock::Increment { val } => {
            let (val_nock, _) = mint(val, jyp)?;
            Ok((Nock::Increment(Box::new(val_nock)), atom_type(JatomType::Number)))
        }

        // ── Cell check ───────────────────────────────────────────
        Jock::CellCheck { val } => {
            let (val_nock, _) = mint(val, jyp)?;
            Ok((Nock::CellTest(Box::new(val_nock)), atom_type(JatomType::Loobean)))
        }

        // ── Compose ──────────────────────────────────────────────
        Jock::Compose { p, q } => {
            let (p_nock, p_jyp) = mint(p, jyp)?;
            let (q_nock, q_jyp) = mint(q, &p_jyp)?;
            Ok((Nock::then(p_nock, q_nock), q_jyp))
        }

        // ── Object ───────────────────────────────────────────────
        Jock::Object { name: _, p: arms, q } => {
            mint_object(arms, q, jyp)
        }

        // ── Eval ─────────────────────────────────────────────────
        Jock::Eval { p, q } => {
            let (p_nock, _) = mint(p, jyp)?;
            let (q_nock, _) = mint(q, jyp)?;
            Ok((Nock::Compose(Box::new(p_nock), Box::new(q_nock)), untyped_j()))
        }

        // ── Loop ─────────────────────────────────────────────────
        Jock::Loop { next } => {
            let loop_jyp = lam_j(
                LambdaArgument::new(None, untyped_j()),
                Some(jyp.clone()),
            );
            let (next_nock, _) = mint(next, &loop_jyp)?;
            // [8 [1 body] [9 2 [0 1]]]
            Ok((
                Nock::push(
                    Nock::Constant(nock_to_noun(&next_nock)),
                    Nock::fire(2, Nock::Axis(1)),
                ),
                jyp.clone(),
            ))
        }

        // ── Defer ────────────────────────────────────────────────
        Jock::Defer { next } => {
            let defer_jyp = lam_j(
                LambdaArgument::new(None, untyped_j()),
                Some(jyp.clone()),
            );
            let (next_nock, _) = mint(next, &defer_jyp)?;
            // [[1 body] [0 1]]
            Ok((
                Nock::autocons(
                    Nock::Constant(nock_to_noun(&next_nock)),
                    Nock::Axis(1),
                ),
                jyp.clone(),
            ))
        }

        // ── If-then-else ─────────────────────────────────────────
        Jock::If { cond, then, after } => {
            let (cond_nock, _) = mint(cond, jyp)?;
            let (then_nock, then_jyp) = mint(then, jyp)?;
            let (after_nock, after_jyp) = mint_after_if(after, jyp)?;
            Ok((
                Nock::if_then_else(cond_nock, then_nock, after_nock),
                fork_type(&then_jyp, &after_jyp),
            ))
        }

        // ── Assert ───────────────────────────────────────────────
        Jock::Assert { cond, then } => {
            let (cond_nock, _) = mint(cond, jyp)?;
            let (then_nock, then_jyp) = mint(then, jyp)?;
            Ok((
                Nock::if_then_else(cond_nock, then_nock, Nock::Axis(0)),
                then_jyp,
            ))
        }

        // ── Match (type-based pattern matching) ──────────────────
        Jock::Match { value, cases, default } => {
            mint_match(value, cases, default, jyp, true)
        }

        // ── Switch (value-based pattern matching) ────────────────
        Jock::Switch { value, cases, default } => {
            mint_match(value, cases, default, jyp, false)
        }

        // ── Call ─────────────────────────────────────────────────
        Jock::Call { func, arg } => {
            mint_call(func, arg, jyp)
        }

        // ── Compare ──────────────────────────────────────────────
        Jock::Compare { comp, a, b } => {
            mint_compare(*comp, a, b, jyp)
        }

        // ── Operator ─────────────────────────────────────────────
        Jock::Operator { op, a, b } => {
            mint_operator(*op, a, b, jyp)
        }

        // ── Lambda ───────────────────────────────────────────────
        Jock::Lambda(lambda) => {
            mint_lambda(lambda, jyp)
        }

        // ── Limb (variable reference) ────────────────────────────
        Jock::Limb(limbs) => {
            let result = get_limb(jyp, limbs)?;
            match result {
                LimbResult::Direct { typ, wings } => {
                    Ok((resolve_wing(&wings), typ))
                }
                LimbResult::Hoon { .. } => {
                    // Hoon library limb — requires Hoon subject.
                    Err(CompileError::RequiresHoonLibrary {
                        feature: format!("limb resolution into Hoon library: {:?}", limbs),
                    })
                }
            }
        }

        // ── Atom literal ─────────────────────────────────────────
        Jock::Atom(jatom) => {
            let (noun, typ) = atom_to_noun(jatom);
            Ok((Nock::Constant(noun), typ))
        }

        // ── List literal ─────────────────────────────────────────
        Jock::List { typ, val } => {
            mint_list(typ, val, jyp)
        }

        // ── Set literal ──────────────────────────────────────────
        Jock::Set { typ, val } => {
            mint_set(typ, val, jyp)
        }

        // ── Import ───────────────────────────────────────────────
        Jock::Import { name, next } => {
            // Import pushes a library subject onto the subject.
            // For now, we support the pattern but the actual Hoon subject
            // must be provided externally.
            let new_subject = cons_type(name, jyp);
            let (next_nock, next_jyp) = mint(next, &new_subject)?;
            // The actual library noun would need to be provided at runtime.
            // We emit the structural pattern: [8 [1 library-noun] next]
            // For now, emit a placeholder constant 0.
            Ok((
                Nock::push(Nock::Constant(Noun::Atom(0)), next_nock),
                next_jyp,
            ))
        }

        // ── Print ────────────────────────────────────────────────
        Jock::Print { body, next } => {
            let (val_nock, _val_jyp) = mint(body, jyp)?;
            let (next_nock, next_jyp) = mint(next, jyp)?;
            // [11 [%slog [1 0] [1 <pretty-printed>]] next]
            // For slog: tag is 'slog' as a Nock atom.
            let slog_tag = cord_to_u64("slog");
            let hint_formula = Nock::autocons(
                Nock::Constant(Noun::Atom(0)),
                Nock::Constant(nock_to_noun(&val_nock)),
            );
            Ok((
                Nock::Hint(
                    HintTag::Dynamic(slog_tag, Box::new(hint_formula)),
                    Box::new(next_nock),
                ),
                next_jyp,
            ))
        }

        // ── Crash ────────────────────────────────────────────────
        Jock::Crash => {
            Ok((Nock::Axis(0), jyp.clone()))
        }
    }
}

// ── After-if compilation ────────────────────────────────────────

fn mint_after_if(after: &AfterIf, jyp: &Jype) -> Result<(Nock, Jype), CompileError> {
    match after {
        AfterIf::Else { then } => mint(then, jyp),
        AfterIf::ElseIf { cond, then, after } => {
            let (cond_nock, _) = mint(cond, jyp)?;
            let (then_nock, then_jyp) = mint(then, jyp)?;
            let (after_nock, after_jyp) = mint_after_if(after, jyp)?;
            Ok((
                Nock::if_then_else(cond_nock, then_nock, after_nock),
                fork_type(&then_jyp, &after_jyp),
            ))
        }
    }
}

// ── Compare compilation ─────────────────────────────────────────

fn mint_compare(
    comp: Comparator,
    a: &Jock,
    b: &Jock,
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    let loobean = atom_type(JatomType::Loobean);

    match comp {
        Comparator::Eq => {
            let (a_nock, _) = mint(a, jyp)?;
            let (b_nock, _) = mint(b, jyp)?;
            Ok((Nock::Equals(Box::new(a_nock), Box::new(b_nock)), loobean))
        }
        Comparator::Ne => {
            let (a_nock, _) = mint(a, jyp)?;
            let (b_nock, _) = mint(b, jyp)?;
            // [6 [5 a b] [1 1] [1 0]]
            Ok((
                Nock::if_then_else(
                    Nock::Equals(Box::new(a_nock), Box::new(b_nock)),
                    Nock::Constant(Noun::Atom(1)), // not equal → false (1)
                    Nock::Constant(Noun::Atom(0)), // equal → true (0)
                ),
                loobean,
            ))
        }
        // Other comparisons desugar to Hoon library calls.
        Comparator::Lt => mint_hoon_call("lth", a, b, jyp),
        Comparator::Gt => mint_hoon_call("gth", a, b, jyp),
        Comparator::Le => mint_hoon_call("lte", a, b, jyp),
        Comparator::Ge => mint_hoon_call("gte", a, b, jyp),
    }
}

// ── Operator compilation ────────────────────────────────────────

fn mint_operator(
    op: Operator,
    a: &Jock,
    b: &Option<Box<Jock>>,
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    let b = b.as_ref().ok_or_else(|| CompileError::MissingOperand {
        op: format!("{:?}", op),
    })?;

    let hoon_name = match op {
        Operator::Add => "add",
        Operator::Sub => "sub",
        Operator::Mul => "mul",
        Operator::Div => "div",
        Operator::Mod => "mod",
        Operator::Pow => "pow",
    };

    mint_hoon_call(hoon_name, a, b, jyp)
}

/// Compile a binary call into the Hoon standard library.
///
/// This desugars `a op b` into `Call(hoon.func, (a, b))`, which in Nock
/// becomes a gate call into the Hoon library subject.
fn mint_hoon_call(
    func_name: &str,
    a: &Jock,
    b: &Jock,
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    // Desugar into: [%call [%limb [%name 'hoon'] [%name func_name]] (a b)]
    let call_jock = Jock::Call {
        func: Box::new(Jock::Limb(vec![
            Jlimb::Name("hoon".into()),
            Jlimb::Name(func_name.into()),
        ])),
        arg: Some(Box::new(Jock::Cell {
            p: Box::new(a.clone()),
            q: Box::new(b.clone()),
        })),
    };
    mint(&call_jock, jyp)
}

// ── Call compilation ────────────────────────────────────────────

fn mint_call(
    func: &Jock,
    arg: &Option<Box<Jock>>,
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    match func {
        Jock::Limb(limbs) => mint_call_limb(limbs, arg, jyp),
        Jock::Lambda(lambda) => {
            // Direct lambda call: compile the lambda, then call it.
            let (lam_nock, _lam_jyp) = mint_lambda(lambda, jyp)?;
            let out_type = (*lambda.arg.out).clone();

            match arg {
                None => {
                    // [7 lam [9 2 [0 1]]]
                    Ok((
                        Nock::then(lam_nock, Nock::fire(2, Nock::Axis(1))),
                        out_type,
                    ))
                }
                Some(arg_jock) => {
                    let (arg_nock, _) = mint(arg_jock, jyp)?;
                    // [7 lam [9 2 [10 [6 [7 [0 3] arg]] [0 1]]]]
                    Ok((
                        Nock::then(
                            lam_nock,
                            Nock::fire(
                                2,
                                Nock::edit(
                                    6,
                                    Nock::then(Nock::Axis(3), arg_nock),
                                    Nock::Axis(1),
                                ),
                            ),
                        ),
                        out_type,
                    ))
                }
            }
        }
        _ => Err(CompileError::InvalidCallTarget(format!(
            "expected limb or lambda, got {:?}",
            func
        ))),
    }
}

fn mint_call_limb(
    limbs: &[Jlimb],
    arg: &Option<Box<Jock>>,
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    if limbs.is_empty() {
        return Err(CompileError::InvalidCallTarget("empty limb path".into()));
    }

    // Check for $ (self-recursion).
    if limbs.len() >= 1 && limbs[0] == Jlimb::Axis(0) {
        return mint_self_call(arg, jyp);
    }

    // Resolve the limb.
    let result = get_limb(jyp, limbs)?;

    match result {
        LimbResult::Hoon { typ, remaining, wings } => {
            // Case 6: Hoon library call.
            mint_hoon_library_call(&wings, &remaining, &typ, arg, jyp)
        }
        LimbResult::Direct { typ, wings } => {
            // Determine what kind of call this is based on the resolved type.
            mint_call_direct(&typ, &wings, limbs, arg, jyp)
        }
    }
}

/// Self-call (recursion via `$`).
fn mint_self_call(
    arg: &Option<Box<Jock>>,
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    let (_, buc_axis) = find_buc(jyp).ok_or_else(|| {
        CompileError::Internal("$ (self) not found in current subject".into())
    })?;

    match arg {
        None => {
            // Just fire the arm.
            Ok((Nock::fire(2, Nock::Axis(buc_axis)), untyped_j()))
        }
        Some(arg_jock) => {
            let (arg_nock, _) = mint(arg_jock, jyp)?;
            // [9 2 [10 [6 [7 [0 1] arg]] [0 1]]]
            Ok((
                Nock::fire(
                    2,
                    Nock::edit(
                        6,
                        Nock::then(Nock::Axis(1), arg_nock),
                        Nock::Axis(1),
                    ),
                ),
                untyped_j(),
            ))
        }
    }
}

/// Direct call — determine sub-case based on resolved type.
fn mint_call_direct(
    typ: &Jype,
    wings: &[Jwing],
    limbs: &[Jlimb],
    arg: &Option<Box<Jock>>,
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    // Check if target is a cell type (class constructor or compound value).
    if let Jype::Cell { .. } = typ {
        return mint_call_class_constructor(typ, wings, limbs, arg, jyp);
    }

    // Check if target is a core (function or lambda).
    if let Jype::Leaf { leaf, .. } = typ {
        match leaf.as_ref() {
            JypeLeaf::Core { body, .. } => {
                match body {
                    CoreBody::Lambda(_arg_type) => {
                        // Case 1: function call or Case 4: lambda call.
                        return mint_call_function(typ, wings, arg, jyp);
                    }
                    CoreBody::Arms(_) => {
                        // Case 5: object method call from within.
                        return mint_call_function(typ, wings, arg, jyp);
                    }
                }
            }
            JypeLeaf::Limb(inner_limbs) => {
                // Instance reference — need to resolve further for method dispatch.
                if !inner_limbs.is_empty() && matches!(inner_limbs[0], Jlimb::Type(_)) {
                    return mint_call_instance_method(typ, inner_limbs, wings, limbs, arg, jyp);
                }
            }
            JypeLeaf::State { .. } => {
                // State access — check if it's a class constructor or state.
                if let Some(first_limb) = limbs.first() {
                    if matches!(first_limb, Jlimb::Type(_)) {
                        return mint_call_class_constructor(typ, wings, limbs, arg, jyp);
                    }
                }
            }
            _ => {}
        }
    }

    // Check by limb type for type constructor.
    if let Some(first_limb) = limbs.first() {
        if matches!(first_limb, Jlimb::Type(_)) {
            // Type(args) — class constructor.
            return mint_call_class_constructor(typ, wings, limbs, arg, jyp);
        }
    }

    // Default: try as a function call.
    mint_call_function(typ, wings, arg, jyp)
}

/// Function call (Case 1) or lambda call (Case 4).
fn mint_call_function(
    typ: &Jype,
    wings: &[Jwing],
    arg: &Option<Box<Jock>>,
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    // Determine return type.
    let out_type = get_return_type(typ);
    let wing_nock = resolve_wing(wings);

    match arg {
        None => {
            // No args — just resolve the wing.
            Ok((wing_nock, out_type))
        }
        Some(arg_jock) => {
            let (arg_nock, _) = mint(arg_jock, jyp)?;
            // [8 wing [9 2 [10 [6 [7 [0 3] arg]] [0 2]]]]
            Ok((
                Nock::push(
                    wing_nock,
                    Nock::fire(
                        2,
                        Nock::edit(
                            6,
                            Nock::then(Nock::Axis(3), arg_nock),
                            Nock::Axis(2),
                        ),
                    ),
                ),
                out_type,
            ))
        }
    }
}

/// Class constructor call (Case 2).
fn mint_call_class_constructor(
    typ: &Jype,
    wings: &[Jwing],
    _limbs: &[Jlimb],
    arg: &Option<Box<Jock>>,
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    let arg_jock = arg.as_ref().ok_or_else(|| {
        CompileError::InvalidCallTarget("class constructor requires arguments".into())
    })?;
    let (val_nock, _val_jyp) = mint(arg_jock, jyp)?;

    // Get the parent axis from the wing.
    let parent_axis = match wings.first() {
        Some(Jwing::Leg(a)) => *a / 2,
        Some(Jwing::Arm { core_axis, .. }) => *core_axis / 2,
        None => 1,
    };

    // [8 [0 parent] [10 [6 [7 [0 3] val]] [0 2]]]
    Ok((
        Nock::push(
            Nock::Axis(parent_axis),
            Nock::edit(
                6,
                Nock::then(Nock::Axis(3), val_nock),
                Nock::Axis(2),
            ),
        ),
        typ.clone(),
    ))
}

/// Instance method call (Case 3).
fn mint_call_instance_method(
    _instance_typ: &Jype,
    inner_limbs: &[Jlimb],
    instance_wings: &[Jwing],
    call_limbs: &[Jlimb],
    arg: &Option<Box<Jock>>,
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    // Resolve the class type to find the method.
    let class_result = get_limb(jyp, inner_limbs)?;
    let class_type = match &class_result {
        LimbResult::Direct { typ, .. } => typ.clone(),
        _ => {
            return Err(CompileError::Internal("expected direct class type".into()));
        }
    };

    // Find the method name in the call limbs (it's the second limb after the instance name).
    let method_name = if call_limbs.len() >= 2 {
        match &call_limbs[1] {
            Jlimb::Name(n) => n.clone(),
            _ => {
                return Err(CompileError::InvalidCallTarget(
                    "expected method name".into(),
                ));
            }
        }
    } else {
        return Err(CompileError::InvalidCallTarget(
            "instance method call requires method name".into(),
        ));
    };

    // Search class type for the method.
    let method_wing = subject::axis_at_name(&class_type, &method_name);
    let method_arm_axis = match method_wing {
        Some(Jwing::Arm { arm_axis, .. }) => arm_axis,
        Some(Jwing::Leg(a)) => a,
        None => {
            return Err(CompileError::LimbNotFound(format!(
                "method '{}' not found in class",
                method_name
            )));
        }
    };

    let instance_nock = resolve_wing(instance_wings);
    let out_type = untyped_j(); // TODO: resolve from method return type

    match arg {
        None => Ok((instance_nock, out_type)),
        Some(arg_jock) => {
            let (arg_nock, _) = mint(arg_jock, jyp)?;
            // [8 [7 instance [9 method_axis [0 1]]] [9 2 [10 [6 [7 [0 3] arg]] [0 2]]]]
            Ok((
                Nock::push(
                    Nock::then(
                        instance_nock,
                        Nock::fire(method_arm_axis, Nock::Axis(1)),
                    ),
                    Nock::fire(
                        2,
                        Nock::edit(
                            6,
                            Nock::then(Nock::Axis(3), arg_nock),
                            Nock::Axis(2),
                        ),
                    ),
                ),
                out_type,
            ))
        }
    }
}

/// Hoon library call (Case 6).
fn mint_hoon_library_call(
    wings: &[Jwing],
    _remaining: &[Jlimb],
    _typ: &Jype,
    arg: &Option<Box<Jock>>,
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    let wing_axis = match wings.first() {
        Some(Jwing::Leg(a)) => *a,
        _ => 1,
    };

    let arg_jock = arg.as_ref().ok_or_else(|| {
        CompileError::InvalidCallTarget("Hoon library call requires arguments".into())
    })?;
    let (arg_nock, _) = mint(arg_jock, jyp)?;

    // Emit the Hoon gate call pattern:
    // [8 [9 arm-axis [0 lib-axis]] [9 2 [10 [6 [7 [0 3] arg]] [0 2]]]]
    // Simplified: we use axis 2 for the gate within the library core.
    Ok((
        Nock::push(
            Nock::fire(2, Nock::Axis(wing_axis)),
            Nock::fire(
                2,
                Nock::edit(
                    6,
                    Nock::then(Nock::Axis(3), arg_nock),
                    Nock::Axis(2),
                ),
            ),
        ),
        untyped_j(),
    ))
}

// ── Class compilation ───────────────────────────────────────────

fn mint_class(
    state: &Jype,
    arms: &[(String, Jock)],
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    if arms.is_empty() {
        return Err(CompileError::Internal("class with no arms".into()));
    }

    // Build the default sample (state default).
    let sam_nock = type_to_default(state);

    // Build the execution context type for compiling arms.
    // The context includes the door state and the outer subject.
    let state_inner = match state {
        Jype::Leaf { leaf, .. } if matches!(leaf.as_ref(), JypeLeaf::State { .. }) => {
                    if let JypeLeaf::State { p } = leaf.as_ref() {
                        *p.clone()
                    } else {
                        unreachable!()
                    }
                }
        _ => state.clone(),
    };
    let context = cons_type(&state_inner, jyp);

    // Build untyped arm map for the execution context.
    let mut arm_types: Vec<(String, Jype)> = Vec::new();
    for (name, _) in arms {
        arm_types.push((name.clone(), untyped_j()));
    }
    let exe_jyp = Jype::Leaf {
        leaf: Box::new(JypeLeaf::Core {
            body: CoreBody::Arms(arm_types.clone()),
            context: Some(Box::new(context.clone())),
        }),
        name: String::new(),
    };

    // Compile each arm.
    let mut arm_nocks: Vec<Nock> = Vec::new();
    let mut arm_jypes: Vec<(String, Jype)> = Vec::new();

    for (name, body) in arms {
        let (arm_nock, arm_jyp) = mint(body, &exe_jyp)?;
        arm_nocks.push(arm_nock);
        arm_jypes.push((name.clone(), arm_jyp));
    }

    // Build the battery (arms autocons tree).
    let battery_nock = build_autocons_tree(&arm_nocks);

    // [8 sam-default [[1 battery] [0 1]]]
    let class_nock = Nock::push(
        sam_nock,
        Nock::autocons(
            Nock::Constant(nock_to_noun(&battery_nock)),
            Nock::Axis(1),
        ),
    );

    // Build the result type.
    let inner_jyp = Jype::Leaf {
        leaf: Box::new(JypeLeaf::Core {
            body: CoreBody::Arms(arm_jypes),
            context: Some(Box::new(state.clone())),
        }),
        name: state.name().to_string(),
    };
    let result_jyp = cons_type(&inner_jyp, jyp);

    Ok((class_nock, result_jyp))
}

// ── Object compilation ──────────────────────────────────────────

fn mint_object(
    arms: &[(String, Jock)],
    context: &Option<Box<Jock>>,
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    if arms.is_empty() {
        return Err(CompileError::Internal("object with no arms".into()));
    }

    // Compile optional context.
    let (con_nock, con_jyp) = match context {
        Some(ctx) => {
            let (n, t) = mint(ctx, jyp)?;
            (Some(n), Some(t))
        }
        None => (None, None),
    };

    // Build execution context type.
    let mut arm_types: Vec<(String, Jype)> = Vec::new();
    for (name, _) in arms {
        arm_types.push((name.clone(), untyped_j()));
    }
    let exe_jyp = Jype::Leaf {
        leaf: Box::new(JypeLeaf::Core {
            body: CoreBody::Arms(arm_types.clone()),
            context: con_jyp.as_ref().map(|t| Box::new(t.clone())),
        }),
        name: String::new(),
    };

    // Compile each arm.
    let mut arm_nocks: Vec<Nock> = Vec::new();
    let mut arm_jypes: Vec<(String, Jype)> = Vec::new();

    for (name, body) in arms {
        let (arm_nock, arm_jyp) = mint(body, &exe_jyp)?;
        arm_nocks.push(arm_nock);
        arm_jypes.push((name.clone(), arm_jyp));
    }

    let battery_nock = build_autocons_tree(&arm_nocks);

    let result_nock = match con_nock {
        Some(cn) => Nock::autocons(
            Nock::Constant(nock_to_noun(&battery_nock)),
            cn,
        ),
        None => Nock::Constant(nock_to_noun(&battery_nock)),
    };

    let result_jyp = Jype::Leaf {
        leaf: Box::new(JypeLeaf::Core {
            body: CoreBody::Arms(arm_jypes),
            context: con_jyp.map(Box::new),
        }),
        name: String::new(),
    };

    Ok((result_nock, result_jyp))
}

// ── Lambda compilation ──────────────────────────────────────────

fn mint_lambda(
    lambda: &Lambda,
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    // Compile optional context.
    let (con_nock, con_jyp) = match &lambda.context {
        Some(ctx) => {
            let (n, t) = mint(ctx, jyp)?;
            (Some(n), Some(t))
        }
        None => (None, None),
    };

    // Build input default.
    let input_default = match &lambda.arg.inp {
        Some(inp) => type_to_default(inp),
        None => Nock::Constant(Noun::Atom(0)),
    };

    // Build the lambda's subject type.
    let lam_jyp = lam_j(
        lambda.arg.clone(),
        con_jyp.as_ref().cloned().or_else(|| Some(jyp.clone())),
    );

    // Compile the body.
    let (body_nock, _body_jyp) = mint(&lambda.body, &lam_jyp)?;

    // Check if return type is a type name (instance return from method).
    if is_type(lambda.arg.out.name()) {
        // Instance return: wrap with door construction.
        // [8 input-default [[1 [8 [0 7] [10 [6 [7 [0 3] body]] [0 2]]]] context]]
        let inner = Nock::push(
            Nock::Axis(7),
            Nock::edit(
                6,
                Nock::then(Nock::Axis(3), body_nock),
                Nock::Axis(2),
            ),
        );
        let result = match con_nock {
            Some(cn) => Nock::push(
                input_default,
                Nock::autocons(
                    Nock::Constant(nock_to_noun(&inner)),
                    cn,
                ),
            ),
            None => Nock::push(
                input_default,
                Nock::autocons(
                    Nock::Constant(nock_to_noun(&inner)),
                    Nock::Axis(1),
                ),
            ),
        };
        let result_jyp = lam_j(
            lambda.arg.clone(),
            con_jyp.map(|t| t).or_else(|| Some(jyp.clone())),
        );
        return Ok((result, result_jyp));
    }

    // Normal return.
    let result = match con_nock {
        Some(cn) => {
            // [8 input-default [[1 body] context]]
            Nock::push(
                input_default,
                Nock::autocons(
                    Nock::Constant(nock_to_noun(&body_nock)),
                    cn,
                ),
            )
        }
        None => {
            // [8 input-default [[1 body] [0 1]]]
            Nock::push(
                input_default,
                Nock::autocons(
                    Nock::Constant(nock_to_noun(&body_nock)),
                    Nock::Axis(1),
                ),
            )
        }
    };

    let result_jyp = lam_j(
        lambda.arg.clone(),
        con_jyp.or_else(|| Some(jyp.clone())),
    );
    Ok((result, result_jyp))
}

// ── Match/Switch compilation ────────────────────────────────────

fn mint_match(
    value: &Jock,
    cases: &[(Jock, Jock)],
    default: &Option<Box<Jock>>,
    jyp: &Jype,
    is_type_match: bool,
) -> Result<(Nock, Jype), CompileError> {
    let (val_nock, _val_jyp) = mint(value, jyp)?;

    if cases.is_empty() {
        return Err(CompileError::Internal("match with no cases".into()));
    }

    // Build the default case.
    let default_nock = match default {
        Some(def) => {
            let (def_nock, _) = mint(def, jyp)?;
            Nock::then(Nock::Axis(3), Nock::Constant(nock_to_noun(&def_nock)))
        }
        None => Nock::Axis(0), // crash
    };

    // Build the case chain from bottom up.
    let mut chain = default_nock;
    for (pattern, body) in cases.iter().rev() {
        let (body_nock, _) = mint(body, jyp)?;

        let test_nock = if is_type_match {
            // hunt-type: test by type structure.
            let (pattern_nock, pattern_jyp) = mint(pattern, jyp)?;
            let _ = pattern_nock; // We use the type for matching, not the value.
            hunt_type(&pattern_jyp, 2)
        } else {
            // hunt-value: test by value equality.
            hunt_value(pattern, jyp, 2)?
        };

        chain = Nock::if_then_else(
            test_nock,
            Nock::then(Nock::Axis(3), Nock::Constant(nock_to_noun(&body_nock))),
            chain,
        );
    }

    // [8 [1 val] chain]
    Ok((
        Nock::push(Nock::Constant(nock_to_noun(&val_nock)), chain),
        jyp.clone(),
    ))
}

/// Generate Nock to test if the value at `axis` matches a type pattern.
///
/// Port of `++hunt-type` (jock.hoon lines 2561-2591).
fn hunt_type(jyp: &Jype, axis: u64) -> Nock {
    match jyp {
        Jype::Cell { p, q, .. } => {
            // Cell case: check if it's a cell, then check both halves.
            Nock::if_then_else(
                Nock::CellTest(Box::new(Nock::Axis(axis))),
                Nock::if_then_else(
                    hunt_type(p, axis * 2),
                    hunt_type(q, axis * 2 + 1),
                    Nock::Constant(Noun::Atom(1)),
                ),
                Nock::Constant(Noun::Atom(1)),
            )
        }
        Jype::Leaf { leaf, .. } => {
            match leaf.as_ref() {
                JypeLeaf::Atom { constant: true, .. } => {
                    // Constant atom: test equality.
                    // [5 [1 constant-value] [0 axis]]
                    // We don't have the actual constant value here — this is a type test.
                    // For constant atoms in match patterns, the value comes from the jype name.
                    Nock::Constant(Noun::Atom(0)) // true (matches)
                }
                JypeLeaf::None { .. } => {
                    // Wildcard: always matches.
                    Nock::Constant(Noun::Atom(0))
                }
                _ => {
                    // Default: always matches (non-constant atom, etc.).
                    Nock::Constant(Noun::Atom(0))
                }
            }
        }
    }
}

/// Generate Nock to test if the value at `axis` matches a value pattern.
///
/// Port of `++hunt-value` (jock.hoon lines 2595-2618).
fn hunt_value(pattern: &Jock, jyp: &Jype, axis: u64) -> Result<Nock, CompileError> {
    match pattern {
        Jock::Cell { p, q } => {
            // Cell case: check if it's a cell, then check both halves.
            let left = hunt_value(p, jyp, axis * 2)?;
            let right = hunt_value(q, jyp, axis * 2 + 1)?;
            Ok(Nock::if_then_else(
                Nock::CellTest(Box::new(Nock::Axis(axis))),
                Nock::if_then_else(left, right, Nock::Constant(Noun::Atom(1))),
                Nock::Constant(Noun::Atom(1)),
            ))
        }
        Jock::Atom(jatom) => {
            // Atom case: test equality with the literal value.
            let (noun, _) = atom_to_noun(jatom);
            let atom_val = match &noun {
                Noun::Atom(n) => Noun::Atom(*n),
                other => other.clone(),
            };
            Ok(Nock::Equals(
                Box::new(Nock::Constant(atom_val)),
                Box::new(Nock::Axis(axis)),
            ))
        }
        _ => {
            // For other patterns, compile and test equality.
            let (pat_nock, _) = mint(pattern, jyp)?;
            Ok(Nock::Equals(
                Box::new(Nock::Constant(nock_to_noun(&pat_nock))),
                Box::new(Nock::Axis(axis)),
            ))
        }
    }
}

// ── List compilation ────────────────────────────────────────────

fn mint_list(
    _typ: &JypeLeaf,
    vals: &[Jock],
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    if vals.is_empty() {
        return Err(CompileError::EmptyCollection {
            kind: "list".into(),
        });
    }

    // Compile each element.
    let mut nouns: Vec<Noun> = Vec::new();
    for val in vals {
        let (val_nock, _) = mint(val, jyp)?;
        nouns.push(nock_to_noun(&val_nock));
    }

    // Build null-terminated tuple: [a [b [c 0]]]
    let mut result = Noun::Atom(0); // null terminator
    for noun in nouns.into_iter().rev() {
        result = Noun::cell(noun, result);
    }

    let result_jyp = Jype::Leaf {
        leaf: Box::new(JypeLeaf::List {
            typ: Box::new(untyped_j()),
        }),
        name: String::new(),
    };

    Ok((Nock::Constant(result), result_jyp))
}

// ── Set compilation ─────────────────────────────────────────────

fn mint_set(
    _typ: &JypeLeaf,
    vals: &[Jock],
    jyp: &Jype,
) -> Result<(Nock, Jype), CompileError> {
    if vals.is_empty() {
        return Err(CompileError::EmptyCollection { kind: "set".into() });
    }

    // Compile each element and build a set as a sorted balanced tree.
    // For simplicity, we build a right-leaning tree like the Hoon compiler.
    let mut nouns: Vec<Noun> = Vec::new();
    for val in vals {
        let (val_nock, _) = mint(val, jyp)?;
        nouns.push(nock_to_noun(&val_nock));
    }

    // Build a simple Hoon-style set representation.
    // A Hoon set is a treap (tree + heap), but for constants we can
    // just build a balanced tree. Simplest approach: null-terminated tree.
    let set_noun = build_set_tree(&nouns);

    let result_jyp = Jype::Leaf {
        leaf: Box::new(JypeLeaf::Set {
            typ: Box::new(untyped_j()),
        }),
        name: String::new(),
    };

    Ok((Nock::Constant(set_noun), result_jyp))
}

// ── Helper functions ────────────────────────────────────────────

/// Convert a Jatom to a Noun and its type.
fn atom_to_noun(jatom: &Jatom) -> (Noun, Jype) {
    let (noun, atype) = match &jatom.variant {
        AtomVariant::Number(n) => (Noun::Atom(*n), JatomType::Number),
        AtomVariant::Hexadecimal(n) => (Noun::Atom(*n), JatomType::Hexadecimal),
        AtomVariant::Loobean(b) => {
            // Nock loobeans: true = 0, false = 1
            let val = if *b { 0u64 } else { 1u64 };
            (Noun::Atom(val), JatomType::Loobean)
        }
        AtomVariant::String(s) => (Noun::from_string(s), JatomType::String),
    };
    let typ = Jype::Leaf {
        leaf: Box::new(JypeLeaf::Atom {
            typ: atype,
            constant: jatom.constant,
        }),
        name: String::new(),
    };
    (noun, typ)
}

/// Create an atom type.
fn atom_type(typ: JatomType) -> Jype {
    Jype::Leaf {
        leaf: Box::new(JypeLeaf::Atom {
            typ,
            constant: false,
        }),
        name: String::new(),
    }
}

/// Create a fork (union) type.
fn fork_type(a: &Jype, b: &Jype) -> Jype {
    Jype::Leaf {
        leaf: Box::new(JypeLeaf::Fork {
            p: Box::new(a.clone()),
            q: Box::new(b.clone()),
        }),
        name: String::new(),
    }
}

/// Infer the type for a let binding.
fn infer_let_type(
    declared: &Jype,
    val_jyp: &Jype,
    jyp: &Jype,
) -> Result<Jype, CompileError> {
    // Check if the declared type is a limb reference (type annotation).
    if let Jype::Leaf { leaf, name, .. } = declared {
        if let JypeLeaf::Limb(limbs) = leaf.as_ref() {
            if !limbs.is_empty() && matches!(limbs[0], Jlimb::Type(_)) {
                // Case 3: let name:Type = value;
                // Resolve the type reference and use it.
                let lim = get_limb(jyp, limbs);
                if let Ok(LimbResult::Direct { typ: _, .. }) = lim {
                    return Ok(Jype::Leaf {
                        leaf: Box::new(JypeLeaf::Limb(vec![Jlimb::Type(
                            val_jyp.name().to_string(),
                        )])),
                        name: name.clone(),
                    });
                }
                // Fall through to unification.
            }
        }
    }

    // Check if the value type is a constructor type (starts with uppercase).
    if is_type(val_jyp.name()) {
        // Case 4: let name = Type(value);
        return Ok(Jype::Leaf {
            leaf: Box::new(JypeLeaf::Limb(vec![Jlimb::Type(
                val_jyp.name().to_string(),
            )])),
            name: declared.name().to_string(),
        });
    }

    // Cases 1 and 2: unify declared type with value type.
    unify(declared, val_jyp).ok_or_else(|| CompileError::TypeMismatch {
        have: format!("{:?}", val_jyp),
        need: format!("{:?}", declared),
    })
}

/// Convert a Jype to its default Nock value.
///
/// Port of `++type-to-default` (jock.hoon lines 2412-2444).
fn type_to_default(jyp: &Jype) -> Nock {
    match jyp {
        Jype::Cell { p, q, .. } => {
            Nock::autocons(type_to_default(p), type_to_default(q))
        }
        Jype::Leaf { leaf, .. } => {
            match leaf.as_ref() {
                JypeLeaf::Atom { .. } => Nock::Constant(Noun::Atom(0)),
                JypeLeaf::Core { body, .. } => {
                    match body {
                        CoreBody::Arms(_) => Nock::Constant(Noun::Atom(0)),
                        CoreBody::Lambda(arg) => {
                            match &arg.inp {
                                None => Nock::Axis(0), // crash
                                Some(inp) => Nock::autocons(
                                    Nock::Constant(Noun::Atom(0)),
                                    type_to_default(inp),
                                ),
                            }
                        }
                    }
                }
                JypeLeaf::Limb(limbs) => {
                    // Would need to resolve the limb to get the actual type.
                    // For now, use a sensible default.
                    let _ = limbs;
                    Nock::Constant(Noun::Atom(0))
                }
                JypeLeaf::Fork { p, .. } => type_to_default(p),
                JypeLeaf::List { .. } => Nock::Constant(Noun::Atom(0)),
                JypeLeaf::Set { .. } => Nock::Constant(Noun::Atom(0)),
                JypeLeaf::State { p } => type_to_default(p),
                JypeLeaf::None { .. } => Nock::Constant(Noun::Atom(0)),
            }
        }
    }
}

/// Resolve a wing path to a Nock formula.
///
/// Port of `++resolve-wing` (jock.hoon lines 2389-2410).
pub fn resolve_wing(wings: &[Jwing]) -> Nock {
    if wings.is_empty() {
        return Nock::Axis(1);
    }

    let mut result = match &wings[0] {
        Jwing::Leg(axis) => Nock::Axis(*axis),
        Jwing::Arm { arm_axis, core_axis } => {
            Nock::fire(*arm_axis, Nock::Axis(*core_axis))
        }
    };

    for wing in &wings[1..] {
        result = match wing {
            Jwing::Leg(axis) => {
                if *axis == 1 {
                    result // identity — no change
                } else {
                    Nock::then(result, Nock::Axis(*axis))
                }
            }
            Jwing::Arm { arm_axis, core_axis } => {
                Nock::push(result, Nock::fire(*arm_axis, Nock::Axis(*core_axis)))
            }
        };
    }

    result
}

/// Resolve a limb path to a type and axis.
fn resolve_limb_to_axis(
    limbs: &[Jlimb],
    jyp: &Jype,
) -> Result<(Jype, u64), CompileError> {
    let result = get_limb(jyp, limbs)?;
    match result {
        LimbResult::Direct { typ, wings } => {
            let axis = match wings.first() {
                Some(Jwing::Leg(a)) => *a,
                Some(Jwing::Arm { arm_axis, core_axis }) => peg(*core_axis, *arm_axis),
                None => 1,
            };
            Ok((typ, axis))
        }
        LimbResult::Hoon { .. } => {
            Err(CompileError::RequiresHoonLibrary {
                feature: format!("limb resolution: {:?}", limbs),
            })
        }
    }
}

/// Get the return type from a core/function type.
fn get_return_type(typ: &Jype) -> Jype {
    match typ {
        Jype::Leaf { leaf, .. } => {
            match leaf.as_ref() {
                JypeLeaf::Core { body, .. } => {
                    match body {
                        CoreBody::Lambda(arg) => (*arg.out).clone(),
                        CoreBody::Arms(arms) => {
                            // For object cores, return the first arm's type.
                            arms.first()
                                .map(|(_, t)| t.clone())
                                .unwrap_or_else(untyped_j)
                        }
                    }
                }
                _ => untyped_j(),
            }
        }
        _ => untyped_j(),
    }
}

/// Convert a Nock formula to a Noun (for embedding as a constant).
fn nock_to_noun(nock: &Nock) -> Noun {
    nock.to_noun()
}

/// Encode a short ASCII string as a u64 (little-endian, Hoon cord encoding).
fn cord_to_u64(s: &str) -> u64 {
    let bytes = s.as_bytes();
    let mut val: u64 = 0;
    for (i, &b) in bytes.iter().enumerate() {
        if i >= 8 {
            break;
        }
        val |= (b as u64) << (i * 8);
    }
    val
}

/// Build an autocons tree from a list of Nock formulas.
/// [a [b [c ...]]] — right-leaning.
fn build_autocons_tree(nocks: &[Nock]) -> Nock {
    if nocks.is_empty() {
        return Nock::Constant(Noun::Atom(0));
    }
    if nocks.len() == 1 {
        return nocks[0].clone();
    }
    let mut result = nocks.last().unwrap().clone();
    for nock in nocks[..nocks.len() - 1].iter().rev() {
        result = Nock::autocons(nock.clone(), result);
    }
    result
}

/// Build a simple set tree from nouns.
/// Uses a right-leaning tree with null at leaves.
fn build_set_tree(nouns: &[Noun]) -> Noun {
    if nouns.is_empty() {
        return Noun::Atom(0); // empty set = null
    }
    // Build a simple balanced tree. Each node is [value left right]
    // but for constant sets in the Hoon compiler, it just uses `put:in`.
    // Simplest approach: build a right-leaning list-like tree.
    let mut result = Noun::Atom(0);
    for noun in nouns.iter().rev() {
        // Hoon set node: [n l r] where n=value, l=left, r=right
        // For a simple right-leaning tree: [n ~ right]
        result = Noun::cell(
            noun.clone(),
            Noun::cell(Noun::Atom(0), result),
        );
    }
    result
}
