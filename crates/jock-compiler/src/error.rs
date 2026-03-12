use std::fmt;

/// Errors that can occur during Jock-to-Nock compilation.
#[derive(Debug, Clone)]
pub enum CompileError {
    /// A limb reference could not be resolved in the current subject.
    LimbNotFound(String),
    /// Type mismatch: value does not nest in declared type.
    TypeMismatch { have: String, need: String },
    /// Feature requires the Hoon standard library (arithmetic, ordering).
    RequiresHoonLibrary { feature: String },
    /// A call target must be a limb or lambda.
    InvalidCallTarget(String),
    /// An operator requires a second argument.
    MissingOperand { op: String },
    /// Empty list or set literal.
    EmptyCollection { kind: String },
    /// Axis too large.
    AxisOverflow(u64),
    /// Internal compiler error.
    Internal(String),
}

impl fmt::Display for CompileError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            CompileError::LimbNotFound(msg) => write!(f, "limb not found: {msg}"),
            CompileError::TypeMismatch { have, need } => {
                write!(f, "type mismatch: have {have}, need {need}")
            }
            CompileError::RequiresHoonLibrary { feature } => {
                write!(f, "feature '{feature}' requires the Hoon standard library")
            }
            CompileError::InvalidCallTarget(msg) => {
                write!(f, "invalid call target: {msg}")
            }
            CompileError::MissingOperand { op } => {
                write!(f, "operator '{op}' requires a second operand")
            }
            CompileError::EmptyCollection { kind } => {
                write!(f, "empty {kind} literal")
            }
            CompileError::AxisOverflow(axis) => {
                write!(f, "axis overflow: {axis}")
            }
            CompileError::Internal(msg) => write!(f, "internal compiler error: {msg}"),
        }
    }
}

impl std::error::Error for CompileError {}
