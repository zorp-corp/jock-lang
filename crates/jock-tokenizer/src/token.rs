/// Corresponds to Hoon `+$keyword` (jock.hoon lines 56-79).
/// 21 reserved keywords in the Jock language.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Keyword {
    Let,
    Func,
    Lambda,
    Class,
    If,
    Else,
    Crash,
    Assert,
    Object,
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

/// All keywords in the order they appear in the Hoon `perk` list (lines 167-173).
/// Order matters: longer keywords sharing a prefix must appear before shorter ones
/// (e.g. `assert` before `as`).
pub const KEYWORDS: &[(Keyword, &str)] = &[
    (Keyword::Let, "let"),
    (Keyword::Func, "func"),
    (Keyword::Lambda, "lambda"),
    (Keyword::Class, "class"),
    (Keyword::If, "if"),
    (Keyword::Else, "else"),
    (Keyword::Crash, "crash"),
    (Keyword::Assert, "assert"),
    (Keyword::Object, "object"),
    (Keyword::Compose, "compose"),
    (Keyword::Loop, "loop"),
    (Keyword::Defer, "defer"),
    (Keyword::Recur, "recur"),
    (Keyword::Match, "match"),
    (Keyword::Switch, "switch"),
    (Keyword::Eval, "eval"),
    (Keyword::With, "with"),
    (Keyword::This, "this"),
    (Keyword::Import, "import"),
    (Keyword::As, "as"),
    (Keyword::Print, "print"),
];

impl Keyword {
    pub fn as_str(self) -> &'static str {
        match self {
            Keyword::Let => "let",
            Keyword::Func => "func",
            Keyword::Lambda => "lambda",
            Keyword::Class => "class",
            Keyword::If => "if",
            Keyword::Else => "else",
            Keyword::Crash => "crash",
            Keyword::Assert => "assert",
            Keyword::Object => "object",
            Keyword::Compose => "compose",
            Keyword::Loop => "loop",
            Keyword::Defer => "defer",
            Keyword::Recur => "recur",
            Keyword::Match => "match",
            Keyword::Switch => "switch",
            Keyword::Eval => "eval",
            Keyword::With => "with",
            Keyword::This => "this",
            Keyword::Import => "import",
            Keyword::As => "as",
            Keyword::Print => "print",
        }
    }
}

/// Corresponds to Hoon `+$jpunc` (jock.hoon lines 81-88).
/// Punctuation tokens including the `((` pseudo-punctuator for function calls.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Jpunc {
    Dot,         // .
    Semicolon,   // ;
    Comma,       // ,
    Colon,       // :
    Ampersand,   // &
    Dollar,      // $
    At,          // @
    Question,    // ?
    Bang,        // !
    DoubleParen, // (( pseudo-punctuator
    LParen,      // (
    RParen,      // )
    LBrace,      // {
    RBrace,      // }
    LBracket,    // [
    RBracket,    // ]
    Equals,      // =
    LessThan,    // <
    GreaterThan, // >
    Hash,        // #
    Plus,        // +
    Minus,       // -
    Star,        // *
    Slash,       // /
    Percent,     // %
    Underscore,  // _
}

impl Jpunc {
    /// Map a single ASCII character to its punctuator variant.
    /// Returns `None` for characters that are not punctuators.
    /// `DoubleParen` is never returned here; it is synthesized by the lexer.
    pub fn from_char(c: u8) -> Option<Jpunc> {
        match c {
            b'.' => Some(Jpunc::Dot),
            b';' => Some(Jpunc::Semicolon),
            b',' => Some(Jpunc::Comma),
            b':' => Some(Jpunc::Colon),
            b'&' => Some(Jpunc::Ampersand),
            b'$' => Some(Jpunc::Dollar),
            b'@' => Some(Jpunc::At),
            b'?' => Some(Jpunc::Question),
            b'!' => Some(Jpunc::Bang),
            b'(' => Some(Jpunc::LParen),
            b')' => Some(Jpunc::RParen),
            b'{' => Some(Jpunc::LBrace),
            b'}' => Some(Jpunc::RBrace),
            b'[' => Some(Jpunc::LBracket),
            b']' => Some(Jpunc::RBracket),
            b'=' => Some(Jpunc::Equals),
            b'<' => Some(Jpunc::LessThan),
            b'>' => Some(Jpunc::GreaterThan),
            b'#' => Some(Jpunc::Hash),
            b'+' => Some(Jpunc::Plus),
            b'-' => Some(Jpunc::Minus),
            b'*' => Some(Jpunc::Star),
            b'/' => Some(Jpunc::Slash),
            b'%' => Some(Jpunc::Percent),
            b'_' => Some(Jpunc::Underscore),
            _ => None,
        }
    }
}

/// The value part of a literal atom.
/// Corresponds to the tagged union inside Hoon `+$jatom` (lines 93-97).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum AtomVariant {
    String(String),
    Number(u64),
    Hexadecimal(u64),
    Loobean(bool),
}

/// A literal atom with a constant flag.
/// Corresponds to Hoon `+$jatom` (lines 90-99).
///
/// `constant` is `true` for symbol literals (prefixed with `%`),
/// `false` for plain literals.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Jatom {
    pub variant: AtomVariant,
    pub constant: bool,
}

/// Corresponds to Hoon `+$token` (jock.hoon lines 101-108).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Token {
    Keyword(Keyword),
    Punctuator(Jpunc),
    Literal(Jatom),
    Name(String),
    Type(String),
}
