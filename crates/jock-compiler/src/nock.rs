/// A Nock noun: either an atom (unsigned integer) or a cell (pair of nouns).
///
/// This is the "data" representation — values that appear inside Nock constants
/// and as the output of evaluation.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Noun {
    /// An atom fitting in a u64.
    Atom(u64),
    /// An atom too large for u64 (e.g. long strings), stored as little-endian bytes.
    BigAtom(Vec<u8>),
    /// A cell: ordered pair of two nouns.
    Cell(Box<Noun>, Box<Noun>),
}

impl Noun {
    /// Create a cell noun.
    pub fn cell(p: Noun, q: Noun) -> Self {
        Noun::Cell(Box::new(p), Box::new(q))
    }

    /// Encode a UTF-8 string as a Nock atom (cord), little-endian byte packing.
    pub fn from_string(s: &str) -> Self {
        let bytes = s.as_bytes();
        if bytes.is_empty() {
            return Noun::Atom(0);
        }
        if bytes.len() <= 8 {
            let mut val: u64 = 0;
            for (i, &b) in bytes.iter().enumerate() {
                val |= (b as u64) << (i * 8);
            }
            Noun::Atom(val)
        } else {
            Noun::BigAtom(bytes.to_vec())
        }
    }
}

impl std::fmt::Display for Noun {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Noun::Atom(n) => write!(f, "{n}"),
            Noun::BigAtom(bytes) => {
                // Display as hex for big atoms
                write!(f, "0x")?;
                for b in bytes.iter().rev() {
                    write!(f, "{b:02x}")?;
                }
                Ok(())
            }
            Noun::Cell(p, q) => write!(f, "[{p} {q}]"),
        }
    }
}

/// A Nock formula (instruction tree).
///
/// Mirrors Hoon `+$nock` from jock.hoon lines 1396-1412.
/// Each variant corresponds to a Nock opcode.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Nock {
    /// Autocons: evaluate both sub-formulas, produce cell `[p q]`.
    Autocons(Box<Nock>, Box<Nock>),
    /// `[0 p]` — axis select: retrieve the value at axis `p` in the subject.
    Axis(u64),
    /// `[1 p]` — constant: produce the literal noun `p`.
    Constant(Noun),
    /// `[2 p q]` — compose: evaluate `p` for subject, `q` for formula, apply.
    Compose(Box<Nock>, Box<Nock>),
    /// `[3 p]` — cell test: 0 if result of `p` is a cell, 1 if atom.
    CellTest(Box<Nock>),
    /// `[4 p]` — increment: add 1 to the atom result of `p`.
    Increment(Box<Nock>),
    /// `[5 p q]` — equality test: 0 if equal, 1 if unequal.
    Equals(Box<Nock>, Box<Nock>),
    /// `[6 p q r]` — if-then-else: if `p` yields 0 evaluate `q`, if 1 evaluate `r`.
    IfThenElse(Box<Nock>, Box<Nock>, Box<Nock>),
    /// `[7 p q]` — serial compose: evaluate `p`, use result as subject for `q`.
    Then(Box<Nock>, Box<Nock>),
    /// `[8 p q]` — push: evaluate `p`, cons result onto subject, evaluate `q`.
    Push(Box<Nock>, Box<Nock>),
    /// `[9 p q]` — fire arm: evaluate `q` to get core, fire arm at axis `p`.
    Fire(u64, Box<Nock>),
    /// `[10 [p q] r]` — edit: evaluate `r`, replace axis `p` with result of `q`.
    Edit {
        axis: u64,
        value: Box<Nock>,
        target: Box<Nock>,
    },
    /// `[11 hint q]` — hint: evaluate `q` with hint metadata.
    Hint(HintTag, Box<Nock>),
}

/// Hint tag for Nock 11. Can be a bare tag or a dynamic [tag formula] pair.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum HintTag {
    /// `[11 p q]` — static hint (just a tag atom).
    Static(u64),
    /// `[11 [p q] r]` — dynamic hint (tag plus a formula to evaluate).
    Dynamic(u64, Box<Nock>),
}

impl Nock {
    /// Convenience: create an autocons pair.
    pub fn autocons(p: Nock, q: Nock) -> Self {
        Nock::Autocons(Box::new(p), Box::new(q))
    }

    /// Convenience: create an if-then-else.
    pub fn if_then_else(cond: Nock, then: Nock, els: Nock) -> Self {
        Nock::IfThenElse(Box::new(cond), Box::new(then), Box::new(els))
    }

    /// Convenience: create a push (Nock 8).
    pub fn push(head: Nock, body: Nock) -> Self {
        Nock::Push(Box::new(head), Box::new(body))
    }

    /// Convenience: create a then/serial compose (Nock 7).
    pub fn then(first: Nock, second: Nock) -> Self {
        Nock::Then(Box::new(first), Box::new(second))
    }

    /// Convenience: create a fire (Nock 9).
    pub fn fire(axis: u64, core: Nock) -> Self {
        Nock::Fire(axis, Box::new(core))
    }

    /// Convenience: create an edit (Nock 10).
    pub fn edit(axis: u64, value: Nock, target: Nock) -> Self {
        Nock::Edit {
            axis,
            value: Box::new(value),
            target: Box::new(target),
        }
    }

    /// Convert this Nock formula to a Noun representation.
    /// This serializes the instruction tree into the standard Nock noun format.
    pub fn to_noun(&self) -> Noun {
        match self {
            Nock::Autocons(p, q) => Noun::cell(p.to_noun(), q.to_noun()),
            Nock::Axis(p) => Noun::cell(Noun::Atom(0), Noun::Atom(*p)),
            Nock::Constant(n) => Noun::cell(Noun::Atom(1), n.clone()),
            Nock::Compose(p, q) => Noun::cell(
                Noun::Atom(2),
                Noun::cell(p.to_noun(), q.to_noun()),
            ),
            Nock::CellTest(p) => Noun::cell(Noun::Atom(3), p.to_noun()),
            Nock::Increment(p) => Noun::cell(Noun::Atom(4), p.to_noun()),
            Nock::Equals(p, q) => Noun::cell(
                Noun::Atom(5),
                Noun::cell(p.to_noun(), q.to_noun()),
            ),
            Nock::IfThenElse(p, q, r) => Noun::cell(
                Noun::Atom(6),
                Noun::cell(p.to_noun(), Noun::cell(q.to_noun(), r.to_noun())),
            ),
            Nock::Then(p, q) => Noun::cell(
                Noun::Atom(7),
                Noun::cell(p.to_noun(), q.to_noun()),
            ),
            Nock::Push(p, q) => Noun::cell(
                Noun::Atom(8),
                Noun::cell(p.to_noun(), q.to_noun()),
            ),
            Nock::Fire(p, q) => Noun::cell(
                Noun::Atom(9),
                Noun::cell(Noun::Atom(*p), q.to_noun()),
            ),
            Nock::Edit { axis, value, target } => Noun::cell(
                Noun::Atom(10),
                Noun::cell(
                    Noun::cell(Noun::Atom(*axis), value.to_noun()),
                    target.to_noun(),
                ),
            ),
            Nock::Hint(hint, q) => {
                let hint_noun = match hint {
                    HintTag::Static(tag) => Noun::Atom(*tag),
                    HintTag::Dynamic(tag, formula) => {
                        Noun::cell(Noun::Atom(*tag), formula.to_noun())
                    }
                };
                Noun::cell(Noun::Atom(11), Noun::cell(hint_noun, q.to_noun()))
            }
        }
    }
}

impl std::fmt::Display for Nock {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.to_noun())
    }
}
