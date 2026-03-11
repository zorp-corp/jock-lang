use std::fmt;

/// A position within the source input.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Position {
    pub offset: usize,
    pub line: usize,
    pub column: usize,
}

/// The kind of lexer error.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ErrorKind {
    UnexpectedCharacter(char),
    UnterminatedString,
    UnterminatedBlockComment,
    InvalidHexLiteral,
    NumberOverflow,
    TrailingInput,
    UnexpectedEndOfInput,
}

/// A lexer error with position information.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LexError {
    pub kind: ErrorKind,
    pub position: Position,
}

impl fmt::Display for LexError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{}:{}: {}",
            self.position.line, self.position.column, self.kind
        )
    }
}

impl fmt::Display for ErrorKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ErrorKind::UnexpectedCharacter(c) => write!(f, "unexpected character '{c}'"),
            ErrorKind::UnterminatedString => write!(f, "unterminated string literal"),
            ErrorKind::UnterminatedBlockComment => write!(f, "unterminated block comment"),
            ErrorKind::InvalidHexLiteral => write!(f, "invalid hexadecimal literal"),
            ErrorKind::NumberOverflow => write!(f, "number literal overflows u64"),
            ErrorKind::TrailingInput => write!(f, "unexpected trailing input"),
            ErrorKind::UnexpectedEndOfInput => write!(f, "unexpected end of input"),
        }
    }
}

impl std::error::Error for LexError {}
