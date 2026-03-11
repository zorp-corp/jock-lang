use jock_tokenizer::{tokenize, AtomVariant, Jatom};

use crate::ast::*;
use crate::parse;

/// Helper: tokenize then parse a source string.
fn parse_src(src: &str) -> Jock {
    let tokens = tokenize(src).expect("tokenize failed");
    parse(tokens).expect("parse failed")
}

/// Helper: assert that source parses without error.
fn assert_parses(src: &str) {
    let tokens = tokenize(src).expect("tokenize failed");
    parse(tokens).expect("parse failed");
}

// ── Literal atoms ───────────────────────────────────────────────

#[test]
fn parse_number_literal() {
    let ast = parse_src("42");
    assert_eq!(
        ast,
        Jock::Atom(Jatom {
            variant: AtomVariant::Number(42),
            constant: false,
        })
    );
}

#[test]
fn parse_string_literal() {
    let ast = parse_src("'hello'");
    assert_eq!(
        ast,
        Jock::Atom(Jatom {
            variant: AtomVariant::String("hello".into()),
            constant: false,
        })
    );
}

#[test]
fn parse_loobean_true() {
    let ast = parse_src("true");
    assert_eq!(
        ast,
        Jock::Atom(Jatom {
            variant: AtomVariant::Loobean(true),
            constant: false,
        })
    );
}

#[test]
fn parse_hex_literal() {
    let ast = parse_src("0xff");
    assert_eq!(
        ast,
        Jock::Atom(Jatom {
            variant: AtomVariant::Hexadecimal(0xff),
            constant: false,
        })
    );
}

#[test]
fn parse_symbol_literal() {
    let ast = parse_src("%42");
    assert_eq!(
        ast,
        Jock::Atom(Jatom {
            variant: AtomVariant::Number(42),
            constant: true,
        })
    );
}

// ── Names / limbs ───────────────────────────────────────────────

#[test]
fn parse_simple_name() {
    let ast = parse_src("foo");
    assert_eq!(ast, Jock::Limb(vec![Jlimb::Name("foo".into())]));
}

#[test]
fn parse_type_name() {
    let ast = parse_src("Foo");
    assert_eq!(ast, Jock::Limb(vec![Jlimb::Type("Foo".into())]));
}

#[test]
fn parse_wing_chain() {
    let ast = parse_src("a.b.c");
    assert_eq!(
        ast,
        Jock::Limb(vec![
            Jlimb::Name("a".into()),
            Jlimb::Name("b".into()),
            Jlimb::Name("c".into()),
        ])
    );
}

// ── Let bindings ────────────────────────────────────────────────

#[test]
fn parse_let_simple() {
    // let a:@ = 42; a
    let ast = parse_src("let a:@ = 42; a");
    match &ast {
        Jock::Let { typ, val, next } => {
            assert_eq!(typ.name(), "a");
            assert!(matches!(**val, Jock::Atom(_)));
            assert!(matches!(**next, Jock::Limb(_)));
        }
        other => panic!("expected Let, got {:?}", other),
    }
}

#[test]
fn parse_let_untyped() {
    // let x = 10; x
    let ast = parse_src("let x = 10; x");
    assert!(matches!(ast, Jock::Let { .. }));
}

// ── example-atom.jock ───────────────────────────────────────────

#[test]
fn parse_example_atom() {
    // let a:@ = 42;\n\n(a a a)
    let ast = parse_src("let a:@ = 42;\n\n(a a a)");
    match &ast {
        Jock::Let { next, .. } => {
            // The next should be a Cell (tuple of 3 elements)
            assert!(matches!(**next, Jock::Cell { .. }));
        }
        other => panic!("expected Let, got {:?}", other),
    }
}

// ── Edit (variable mutation) ────────────────────────────────────

#[test]
fn parse_let_edit() {
    let ast = parse_src("let a: ? = true;\n\na = false;\n\na");
    match &ast {
        Jock::Let { next, .. } => {
            assert!(matches!(**next, Jock::Edit { .. }));
        }
        other => panic!("expected Let, got {:?}", other),
    }
}

// ── Increment ───────────────────────────────────────────────────

#[test]
fn parse_increment() {
    let ast = parse_src("+(0)");
    assert!(matches!(ast, Jock::Increment { .. }));
}

// ── Cell check ──────────────────────────────────────────────────

#[test]
fn parse_cell_check() {
    let ast = parse_src("?(42)");
    assert!(matches!(ast, Jock::CellCheck { .. }));
}

// ── Recur ($) ───────────────────────────────────────────────────

#[test]
fn parse_recur_no_arg() {
    let ast = parse_src("$");
    assert!(matches!(
        ast,
        Jock::Call {
            arg: None,
            ..
        }
    ));
}

#[test]
fn parse_recur_with_arg() {
    let ast = parse_src("$(42)");
    match &ast {
        Jock::Call { func, arg } => {
            assert!(matches!(**func, Jock::Limb(ref v) if matches!(v[0], Jlimb::Axis(0))));
            assert!(arg.is_some());
        }
        other => panic!("expected Call, got {:?}", other),
    }
}

// ── Lists ───────────────────────────────────────────────────────

#[test]
fn parse_list() {
    let ast = parse_src("[1 2 3]");
    match &ast {
        Jock::List { val, .. } => {
            // 3 user elements + null terminator = 4
            assert_eq!(val.len(), 4);
            // Last element should be Atom(Number(0))
            assert_eq!(
                val[3],
                Jock::Atom(Jatom {
                    variant: AtomVariant::Number(0),
                    constant: false,
                })
            );
        }
        other => panic!("expected List, got {:?}", other),
    }
}

// ── Sets ────────────────────────────────────────────────────────

#[test]
fn parse_set() {
    let ast = parse_src("{1 2 3}");
    match &ast {
        Jock::Set { val, .. } => {
            assert_eq!(val.len(), 3);
        }
        other => panic!("expected Set, got {:?}", other),
    }
}

// ── Tuples ──────────────────────────────────────────────────────

#[test]
fn parse_tuple() {
    let ast = parse_src("(1 2)");
    assert!(matches!(ast, Jock::Cell { .. }));
}

#[test]
fn parse_single_paren() {
    let ast = parse_src("(42)");
    // Single element in parens unwraps
    assert!(matches!(ast, Jock::Atom(_)));
}

// ── If/else ─────────────────────────────────────────────────────

#[test]
fn parse_if_else() {
    let ast = parse_src(
        "let a: @ = 3;\n\nif a == 3 {\n  42\n} else {\n  17\n}",
    );
    match &ast {
        Jock::Let { next, .. } => {
            assert!(matches!(**next, Jock::If { .. }));
        }
        other => panic!("expected Let, got {:?}", other),
    }
}

#[test]
fn parse_if_elseif_else() {
    assert_parses(
        "let a: @ = 3;\nif a == 1 {\n  0\n} else if a == 2 {\n  1\n} else {\n  2\n}",
    );
}

// ── Comparisons ─────────────────────────────────────────────────

#[test]
fn parse_compare_eq() {
    let ast = parse_src("1 == 1");
    match &ast {
        Jock::Compare { comp, .. } => assert_eq!(*comp, Comparator::Eq),
        other => panic!("expected Compare, got {:?}", other),
    }
}

#[test]
fn parse_compare_lt() {
    let ast = parse_src("1 < 2");
    match &ast {
        Jock::Compare { comp, .. } => assert_eq!(*comp, Comparator::Lt),
        other => panic!("expected Compare, got {:?}", other),
    }
}

#[test]
fn parse_compare_ne() {
    let ast = parse_src("1 != 2");
    match &ast {
        Jock::Compare { comp, .. } => assert_eq!(*comp, Comparator::Ne),
        other => panic!("expected Compare, got {:?}", other),
    }
}

// ── Arithmetic operators ────────────────────────────────────────

#[test]
fn parse_add() {
    let ast = parse_src("1 + 2");
    match &ast {
        Jock::Operator { op, .. } => assert_eq!(*op, Operator::Add),
        other => panic!("expected Operator, got {:?}", other),
    }
}

#[test]
fn parse_sub() {
    let ast = parse_src("5 - 3");
    match &ast {
        Jock::Operator { op, .. } => assert_eq!(*op, Operator::Sub),
        other => panic!("expected Operator, got {:?}", other),
    }
}

#[test]
fn parse_mul() {
    let ast = parse_src("2 * 3");
    match &ast {
        Jock::Operator { op, .. } => assert_eq!(*op, Operator::Mul),
        other => panic!("expected Operator, got {:?}", other),
    }
}

// ── Functions ───────────────────────────────────────────────────

#[test]
fn parse_func_def() {
    let ast = parse_src("func inc(n:@) -> @ { +(n) };\n\ninc(41)");
    match &ast {
        Jock::Func { next, .. } => {
            assert!(matches!(**next, Jock::Call { .. }));
        }
        other => panic!("expected Func, got {:?}", other),
    }
}

// ── Lambda ──────────────────────────────────────────────────────

#[test]
fn parse_lambda_call() {
    let ast = parse_src("lambda (b:@) -> @ {\n  +(b)\n}(41)");
    assert!(matches!(ast, Jock::Call { .. }));
}

#[test]
fn parse_lambda_no_arg_call() {
    let ast = parse_src("lambda (b:@) -> @ {\n  +(b)\n}()");
    assert!(matches!(ast, Jock::Call { .. }));
}

// ── This ────────────────────────────────────────────────────────

#[test]
fn parse_this() {
    let ast = parse_src("this");
    assert_eq!(ast, Jock::Limb(vec![Jlimb::Axis(1)]));
}

// ── Crash ───────────────────────────────────────────────────────

#[test]
fn parse_crash() {
    let ast = parse_src("crash");
    assert_eq!(ast, Jock::Crash);
}

// ── Compose ─────────────────────────────────────────────────────

#[test]
fn parse_compose() {
    assert_parses(
        "compose\n  object {\n    b = 5\n    a = lambda (c: @) -> @ {\n      +(c)\n    }\n  };\na(b)",
    );
}

// ── Match / Switch ──────────────────────────────────────────────

#[test]
fn parse_switch() {
    let ast = parse_src("let a: @ = 3;\n\nswitch a {\n  1 -> 0;\n  2 -> 21;\n  3 -> 42;\n  4 -> 63;\n  _ -> 84;\n}");
    match &ast {
        Jock::Let { next, .. } => {
            match &**next {
                Jock::Switch {
                    cases, default, ..
                } => {
                    assert_eq!(cases.len(), 4);
                    assert!(default.is_some());
                }
                other => panic!("expected Switch, got {:?}", other),
            }
        }
        other => panic!("expected Let, got {:?}", other),
    }
}

// ── Print ───────────────────────────────────────────────────────

#[test]
fn parse_print() {
    let ast = parse_src("print('Hello world');\n0");
    match &ast {
        Jock::Print { next, .. } => {
            assert!(matches!(**next, Jock::Atom(_)));
        }
        other => panic!("expected Print, got {:?}", other),
    }
}

// ── Assert ──────────────────────────────────────────────────────

#[test]
fn parse_assert() {
    let ast = parse_src("assert 1 == 1;\n42");
    match &ast {
        Jock::Assert { cond, then } => {
            assert!(matches!(**cond, Jock::Compare { .. }));
            assert!(matches!(**then, Jock::Atom(_)));
        }
        other => panic!("expected Assert, got {:?}", other),
    }
}

// ── Loop / Defer ────────────────────────────────────────────────

#[test]
fn parse_loop() {
    let ast = parse_src("loop;\n42");
    assert!(matches!(ast, Jock::Loop { .. }));
}

#[test]
fn parse_defer() {
    let ast = parse_src("defer;\n42");
    assert!(matches!(ast, Jock::Defer { .. }));
}

// ── Eval ────────────────────────────────────────────────────────

#[test]
fn parse_eval() {
    let ast = parse_src("let a = eval (42 55) (0 2);\n\na");
    match &ast {
        Jock::Let { val, .. } => {
            assert!(matches!(**val, Jock::Eval { .. }));
        }
        other => panic!("expected Let, got {:?}", other),
    }
}

// ── Full .jock file integration tests ───────────────────────────

#[test]
fn parse_hello_world() {
    assert_parses("print('Hello world');\n0");
}

#[test]
fn parse_fibonacci() {
    assert_parses(
        r#"func fib(n:@) -> @ {
  if n == 0 {
    1
  } else if n == 1 {
    1
  } else {
    $(n - 1) + $(n - 2)
  }
};

(
  fib(0)
  fib(1)
  fib(2)
  fib(3)
  fib(4)
  fib(5)
  fib(6)
  fib(7)
  fib(8)
  fib(9)
  fib(10)
)"#,
    );
}

#[test]
fn parse_lists_file() {
    assert_parses(
        "let d = [11];\n\nlet c = [9 10];\n\nlet b = [6 7 8];\n\nlet a = [1 2 3 4 5];\n\n\n[a b c d]",
    );
}

#[test]
fn parse_dec_function() {
    assert_parses(
        r#"func dec(a:@) -> @ {
  let b = 0;
  loop;
  if a == +(b) {
    b
  } else {
    b = +(b);
    recur
  }
};

dec(43)"#,
    );
}

#[test]
fn parse_infix_arithmetic() {
    assert_parses(
        r#"[ (41 + 5) - 4
  (126 * 2) / 6
  ((6 ** 2) + 6) % 100
  (2 ** 5) + 10
  1 + 2 + 39
  (50 - 9) + 1
]"#,
    );
}

#[test]
fn parse_infix_comparators() {
    assert_parses(
        r#"(
    1 < 0
    0 <= 1
    0 == 1
    1 > 0
    0 >= 0
    1 != 1
)"#,
    );
}

#[test]
fn parse_class_state() {
    assert_parses(
        r#"compose
  class Point(x:@ y:@) {
    inc(q:@) -> @ {
      +(q)
    }
  }
;

let point_1 = Point(70 80);
let point_2 = Point(90 100);
((point_2.x() point_2.y()) (point_1.x() point_1.y()))"#,
    );
}

#[test]
fn parse_inline_lambda_call() {
    assert_parses("lambda (b:@) -> @ {\n  +(b)\n}(41)");
}

#[test]
fn parse_compose_with_object() {
    assert_parses(
        r#"compose
  object {
    b = 5
    a = lambda (c: @) -> @ {
      +(c)
    }
  };
a(b)"#,
    );
}

#[test]
fn parse_sets_file() {
    assert_parses(
        r#"let a:Set(@) = {1};

let b:Set(@) = {1 2};

let c:Set(@) = {1 2 3 2 1};

let d:Set((@ @)) = {(1 2) (3 4) (1 2)};

let e:Set((@ Set(@))) = {(1 {2}) (3 {4 5})};

(a b c d e)"#,
    );
}

#[test]
fn parse_assert_file() {
    assert_parses(
        r#"let a: @ = 5;
let b: @ = 0;

assert a != 0;
let c = ?((a a));
loop;

if a == +(b) {
  b
} else {
  b = +(b);
  recur
}"#,
    );
}

// ── Missing .jock file tests ────────────────────────────────────

#[test]
fn parse_axis_call() {
    assert_parses(
        r#"func a(b:@) -> @ {
  +(b)
};

&2(17)"#,
    );
}

#[test]
fn parse_baby() {
    assert_parses(
        r#"compose with 0; object {
  load = crash
  peek = crash
  poke = (a:* -> (* &1)) {
    (a &1)
  }
  wish = crash
};

poke(3)"#,
    );
}

#[test]
fn parse_call() {
    let ast = parse_src(
        r#"func a(b:@) -> @ {
  +(b)
};

a(23)"#,
    );
    match &ast {
        Jock::Func { next, .. } => {
            assert!(matches!(**next, Jock::Call { .. }));
        }
        other => panic!("expected Func, got {:?}", other),
    }
}

#[test]
fn parse_call_let_edit() {
    assert_parses(
        r#"func a(c:@) -> @ {
  +(c)
};

let b: @ = 42;
b = a(23);

b"#,
    );
}

#[test]
fn parse_class_ops() {
    assert_parses(
        r#"compose
  class Point(x:@ y:@) {
   add(p:(x:@ y:@)) -> Point {
     (x + p.x
      y + p.y)
   }
  }
;

let point_1 = Point(14 104);
point_1 = point_1.add(28 38);
(point_1.x() point_1.y())"#,
    );
}

#[test]
fn parse_comparator_file() {
    assert_parses(
        r#"let a = true;
let b = a == true;
let c = a < 1;
let d = a > 2;
let e = b != true;
let f = a <= 1;
let g = a >= 2;

g"#,
    );
}

#[test]
fn parse_compose_cores() {
    assert_parses(
        r#"func g(a:@) -> @ {
  29
};

compose
  with this; object {
    b = lambda (c:@) -> @ {
      g(5)
    }
    c = 89
  };

b(3)"#,
    );
}

#[test]
fn parse_hoon_alias() {
    assert_parses(
        r#"import hoon as lib;

let a:@ = 6;
let b:@ = 7;

lib.mul(a b)"#,
    );
}

#[test]
fn parse_hoon_arithmetic() {
    assert_parses(
        r#"import hoon;

let a:@ = 5;
let b:@ = 37;

(
  hoon.dec(43)
  hoon.add(5 37)
  hoon.add(a b)
  hoon.sub(47 a)
  hoon.lent([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42])
)"#,
    );
}

#[test]
fn parse_hoon_ffi() {
    assert_parses(
        r#"let a = 1;
let b = 41;
let c = 43;
let d = 6;
let e = 7;
let f = 252;

(hoon.add(a b)
 hoon.sub(c a)
 hoon.mul(d e)
 hoon.div(f d)
)"#,
    );
}

#[test]
fn parse_if_elseif_else_file() {
    assert_parses(
        r#"let a: @ = 3;

if a == 3 {
  42
} else if a == 5 {
  17
} else {
  15
}"#,
    );
}

#[test]
fn parse_in_subj_call() {
    assert_parses(
        r#"let a = 17;

let b = lambda ((b:@ c:&1)) -> @ {
  if c == 18 {
    +(b)
  } else {
    b
  }
}(23 &1);

&1"#,
    );
}

#[test]
fn parse_inline_lambda_no_arg() {
    assert_parses(
        r#"lambda (b:@) -> @ {
  +(b)
}()"#,
    );
}

#[test]
fn parse_inline_point() {
    assert_parses(
        r#"let a: @ = 5;
let b: @ = 0;
loop;
if a == +(b) {
  b
} else {
  b = +(b);
  $(b)
}"#,
    );
}

#[test]
fn parse_let_inner_exp() {
    let ast = parse_src("let a = 42;\n\na");
    match &ast {
        Jock::Let { val, next, .. } => {
            assert!(matches!(**val, Jock::Atom(_)));
            assert!(matches!(**next, Jock::Limb(_)));
        }
        other => panic!("expected Let, got {:?}", other),
    }
}

#[test]
fn parse_lists_indexing() {
    assert_parses(
        r#"import hoon;

let a = [100 200 300 400 500];
let b:List(@ @) = [(10 20) (30 40) (50 60)];

(hoon.snag(0 a) hoon.snag(2 b))"#,
    );
}

#[test]
fn parse_lists_nested() {
    assert_parses(
        r#"let a:List(@) = [1];

let b:List(@) = [1 2];

let c:List(@) = [1 2 3];

let d:List((@ @)) = [(1 2) (3 4)];

let e:List((@ List(@))) = [(1 [2]) (3 [4 5])];

(a b c d e)"#,
    );
}

#[test]
fn parse_match_type() {
    let ast = parse_src(
        r#"let a: @ = 3;

match a {
  %1 -> 0;
  %2 -> 21;
  %3 -> 42;
  %4 -> 63;
  _ -> 84;
}"#,
    );
    match &ast {
        Jock::Let { next, .. } => {
            match &**next {
                Jock::Match {
                    cases, default, ..
                } => {
                    assert_eq!(cases.len(), 4);
                    assert!(default.is_some());
                }
                other => panic!("expected Match, got {:?}", other),
            }
        }
        other => panic!("expected Let, got {:?}", other),
    }
}

#[test]
fn parse_multi_limb() {
    assert_parses(
        r#"let a: (p:@ q:(k:@ v:@)) = (52 30 42);

(a.q.v)"#,
    );
}

#[test]
fn parse_type_point() {
    assert_parses(
        r#"compose
  class Foo(x:@) {
    bar(p:@) -> Foo {
      p
    }
  }
;

let a:Foo = Foo(41);
let b = Foo(42);
let c:@ = 43;

(Foo(40) a b c)"#,
    );
}

#[test]
fn parse_type_point_2() {
    assert_parses(
        r#"compose
  class Point(x:Uint y:Uint) {
   add(p:(x:Uint y:Uint)) -> Point {
     (x + p.x
      y + p.y)
   }
   sub(p:(x:Uint y:Uint)) -> Point {
     (x - p.x
      y - p.y)
   }
  }
;

let point_1 = Point(104 124);
point_1 = point_1.add(38 38);
let point_2 = Point(30 40);
point_2 = point_2.add(212 302);
point_1 = point_1.sub(100 20);
( (point_1.x() point_1.y())
  (point_2.x() point_2.y())
)"#,
    );
}

#[test]
fn parse_type_point_3() {
    assert_parses(
        r#"compose
  class Point(x:Uint y:Uint) {
    add(p:(x:Uint y:Uint)) -> Point {
      (x + p.x
       y + p.y)
    }
    add_cell(p:(x:Uint y:Uint)) -> (Uint Uint) {
      (x + p.x
       y + p.y)
    }
    inc(q:Uint) -> @ {
      +(q)
    }
  }
;

let one = Point(2 13);
let two = one.add(30 19);
let three = one.inc(41);
(two.add_cell(10 10) three)"#,
    );
}

// ── Error handling ──────────────────────────────────────────────

#[test]
fn error_on_empty_input() {
    let tokens = tokenize("").expect("tokenize failed");
    assert!(tokens.is_empty());
    let result = parse(tokens);
    assert!(result.is_err());
}

#[test]
fn error_on_reserved_type_class() {
    let tokens = tokenize("class List(x:@) {}").expect("tokenize failed");
    let result = parse(tokens);
    assert!(result.is_err());
}
