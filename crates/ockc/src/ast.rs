use std::ops::Range;

pub type Span = Range<usize>;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Spanned<T> {
    pub item: T,
    pub span: Span,
}

impl<T> Spanned<T> {
    pub fn new(item: T, span: Span) -> Self {
        Self { item, span }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Keyword {
    Let,
    Func,
    Lambda,
    Class,
    Struct,
    Impl,
    Trait,
    Union,
    Alias,
    Object,
    If,
    Else,
    Crash,
    Assert,
    Compose,
    Loop,
    Defer,
    Recur,
    Match,
    Switch,
    Eval,
    With,
    This,
    Import,
    As,
    Print,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Punct {
    Dot,
    Semi,
    Comma,
    Colon,
    Amp,
    Dollar,
    At,
    Question,
    Bang,
    CallOpen,
    OpenParen,
    CloseParen,
    OpenBrace,
    CloseBrace,
    OpenBracket,
    CloseBracket,
    Equals,
    EqEq,
    NotEq,
    Less,
    LessEq,
    Greater,
    GreaterEq,
    Hash,
    Plus,
    Minus,
    Star,
    StarStar,
    Slash,
    Percent,
    Underscore,
    Arrow,
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum TokenKind {
    Keyword(Keyword),
    Punct(Punct),
    Literal(Literal),
    Name(String),
    Type(String),
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum Literal {
    Atom(AtomLiteral),
    Noun(NounLiteral),
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum AtomLiteral {
    Chars(String),
    Number(String),
    Sint(String),
    Hex(String),
    Real(String),
    Real16(String),
    Real32(String),
    Real128(String),
    Logical(bool),
    Date(String),
    Span(String),
    Constant(Box<AtomLiteral>),
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum NounLiteral {
    String(String),
    Path(String),
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum AtomType {
    Chars,
    Number,
    Sint,
    Hex,
    Real,
    Real16,
    Real32,
    Real128,
    Logical,
    Date,
    Span,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum NounType {
    String,
    Path,
}

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum Limb {
    Name(String),
    Axis(u64),
    Type(String),
}

#[derive(Debug, Clone, PartialEq)]
pub struct TypeExpr {
    pub kind: TypeExprKind,
    pub name: Option<String>,
    pub span: Span,
}

impl TypeExpr {
    pub fn new(kind: TypeExprKind, name: Option<String>, span: Span) -> Self {
        Self { kind, name, span }
    }

    pub fn with_name(mut self, name: String) -> Self {
        self.name = Some(name);
        self
    }
}

#[derive(Debug, Clone, PartialEq)]
pub enum TypeExprKind {
    Cell(Box<TypeExpr>, Box<TypeExpr>),
    Leaf(TypeLeaf),
}

#[derive(Debug, Clone, PartialEq)]
pub enum TypeLeaf {
    Atom {
        atom: AtomType,
        constant: bool,
    },
    Noun(NounType),
    Limb(Vec<Limb>),
    Function {
        input: Box<TypeExpr>,
        output: Box<TypeExpr>,
    },
    Fork(Box<TypeExpr>, Box<TypeExpr>),
    List(Box<TypeExpr>),
    Set(Box<TypeExpr>),
    Hoon,
    State(Box<TypeExpr>),
    None,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Comparator {
    Eq,
    NotEq,
    Lt,
    Le,
    Gt,
    Ge,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Operator {
    Add,
    Sub,
    Mul,
    Div,
    Mod,
    Pow,
}

#[derive(Debug, Clone, PartialEq)]
pub struct Expr {
    pub kind: ExprKind,
    pub span: Span,
}

impl Expr {
    pub fn new(kind: ExprKind, span: Span) -> Self {
        Self { kind, span }
    }
}

#[derive(Debug, Clone, PartialEq)]
pub struct Lambda {
    pub input: TypeExpr,
    pub output: TypeExpr,
    pub body: Box<Expr>,
    pub context: Option<Box<Expr>>,
}

#[derive(Debug, Clone, PartialEq)]
pub struct Method {
    pub name: String,
    pub input: TypeExpr,
    pub output: TypeExpr,
    pub body: Box<Expr>,
}

#[derive(Debug, Clone, PartialEq)]
pub enum ExprKind {
    Pair(Box<Expr>, Box<Expr>),
    Let {
        name: String,
        ty: TypeExpr,
        value: Box<Expr>,
        next: Box<Expr>,
    },
    Edit {
        target: Vec<Limb>,
        value: Box<Expr>,
        next: Box<Expr>,
    },
    Func {
        name: String,
        input: TypeExpr,
        output: TypeExpr,
        body: Box<Expr>,
        next: Box<Expr>,
    },
    Lambda(Lambda),
    Alias {
        name: String,
        target: String,
    },
    Class {
        name: String,
        state: TypeExpr,
        methods: Vec<Method>,
    },
    Object {
        name: Option<String>,
        arms: Vec<(String, Expr)>,
        context: Option<Box<Expr>>,
    },
    If {
        cond: Box<Expr>,
        then: Box<Expr>,
        otherwise: Option<Box<Expr>>,
    },
    Assert {
        cond: Box<Expr>,
        then: Box<Expr>,
    },
    Compose {
        left: Box<Expr>,
        right: Box<Expr>,
    },
    Loop {
        next: Box<Expr>,
    },
    Defer {
        next: Box<Expr>,
    },
    Match {
        value: Box<Expr>,
        cases: Vec<(Expr, Expr)>,
        default: Option<Box<Expr>>,
    },
    Switch {
        value: Box<Expr>,
        cases: Vec<(Expr, Expr)>,
        default: Option<Box<Expr>>,
    },
    Eval {
        target: Box<Expr>,
        sample: Box<Expr>,
    },
    Print {
        value: Box<Expr>,
        next: Box<Expr>,
    },
    Operator {
        op: Operator,
        left: Box<Expr>,
        right: Box<Expr>,
    },
    Increment {
        value: Box<Expr>,
    },
    CellCheck {
        value: Box<Expr>,
    },
    Call {
        func: Box<Expr>,
        arg: Option<Box<Expr>>,
    },
    Compare {
        op: Comparator,
        left: Box<Expr>,
        right: Box<Expr>,
    },
    Limb(Vec<Limb>),
    Atom(AtomLiteral),
    Noun(NounLiteral),
    List {
        elements: Vec<Expr>,
        element_type: Option<TypeExpr>,
    },
    Set {
        elements: Vec<Expr>,
        element_type: Option<TypeExpr>,
    },
    Import {
        module: String,
        alias: Option<String>,
        next: Box<Expr>,
    },
    With {
        context: Box<Expr>,
        body: Box<Expr>,
    },
    Crash,
}
