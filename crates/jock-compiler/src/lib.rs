pub mod compiler;
pub mod error;
pub mod nock;
pub mod subject;

pub use compiler::mint;
pub use error::CompileError;
pub use nock::{HintTag, Nock, Noun};
pub use subject::{Jwing, LimbResult, default_subject_type};

use jock_parser::Jock;

/// Compile a Jock AST to Nock.
///
/// Uses the default initial subject type (`[%atom %string %.n]`).
pub fn compile(ast: &Jock) -> Result<Nock, CompileError> {
    let initial_type = default_subject_type();
    let (nock, _type) = mint(ast, &initial_type)?;
    Ok(nock)
}

/// Compile a Jock AST to Nock with a custom initial subject type.
///
/// Returns both the Nock formula and the inferred result type.
pub fn compile_with_type(
    ast: &Jock,
    initial_type: &jock_parser::Jype,
) -> Result<(Nock, jock_parser::Jype), CompileError> {
    mint(ast, initial_type)
}

#[cfg(test)]
mod tests;
