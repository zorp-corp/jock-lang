/// Jock AST node definitions.
///
/// Mirrors the Hoon `+$jock`, `+$jype`, `+$jlimb`, and related types
/// from `jock.hoon` lines 238-397.
use jock_tokenizer::Jatom;

/// Main AST node. Corresponds to Hoon `+$jock` (lines 238-268).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Jock {
    /// `$^  [p=jock q=jock]` — cell/pair
    Cell {
        p: Box<Jock>,
        q: Box<Jock>,
    },
    /// `[%let type=jype val=jock next=jock]`
    Let {
        typ: Jype,
        val: Box<Jock>,
        next: Box<Jock>,
    },
    /// `[%func type=jype body=jock next=jock]`
    Func {
        typ: Jype,
        body: Box<Jock>,
        next: Box<Jock>,
    },
    /// `[%class state=jype arms=(map term jock)]`
    Class {
        state: Jype,
        arms: Vec<(String, Jock)>,
    },
    /// `[%method type=jype body=jock]`
    Method {
        typ: Jype,
        body: Box<Jock>,
    },
    /// `[%edit limb=(list jlimb) val=jock next=jock]`
    Edit {
        limb: Vec<Jlimb>,
        val: Box<Jock>,
        next: Box<Jock>,
    },
    /// `[%increment val=jock]`
    Increment {
        val: Box<Jock>,
    },
    /// `[%cell-check val=jock]`
    CellCheck {
        val: Box<Jock>,
    },
    /// `[%compose p=jock q=jock]`
    Compose {
        p: Box<Jock>,
        q: Box<Jock>,
    },
    /// `[%object name=term p=(map term jock) q=(unit jock)]`
    Object {
        name: String,
        p: Vec<(String, Jock)>,
        q: Option<Box<Jock>>,
    },
    /// `[%eval p=jock q=jock]`
    Eval {
        p: Box<Jock>,
        q: Box<Jock>,
    },
    /// `[%loop next=jock]`
    Loop {
        next: Box<Jock>,
    },
    /// `[%defer next=jock]`
    Defer {
        next: Box<Jock>,
    },
    /// `[%if cond=jock then=jock after=after-if-expression]`
    If {
        cond: Box<Jock>,
        then: Box<Jock>,
        after: AfterIf,
    },
    /// `[%assert cond=jock then=jock]`
    Assert {
        cond: Box<Jock>,
        then: Box<Jock>,
    },
    /// `[%match value=jock cases=(map jock jock) default=(unit jock)]`
    Match {
        value: Box<Jock>,
        cases: Vec<(Jock, Jock)>,
        default: Option<Box<Jock>>,
    },
    /// `[%cases value=jock cases=(map jock jock) default=(unit jock)]` (switch)
    Switch {
        value: Box<Jock>,
        cases: Vec<(Jock, Jock)>,
        default: Option<Box<Jock>>,
    },
    /// `[%call func=jock arg=(unit jock)]`
    Call {
        func: Box<Jock>,
        arg: Option<Box<Jock>>,
    },
    /// `[%compare comp=comparator a=jock b=jock]`
    Compare {
        comp: Comparator,
        a: Box<Jock>,
        b: Box<Jock>,
    },
    /// `[%operator op=operator a=jock b=(unit jock)]`
    Operator {
        op: Operator,
        a: Box<Jock>,
        b: Option<Box<Jock>>,
    },
    /// `[%lambda p=lambda]`
    Lambda(Lambda),
    /// `[%limb p=(list jlimb)]`
    Limb(Vec<Jlimb>),
    /// `[%atom p=jatom]`
    Atom(Jatom),
    /// `[%list type=jype-leaf val=(list jock)]`
    List {
        typ: JypeLeaf,
        val: Vec<Jock>,
    },
    /// `[%set type=jype-leaf val=(set jock)]`
    Set {
        typ: JypeLeaf,
        val: Vec<Jock>,
    },
    /// `[%import name=jype next=jock]`
    Import {
        name: Jype,
        next: Box<Jock>,
    },
    /// `[%print body=?([%jock jock]) next=jock]`
    Print {
        body: Box<Jock>,
        next: Box<Jock>,
    },
    /// `[%crash ~]`
    Crash,
}

/// After-if expression. Corresponds to Hoon `+$after-if-expression` (lines 289-292).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AfterIf {
    /// `[%else-if cond=jock then=jock after=after-if-expression]`
    ElseIf {
        cond: Box<Jock>,
        then: Box<Jock>,
        after: Box<AfterIf>,
    },
    /// `[%else then=jock]`
    Else { then: Box<Jock> },
}

/// Comparison operators. Corresponds to Hoon `+$comparator` (lines 294-302).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Comparator {
    Lt,  // <
    Gt,  // >
    Ne,  // !=
    Eq,  // ==
    Le,  // <=
    Ge,  // >=
}

/// Arithmetic/math operators. Corresponds to Hoon `+$operator` (lines 311-319).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Operator {
    Add, // +
    Sub, // -
    Mul, // *
    Div, // /
    Mod, // %
    Pow, // **
}

/// Type expression. Corresponds to Hoon `+$jype` (lines 328-332).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Jype {
    /// Cell type pair `[p=jype q=jype]` with name
    Cell {
        p: Box<Jype>,
        q: Box<Jype>,
        name: String,
    },
    /// Leaf type with name
    Leaf {
        leaf: Box<JypeLeaf>,
        name: String,
    },
}

impl Jype {
    pub fn name(&self) -> &str {
        match self {
            Jype::Cell { name, .. } => name,
            Jype::Leaf { name, .. } => name,
        }
    }

    pub fn with_name(self, new_name: String) -> Self {
        match self {
            Jype::Cell { p, q, .. } => Jype::Cell {
                p,
                q,
                name: new_name,
            },
            Jype::Leaf { leaf, .. } => Jype::Leaf {
                leaf,
                name: new_name,
            },
        }
    }
}

/// Type leaf. Corresponds to Hoon `+$jype-leaf` (lines 334-354).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum JypeLeaf {
    /// `[%atom p=jatom-type q=?(%.y %.n)]`
    Atom {
        typ: JatomType,
        constant: bool,
    },
    /// `[%core p=core-body q=(unit jype)]`
    Core {
        body: CoreBody,
        context: Option<Box<Jype>>,
    },
    /// `[%limb p=(list jlimb)]`
    Limb(Vec<Jlimb>),
    /// `[%fork p=jype q=jype]`
    Fork {
        p: Box<Jype>,
        q: Box<Jype>,
    },
    /// `[%list type=jype]`
    List {
        typ: Box<Jype>,
    },
    /// `[%set type=jype]`
    Set {
        typ: Box<Jype>,
    },
    /// `[%state p=jype]`
    State {
        p: Box<Jype>,
    },
    /// `[%none p=(unit term)]`
    None {
        name: Option<String>,
    },
}

/// Atom base types. Corresponds to Hoon `+$jatom-type` (lines 362-368).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum JatomType {
    String,
    Number,
    Hexadecimal,
    Loobean,
}

/// Core body. Corresponds to Hoon `+$core-body` (line 370).
/// `(each lambda-argument (map term jype))`
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum CoreBody {
    Lambda(Box<LambdaArgument>),
    Arms(Vec<(String, Jype)>),
}

/// Lambda expression. Corresponds to Hoon `+$lambda` (lines 372-380).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Lambda {
    pub arg: LambdaArgument,
    pub body: Box<Jock>,
    pub context: Option<Box<Jock>>,
}

/// Lambda argument (input/output type pair).
/// Corresponds to Hoon `+$lambda-argument` (lines 382-388).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LambdaArgument {
    pub inp: Option<Box<Jype>>,
    pub out: Box<Jype>,
}

// ── Constructor helpers ─────────────────────────────────────────

impl Jype {
    pub fn leaf(leaf: JypeLeaf, name: impl Into<String>) -> Self {
        Jype::Leaf {
            leaf: Box::new(leaf),
            name: name.into(),
        }
    }
}

impl LambdaArgument {
    pub fn new(inp: Option<Jype>, out: Jype) -> Self {
        Self {
            inp: inp.map(Box::new),
            out: Box::new(out),
        }
    }
}

impl CoreBody {
    pub fn lambda(arg: LambdaArgument) -> Self {
        CoreBody::Lambda(Box::new(arg))
    }
}

/// Limb reference. Corresponds to Hoon `+$jlimb` (lines 390-397).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Jlimb {
    /// `[%name p=term]` — arm or leg name
    Name(String),
    /// `[%axis p=@]` — numeric axis
    Axis(u64),
    /// `[%type p=cord]` — type reference
    Type(String),
}
