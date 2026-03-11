pub mod ast;
pub mod error;
mod parser;

pub use ast::*;
pub use error::{ParseError, ParseErrorKind};
pub use parser::Parser;

use jock_tokenizer::Token;

/// Parse a list of Jock tokens into an AST.
///
/// Corresponds to the Hoon parser arm `++match-jock` invoked on
/// the full token list produced by `++tokenize`.
pub fn parse(tokens: Vec<Token>) -> Result<Jock, ParseError> {
    let mut parser = Parser::new(tokens);
    parser.parse()
}

#[cfg(test)]
mod tests;
