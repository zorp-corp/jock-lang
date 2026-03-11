pub mod error;
mod lexer;
pub mod token;

pub use error::{ErrorKind, LexError, Position};
pub use token::{AtomVariant, Jatom, Jpunc, Keyword, Token};

/// Tokenize a Jock source string into a list of tokens.
///
/// Corresponds to Hoon `++tokenize` (lines 14-17) which calls
/// `(rash txt parse-tokens)`.
pub fn tokenize(input: &str) -> Result<Vec<Token>, LexError> {
    let mut lexer = lexer::Lexer::new(input);
    lexer.tokenize_all()
}

#[cfg(test)]
mod tests;
