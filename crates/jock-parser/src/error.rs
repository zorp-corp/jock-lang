use jock_tokenizer::Token;
use std::fmt;

/// A parse error with position information.
#[derive(Debug, Clone)]
pub struct ParseError {
    pub kind: ParseErrorKind,
    /// Token index where the error occurred.
    pub position: usize,
}

#[derive(Debug, Clone)]
pub enum ParseErrorKind {
    /// Expected a specific token, got something else (or end of input).
    UnexpectedToken {
        expected: String,
        found: Option<Token>,
    },
    /// Ran out of tokens when more were expected.
    UnexpectedEndOfInput { expected: String },
    /// Attempted to shadow a reserved type name (e.g. List, Set).
    ReservedType(String),
}

impl fmt::Display for ParseError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match &self.kind {
            ParseErrorKind::UnexpectedToken { expected, found } => match found {
                Some(tok) => write!(
                    f,
                    "parse error at token {}: expected {}, found {:?}",
                    self.position, expected, tok,
                ),
                None => write!(
                    f,
                    "parse error at token {}: expected {}, found end of input",
                    self.position, expected,
                ),
            },
            ParseErrorKind::UnexpectedEndOfInput { expected } => {
                write!(
                    f,
                    "parse error: unexpected end of input, expected {}",
                    expected,
                )
            }
            ParseErrorKind::ReservedType(name) => {
                write!(
                    f,
                    "parse error at token {}: shadowing reserved type '{}' is not allowed",
                    self.position, name,
                )
            }
        }
    }
}

impl std::error::Error for ParseError {}
