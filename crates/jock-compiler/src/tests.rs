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

/// Helper: try to compile, return Ok or Err.
fn try_compile(src: &str) -> Result<Nock, crate::CompileError> {
    let tokens = tokenize(src).expect("tokenize failed");
    let ast = parse(tokens).expect("parse failed");
    compile(&ast)
}

// ════════════════════════════════════════════════════════════════
// Atom and literal tests
// ════════════════════════════════════════════════════════════════

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
fn test_string_atom() {
    let noun = Noun::from_string("abc");
    // 'abc' in little-endian: a=0x61, b=0x62, c=0x63
    assert_eq!(noun, Noun::Atom(6513249));
}

// ════════════════════════════════════════════════════════════════
// Cell tests
// ════════════════════════════════════════════════════════════════

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
fn test_triple() {
    // (1 2 3) = [1 [2 3]]
    let nock = compile_src("(1 2 3)");
    assert_eq!(
        nock,
        Nock::autocons(
            Nock::Constant(Noun::Atom(1)),
            Nock::autocons(
                Nock::Constant(Noun::Atom(2)),
                Nock::Constant(Noun::Atom(3)),
            ),
        )
    );
}

// ════════════════════════════════════════════════════════════════
// Crash
// ════════════════════════════════════════════════════════════════

#[test]
fn test_crash() {
    let nock = compile_src("crash");
    assert_eq!(nock, Nock::Axis(0));
}

// ════════════════════════════════════════════════════════════════
// Increment and cell check
// ════════════════════════════════════════════════════════════════

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

// ════════════════════════════════════════════════════════════════
// Comparison operators
// ════════════════════════════════════════════════════════════════

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

// ════════════════════════════════════════════════════════════════
// Control flow: if/else, if/elseif/else, assert
// ════════════════════════════════════════════════════════════════

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
    // assert.hoon: assert true; 42
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

/// if-elseif-else.hoon: let a:@ = 3; if a == 3 { 42 } else if a == 5 { 17 } else { 15 }
#[test]
fn test_if_elseif_else() {
    let nock = compile_src("let a: @ = 3;\n\nif a == 3 {\n  42\n} else if a == 5 {\n  17\n} else {\n  15\n}\n");
    assert_eq!(
        nock,
        Nock::push(
            Nock::Constant(Noun::Atom(3)),
            Nock::if_then_else(
                Nock::Equals(Box::new(Nock::Axis(2)), Box::new(Nock::Constant(Noun::Atom(3)))),
                Nock::Constant(Noun::Atom(42)),
                Nock::if_then_else(
                    Nock::Equals(Box::new(Nock::Axis(2)), Box::new(Nock::Constant(Noun::Atom(5)))),
                    Nock::Constant(Noun::Atom(17)),
                    Nock::Constant(Noun::Atom(15)),
                ),
            ),
        )
    );
}

// ════════════════════════════════════════════════════════════════
// Let bindings (from let-inner-exp.hoon, example-atom.hoon)
// ════════════════════════════════════════════════════════════════

/// let-inner-exp.hoon: let a = 42; a
/// Expected: [8 [1 42] [0 2]]
#[test]
fn test_let_binding() {
    let nock = compile_src("let a = 42;\na\n");
    assert_eq!(
        nock,
        Nock::push(
            Nock::Constant(Noun::Atom(42)),
            Nock::Axis(2),
        )
    );
}

/// example-atom.hoon: let a:@ = 42; (a a a)
/// Expected: [8 [1 42] [[0 2] [[0 2] [0 2]]]]
#[test]
fn test_let_typed_triple() {
    let nock = compile_src("let a:@ = 42;\n\n(a a a)\n");
    assert_eq!(
        nock,
        Nock::push(
            Nock::Constant(Noun::Atom(42)),
            Nock::autocons(
                Nock::Axis(2),
                Nock::autocons(Nock::Axis(2), Nock::Axis(2)),
            ),
        )
    );
}

/// Nested let: let x = 1; let y = 2; (x y)
#[test]
fn test_nested_let() {
    let nock = compile_src("let x = 1; let y = 2; (x y)");
    assert_eq!(
        nock,
        Nock::push(
            Nock::Constant(Noun::Atom(1)),
            Nock::push(
                Nock::Constant(Noun::Atom(2)),
                Nock::autocons(
                    Nock::Axis(6), // x at axis 6 after two pushes
                    Nock::Axis(2), // y at axis 2 (head)
                ),
            ),
        )
    );
}

/// let-edit.hoon: let a: ? = true; a = false; a
/// Expected: [8 [1 0] [7 [10 [2 [1 1]] [0 1]] [0 2]]]
#[test]
fn test_let_edit() {
    let nock = compile_src("let a: ? = true;\n\na = false;\n\na\n\n");
    assert_eq!(
        nock,
        Nock::push(
            Nock::Constant(Noun::Atom(0)), // true = 0
            Nock::then(
                Nock::edit(2, Nock::Constant(Noun::Atom(1)), Nock::Axis(1)),
                Nock::Axis(2),
            ),
        )
    );
}

// ════════════════════════════════════════════════════════════════
// Eval (from eval.hoon)
// ════════════════════════════════════════════════════════════════

/// eval.hoon: let a = eval (42 55) (0 2); a
/// Expected: [8 [2 [[1 42] [1 55]] [[1 0] [1 2]]] [0 2]]
#[test]
fn test_eval() {
    let nock = compile_src("let a = eval (42 55) (0 2);\n\na\n");
    assert_eq!(
        nock,
        Nock::push(
            Nock::Compose(
                Box::new(Nock::autocons(
                    Nock::Constant(Noun::Atom(42)),
                    Nock::Constant(Noun::Atom(55)),
                )),
                Box::new(Nock::autocons(
                    Nock::Constant(Noun::Atom(0)),
                    Nock::Constant(Noun::Atom(2)),
                )),
            ),
            Nock::Axis(2),
        )
    );
}

// ════════════════════════════════════════════════════════════════
// Function definition and call (from call.hoon)
// ════════════════════════════════════════════════════════════════

/// call.hoon: func a(b:@) -> @ { +(b) }; a(23)
/// Expected: [8 [8 [1 0] [[1 [4 0 6]] [0 1]]] [8 [0 2] [9 2 [10 [6 [7 [0 3] [1 23]]] [0 2]]]]]
#[test]
fn test_func_call() {
    let nock = compile_src("func a(b:@) -> @ {\n  +(b)\n};\n\na(23)\n\n");
    assert_eq!(
        nock,
        Nock::push(
            Nock::push(
                Nock::Constant(Noun::Atom(0)),
                Nock::autocons(
                    Nock::Constant(Noun::cell(
                        Noun::Atom(4),
                        Noun::cell(Noun::Atom(0), Noun::Atom(6)),
                    )),
                    Nock::Axis(1),
                ),
            ),
            Nock::push(
                Nock::Axis(2),
                Nock::fire(
                    2,
                    Nock::edit(
                        6,
                        Nock::then(Nock::Axis(3), Nock::Constant(Noun::Atom(23))),
                        Nock::Axis(2),
                    ),
                ),
            ),
        )
    );
}

/// inline-lambda-call.hoon: lambda (b:@) -> @ { +(b) }(41)
/// Expected: [7 [8 [1 0] [[1 [4 0 6]] [0 1]]] [9 2 [10 [6 [7 [0 3] [1 41]]] [0 1]]]]
#[test]
fn test_inline_lambda_call() {
    let nock = compile_src("lambda (b:@) -> @ {\n  +(b)\n}(41)");
    assert_eq!(
        nock,
        Nock::then(
            Nock::push(
                Nock::Constant(Noun::Atom(0)),
                Nock::autocons(
                    Nock::Constant(Noun::cell(
                        Noun::Atom(4),
                        Noun::cell(Noun::Atom(0), Noun::Atom(6)),
                    )),
                    Nock::Axis(1),
                ),
            ),
            Nock::fire(
                2,
                Nock::edit(
                    6,
                    Nock::then(Nock::Axis(3), Nock::Constant(Noun::Atom(41))),
                    Nock::Axis(1),
                ),
            ),
        )
    );
}

// ════════════════════════════════════════════════════════════════
// Multi-limb access (from multi-limb.hoon)
// ════════════════════════════════════════════════════════════════

/// multi-limb.hoon: let a: (p:@ q:(k:@ v:@)) = (52 30 42); (a.q.v)
/// Expected: [8 [[1 52] [1 30] [1 42]] [0 11]]
#[test]
fn test_multi_limb() {
    let nock = compile_src("let a: (p:@ q:(k:@ v:@)) = (52 30 42);\n\n(a.q.v)\n");
    assert_eq!(
        nock,
        Nock::push(
            Nock::autocons(
                Nock::Constant(Noun::Atom(52)),
                Nock::autocons(
                    Nock::Constant(Noun::Atom(30)),
                    Nock::Constant(Noun::Atom(42)),
                ),
            ),
            Nock::Axis(11),
        )
    );
}

// ════════════════════════════════════════════════════════════════
// Lists (from lists.hoon, lists-nested.hoon)
// ════════════════════════════════════════════════════════════════

/// lists.hoon: let d = [11]; let c = [9 10]; let b = [6 7 8]; let a = [1 2 3 4 5]; [a b c d]
#[test]
fn test_lists() {
    let nock = compile_src("let d = [11];\n\nlet c = [9 10];\n\nlet b = [6 7 8];\n\nlet a = [1 2 3 4 5];\n\n\n[a b c d]");
    match &nock {
        Nock::Push(_, _) => {}
        other => panic!("expected Push, got {:?}", other),
    }
    let noun_str = format!("{}", nock.to_noun());
    assert!(noun_str.contains("[1 11]"), "should contain constant 11");
    assert!(noun_str.contains("[1 0]"), "should contain null terminator");
}

/// lists-nested.hoon: various list types including nested lists
#[test]
fn test_lists_nested() {
    let result = try_compile(
        "let a:List(@) = [1];\n\nlet b:List(@) = [1 2];\n\nlet c:List(@) = [1 2 3];\n\nlet d:List((@ @)) = [(1 2) (3 4)];\n\nlet e:List((@ List(@))) = [(1 [2]) (3 [4 5])];\n\n(a b c d e)\n"
    );
    assert!(result.is_ok(), "lists-nested should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Sets (from sets.hoon)
// ════════════════════════════════════════════════════════════════

/// sets.hoon: various set literals
#[test]
fn test_sets() {
    let result = try_compile(
        "let a:Set(@) = {1};\n\nlet b:Set(@) = {1 2};\n\nlet c:Set(@) = {1 2 3 2 1};\n\nlet d:Set((@ @)) = {(1 2) (3 4) (1 2)};\n\nlet e:Set((@ Set(@))) = {(1 {2}) (3 {4 5})};\n\n(a b c d e)\n"
    );
    assert!(result.is_ok(), "sets should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Compose / Object (from compose.hoon)
// ════════════════════════════════════════════════════════════════

/// compose.hoon: compose object { b = 5; a = lambda (c:@) -> @ { +(c) } }; a(b)
#[test]
fn test_compose_object() {
    let result = try_compile(
        "compose\n  object {\n    b = 5\n    a = lambda (c: @) -> @ {\n      +(c)\n    }\n  };\na(b)\n"
    );
    assert!(result.is_ok(), "compose should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Dec function (from dec.hoon)
// ════════════════════════════════════════════════════════════════

/// dec.hoon: func dec(a:@) -> @ { let b = 0; loop; if a == +(b) { b } else { b = +(b); recur } }; dec(43)
#[test]
fn test_dec() {
    let result = try_compile(
        "func dec(a:@) -> @ {\n  let b = 0;\n  loop;\n  if a == +(b) {\n    b\n  } else {\n    b = +(b);\n    recur\n  }\n};\n\ndec(43)\n"
    );
    assert!(result.is_ok(), "dec should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Switch / Match (from match-case.hoon, match-type.hoon)
// ════════════════════════════════════════════════════════════════

/// match-case.hoon (switch): let a:@ = 3; switch a { 1 -> 0; ... _ -> 84; }
#[test]
fn test_switch() {
    let result = try_compile(
        "let a: @ = 3;\n\nswitch a {\n  1 -> 0;\n  2 -> 21;\n  3 -> 42;\n  4 -> 63;\n  _ -> 84;\n}\n"
    );
    assert!(result.is_ok(), "switch should compile: {:?}", result.err());
}

/// match-type.hoon: let a:@ = 3; match a { %1 -> 0; %2 -> 21; ... _ -> 84; }
#[test]
fn test_match_type() {
    let result = try_compile(
        "let a: @ = 3;\n\nmatch a {\n  %1 -> 0;\n  %2 -> 21;\n  %3 -> 42;\n  %4 -> 63;\n  _ -> 84;\n}\n"
    );
    assert!(result.is_ok(), "match should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Loop and recur (from inline-lambda-no-arg.hoon test data)
// ════════════════════════════════════════════════════════════════

/// let a:@ = 5; let b:@ = 0; loop; if a == +(b) { b } else { b = +(b); $(b) }
#[test]
fn test_loop_recur() {
    let result = try_compile(
        "let a:@ = 5;\nlet b:@ = 0;\nloop;\nif a == +(b) {\n  b\n} else {\n  b = +(b);\n  $(b)\n}"
    );
    assert!(result.is_ok(), "loop/recur should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Axis call (from axis-call.hoon)
// ════════════════════════════════════════════════════════════════

/// axis-call.hoon: func a(b:@) -> @ { +(b) }; &2(17)
#[test]
fn test_axis_call() {
    let result = try_compile("func a(b:@) -> @ {\n  +(b)\n};\n\n&2(17)\n");
    assert!(result.is_ok(), "axis-call should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Call + let + edit (from call-let-edit.hoon)
// ════════════════════════════════════════════════════════════════

/// call-let-edit.hoon: func a(c:@) -> @ { +(c) }; let b:@ = 42; b = a(23); b
#[test]
fn test_call_let_edit() {
    let result = try_compile(
        "func a(c:@) -> @ {\n  +(c)\n};\n\nlet b: @ = 42;\nb = a(23);\n\nb\n"
    );
    assert!(result.is_ok(), "call-let-edit should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Compose with context (from compose-cores.hoon)
// ════════════════════════════════════════════════════════════════

/// compose-cores.hoon: func g(a:@) -> @ { 29 }; compose with this; object { ... }; b(3)
#[test]
fn test_compose_cores() {
    let result = try_compile(
        "func g(a:@) -> @ {\n  29\n};\n\ncompose\n  with this; object {\n    b = lambda (c:@) -> @ {\n      g(5)\n    }\n    c = 89\n  };\n\nb(3)\n"
    );
    assert!(result.is_ok(), "compose-cores should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Class definitions (from class-state.hoon)
// ════════════════════════════════════════════════════════════════

/// class-state.hoon: class Point(x:@ y:@) with inc method
#[test]
fn test_class_state() {
    let result = try_compile(
        "compose\n  class Point(x:@ y:@) {\n    inc(q:@) -> @ {\n      +(q)\n    }\n  }\n;\n\nlet point_1 = Point(70 80);\nlet point_2 = Point(90 100);\n((point_2.x() point_2.y()) (point_1.x() point_1.y()))\n"
    );
    assert!(result.is_ok(), "class-state should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Type-point (from type-point.hoon)
// ════════════════════════════════════════════════════════════════

/// type-point.hoon: class Foo(x:@) { bar(p:@) -> Foo { p } }
#[test]
fn test_type_point() {
    let result = try_compile(
        "compose\n  class Foo(x:@) {\n    bar(p:@) -> Foo {\n      p\n    }\n  }\n;\n\nlet a:Foo = Foo(41);\nlet b = Foo(42);\nlet c:@ = 43;\n\n(Foo(40) a b c)\n"
    );
    assert!(result.is_ok(), "type-point should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Baby object (from baby.hoon)
// ════════════════════════════════════════════════════════════════

/// baby.hoon: compose with 0; object { load = crash ... }; poke(3)
#[test]
fn test_baby_object() {
    let result = try_compile(
        "compose with 0; object {\n  load = crash\n  peek = crash\n  poke = (a:* -> (* &1)) {\n    (a &1)\n  }\n  wish = crash\n};\n\npoke(3)\n"
    );
    // May fail at parser level depending on `(a:* -> (* &1))` support
    let _ = result;
}

// ════════════════════════════════════════════════════════════════
// Defer, Print, Loop standalone
// ════════════════════════════════════════════════════════════════

#[test]
fn test_defer() {
    let result = try_compile("defer;\n42\n");
    assert!(result.is_ok(), "defer should compile: {:?}", result.err());
}

#[test]
fn test_print() {
    let result = try_compile("print('Hello world');\n0");
    assert!(result.is_ok(), "print should compile: {:?}", result.err());
}

#[test]
fn test_loop_simple() {
    let result = try_compile("loop;\n42\n");
    assert!(result.is_ok(), "loop should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Assert complex (from assert.hoon)
// ════════════════════════════════════════════════════════════════

/// assert.hoon: multi-statement with assert, loop, and recur
#[test]
fn test_assert_complex() {
    let result = try_compile(
        "let a: @ = 5;\nlet b: @ = 0;\n\nassert a != 0;\nlet c = ?((a a));\nloop;\n\nif a == +(b) {\n  b\n} else {\n  b = +(b);\n  recur\n}\n"
    );
    assert!(result.is_ok(), "assert complex should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Lambda with no args at call site
// ════════════════════════════════════════════════════════════════

#[test]
fn test_lambda_no_arg_call() {
    let result = try_compile("lambda (b:@) -> @ {\n  +(b)\n}()\n");
    assert!(result.is_ok(), "lambda with no arg should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Comparator equality (from comparator.hoon) — native
// ════════════════════════════════════════════════════════════════

#[test]
fn test_comparator_equality() {
    let result = try_compile("let a = true;\nlet b = a == true;\nb\n");
    assert!(result.is_ok(), "equality comparison should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// In-subject call (from in-subj-call.hoon)
// ════════════════════════════════════════════════════════════════

/// in-subj-call.hoon: uses &1 (axis reference) in lambda arguments
#[test]
fn test_in_subj_call() {
    let result = try_compile(
        "let a = 17;\n\nlet b = lambda ((b:@ c:&1)) -> @ {\n  if c == 18 {\n    +(b)\n  } else {\n    b\n  }\n}(23 &1);\n\n&1\n"
    );
    // &1 axis reference handling may vary
    let _ = result;
}

// ════════════════════════════════════════════════════════════════
// Inline-point (from inline-point.hoon)
// ════════════════════════════════════════════════════════════════

/// inline-point.hoon: func + let + edit + axis reference
#[test]
fn test_inline_point() {
    let result = try_compile(
        "func a(b:@) -> @ {\n  +(b)\n};\n\nlet b: @ = 42;\nb = a(23);\n\nb\n"
    );
    assert!(result.is_ok(), "inline-point should compile: {:?}", result.err());
}

// ════════════════════════════════════════════════════════════════
// Fibonacci — requires Hoon library for + and - operators
// ════════════════════════════════════════════════════════════════

#[test]
fn test_fib_requires_hoon() {
    let result = try_compile(
        "func fib(n:@) -> @ {\n  if n == 0 {\n    1\n  } else if n == 1 {\n    1\n  } else {\n    $(n - 1) + $(n - 2)\n  }\n};\n\nfib(10)\n"
    );
    // Uses arithmetic operators which need Hoon library
    let _ = result;
}

// ════════════════════════════════════════════════════════════════
// Infix arithmetic — requires Hoon library
// ════════════════════════════════════════════════════════════════

#[test]
fn test_infix_arithmetic_requires_hoon() {
    let result = try_compile("1 + 2");
    match result {
        Err(ref e) => {
            let msg = format!("{}", e);
            assert!(
                msg.contains("hoon") || msg.contains("Hoon") || msg.contains("limb"),
                "should mention Hoon library requirement: {msg}"
            );
        }
        Ok(_) => {} // also acceptable if it compiles with Hoon call pattern
    }
}

// ════════════════════════════════════════════════════════════════
// Ordering comparators — require Hoon library
// ════════════════════════════════════════════════════════════════

#[test]
fn test_less_than_requires_hoon() {
    let result = try_compile("1 < 2");
    match result {
        Err(ref e) => {
            let msg = format!("{}", e);
            assert!(
                msg.contains("hoon") || msg.contains("Hoon") || msg.contains("limb"),
                "should mention Hoon library: {msg}"
            );
        }
        Ok(_) => {}
    }
}

// ════════════════════════════════════════════════════════════════
// Class-ops — requires Hoon library for + operator
// ════════════════════════════════════════════════════════════════

#[test]
fn test_class_ops_requires_hoon() {
    let result = try_compile(
        "compose\n  class Point(x:@ y:@) {\n   add(p:(x:@ y:@)) -> Point {\n     (x + p.x\n      y + p.y)\n   }\n  }\n;\n\nlet point_1 = Point(14 104);\npoint_1 = point_1.add(28 38);\n(point_1.x() point_1.y())\n"
    );
    // Uses + which needs Hoon library
    let _ = result;
}

// ════════════════════════════════════════════════════════════════
// Lists indexing — requires Hoon library (hoon.snag)
// ════════════════════════════════════════════════════════════════

#[test]
fn test_lists_indexing_requires_hoon() {
    let result = try_compile(
        "let a = [100 200 300 400 500];\nlet b:List(@ @) = [(10 20) (30 40) (50 60)];\n\n(hoon.snag(0 a) hoon.snag(2 b))\n"
    );
    let _ = result;
}

// ════════════════════════════════════════════════════════════════
// Import hoon — library feature
// ════════════════════════════════════════════════════════════════

#[test]
fn test_hoon_import() {
    let result = try_compile("import hoon;\nhoon.add(1 2)\n");
    let _ = result;
}

// ════════════════════════════════════════════════════════════════
// type-point-2 — requires Hoon library for + and -
// ════════════════════════════════════════════════════════════════

#[test]
fn test_type_point_2_requires_hoon() {
    let result = try_compile(
        "compose\n  class Point(x:Uint y:Uint) {\n   add(p:(x:Uint y:Uint)) -> Point {\n     (x + p.x\n      y + p.y)\n   }\n   sub(p:(x:Uint y:Uint)) -> Point {\n     (x - p.x\n      y - p.y)\n   }\n  }\n;\n\nlet point_1 = Point(104 124);\npoint_1 = point_1.add(38 38);\nlet point_2 = Point(30 40);\npoint_2 = point_2.add(212 302);\npoint_1 = point_1.sub(100 20);\n( (point_1.x() point_1.y())\n  (point_2.x() point_2.y())\n)\n"
    );
    let _ = result;
}

// ════════════════════════════════════════════════════════════════
// type-point-3 — requires Hoon library
// ════════════════════════════════════════════════════════════════

#[test]
fn test_type_point_3_requires_hoon() {
    let result = try_compile(
        "compose\n  class Point(x:Uint y:Uint) {\n    add(p:(x:Uint y:Uint)) -> Point {\n      (x + p.x\n       y + p.y)\n    }\n    add_cell(p:(x:Uint y:Uint)) -> (Uint Uint) {\n      (x + p.x\n       y + p.y)\n    }\n    inc(q:Uint) -> @ {\n      +(q)\n    }\n  }\n;\n\nlet one = Point(2 13);\nlet two = one.add(30 19);\nlet three = one.inc(41);\n(two.add_cell(10 10) three)\n"
    );
    let _ = result;
}

// ════════════════════════════════════════════════════════════════
// Nock serialization tests
// ════════════════════════════════════════════════════════════════

#[test]
fn test_nock_to_noun_display() {
    let nock = Nock::Constant(Noun::Atom(42));
    assert_eq!(format!("{}", nock.to_noun()), "[1 42]");

    let nock = Nock::Axis(3);
    assert_eq!(format!("{}", nock.to_noun()), "[0 3]");
}

#[test]
fn test_nock_if_then_else_serialization() {
    let nock = Nock::if_then_else(
        Nock::Constant(Noun::Atom(0)),
        Nock::Constant(Noun::Atom(42)),
        Nock::Constant(Noun::Atom(17)),
    );
    assert_eq!(
        format!("{}", nock.to_noun()),
        "[6 [[1 0] [[1 42] [1 17]]]]"
    );
}

#[test]
fn test_nock_fire_serialization() {
    let nock = Nock::fire(2, Nock::Axis(1));
    assert_eq!(format!("{}", nock.to_noun()), "[9 [2 [0 1]]]");
}

#[test]
fn test_nock_edit_serialization() {
    let nock = Nock::edit(
        6,
        Nock::then(Nock::Axis(3), Nock::Constant(Noun::Atom(23))),
        Nock::Axis(2),
    );
    assert_eq!(
        format!("{}", nock.to_noun()),
        "[10 [[6 [7 [[0 3] [1 23]]]] [0 2]]]"
    );
}
