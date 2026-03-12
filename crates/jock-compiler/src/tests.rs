use jock_parser::parse;
use jock_tokenizer::tokenize;

use crate::compile;
use crate::nock::{Nock, Noun};

/// Helper: tokenize + parse + compile a Jock source string.
fn compile_src(src: &str) -> Nock {
    let tokens = tokenize(src).expect("tokenize failed");
    let ast = parse(tokens).expect("parse failed");
    compile(&ast).expect("compile failed")
}

#[test]
fn test_atom_number() {
    let nock = compile_src("42");
    assert_eq!(nock, Nock::Constant(Noun::Atom(42)));
}

#[test]
fn test_atom_zero() {
    let nock = compile_src("0");
    assert_eq!(nock, Nock::Constant(Noun::Atom(0)));
}

#[test]
fn test_loobean_true() {
    // Nock true = 0
    let nock = compile_src("true");
    assert_eq!(nock, Nock::Constant(Noun::Atom(0)));
}

#[test]
fn test_loobean_false() {
    // Nock false = 1
    let nock = compile_src("false");
    assert_eq!(nock, Nock::Constant(Noun::Atom(1)));
}

#[test]
fn test_cell() {
    let nock = compile_src("(1 2)");
    assert_eq!(
        nock,
        Nock::autocons(
            Nock::Constant(Noun::Atom(1)),
            Nock::Constant(Noun::Atom(2)),
        )
    );
}

#[test]
fn test_crash() {
    let nock = compile_src("crash");
    assert_eq!(nock, Nock::Axis(0));
}

#[test]
fn test_increment() {
    let nock = compile_src("+(42)");
    assert_eq!(nock, Nock::Increment(Box::new(Nock::Constant(Noun::Atom(42)))));
}

#[test]
fn test_cell_check() {
    let nock = compile_src("?(42)");
    assert_eq!(nock, Nock::CellTest(Box::new(Nock::Constant(Noun::Atom(42)))));
}

#[test]
fn test_equality() {
    let nock = compile_src("1 == 2");
    assert_eq!(
        nock,
        Nock::Equals(
            Box::new(Nock::Constant(Noun::Atom(1))),
            Box::new(Nock::Constant(Noun::Atom(2))),
        )
    );
}

#[test]
fn test_inequality() {
    let nock = compile_src("1 != 2");
    assert_eq!(
        nock,
        Nock::if_then_else(
            Nock::Equals(
                Box::new(Nock::Constant(Noun::Atom(1))),
                Box::new(Nock::Constant(Noun::Atom(2))),
            ),
            Nock::Constant(Noun::Atom(1)),
            Nock::Constant(Noun::Atom(0)),
        )
    );
}

#[test]
fn test_if_else() {
    let nock = compile_src("if true { 1 } else { 2 }");
    assert_eq!(
        nock,
        Nock::if_then_else(
            Nock::Constant(Noun::Atom(0)), // true = 0 in Nock
            Nock::Constant(Noun::Atom(1)),
            Nock::Constant(Noun::Atom(2)),
        )
    );
}

#[test]
fn test_assert() {
    let nock = compile_src("assert true;\n42");
    assert_eq!(
        nock,
        Nock::if_then_else(
            Nock::Constant(Noun::Atom(0)),
            Nock::Constant(Noun::Atom(42)),
            Nock::Axis(0), // crash on false
        )
    );
}

#[test]
fn test_let_binding() {
    // let x = 5; x
    // Should compile to: [8 [1 5] [0 2]]
    // Push 5 onto subject, then access head (axis 2)
    let nock = compile_src("let x = 5; x");
    assert_eq!(
        nock,
        Nock::push(
            Nock::Constant(Noun::Atom(5)),
            Nock::Axis(2),
        )
    );
}

#[test]
fn test_nested_let() {
    // let x = 1; let y = 2; (x y)
    // Push 1, push 2, access x (axis 6) and y (axis 2)
    let nock = compile_src("let x = 1; let y = 2; (x y)");
    assert_eq!(
        nock,
        Nock::push(
            Nock::Constant(Noun::Atom(1)),
            Nock::push(
                Nock::Constant(Noun::Atom(2)),
                Nock::autocons(
                    Nock::Axis(6), // x is at axis 6 after two pushes
                    Nock::Axis(2), // y is at axis 2 (head)
                ),
            ),
        )
    );
}

#[test]
fn test_nock_to_noun_display() {
    // Verify that Nock formulas serialize correctly.
    let nock = Nock::Constant(Noun::Atom(42));
    let noun = nock.to_noun();
    assert_eq!(format!("{}", noun), "[1 42]");

    let nock = Nock::Axis(3);
    let noun = nock.to_noun();
    assert_eq!(format!("{}", noun), "[0 3]");
}

#[test]
fn test_string_atom() {
    let noun = Noun::from_string("abc");
    // 'abc' in little-endian: a=0x61, b=0x62, c=0x63
    // = 0x61 | (0x62 << 8) | (0x63 << 16) = 97 + 25088 + 6488064 = 6513249
    assert_eq!(noun, Noun::Atom(6513249));
}
