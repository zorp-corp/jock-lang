use crate::token::*;
use crate::{tokenize, ErrorKind};

fn kw(k: Keyword) -> Token {
    Token::Keyword(k)
}

fn punc(p: Jpunc) -> Token {
    Token::Punctuator(p)
}

fn name(s: &str) -> Token {
    Token::Name(s.to_string())
}

fn typ(s: &str) -> Token {
    Token::Type(s.to_string())
}

fn num(n: u64) -> Token {
    Token::Literal(Jatom {
        variant: AtomVariant::Number(n),
        constant: false,
    })
}

fn hex(n: u64) -> Token {
    Token::Literal(Jatom {
        variant: AtomVariant::Hexadecimal(n),
        constant: false,
    })
}

fn str_lit(s: &str) -> Token {
    Token::Literal(Jatom {
        variant: AtomVariant::String(s.to_string()),
        constant: false,
    })
}

fn bool_lit(b: bool) -> Token {
    Token::Literal(Jatom {
        variant: AtomVariant::Loobean(b),
        constant: false,
    })
}

fn const_num(n: u64) -> Token {
    Token::Literal(Jatom {
        variant: AtomVariant::Number(n),
        constant: true,
    })
}

fn const_str(s: &str) -> Token {
    Token::Literal(Jatom {
        variant: AtomVariant::String(s.to_string()),
        constant: true,
    })
}

fn const_bool(b: bool) -> Token {
    Token::Literal(Jatom {
        variant: AtomVariant::Loobean(b),
        constant: true,
    })
}

fn const_hex(n: u64) -> Token {
    Token::Literal(Jatom {
        variant: AtomVariant::Hexadecimal(n),
        constant: true,
    })
}

// ---------------------------------------------------------------
// Basic token recognition
// ---------------------------------------------------------------

#[test]
fn empty_input() {
    assert_eq!(tokenize("").unwrap(), vec![]);
}

#[test]
fn whitespace_only() {
    assert_eq!(tokenize("  \t\n  ").unwrap(), vec![]);
}

#[test]
fn single_number() {
    assert_eq!(tokenize("42").unwrap(), vec![num(42)]);
}

#[test]
fn single_zero() {
    assert_eq!(tokenize("0").unwrap(), vec![num(0)]);
}

#[test]
fn single_string() {
    assert_eq!(tokenize("'hello'").unwrap(), vec![str_lit("hello")]);
}

#[test]
fn empty_string() {
    assert_eq!(tokenize("''").unwrap(), vec![str_lit("")]);
}

#[test]
fn boolean_true() {
    assert_eq!(tokenize("true").unwrap(), vec![bool_lit(true)]);
}

#[test]
fn boolean_false() {
    assert_eq!(tokenize("false").unwrap(), vec![bool_lit(false)]);
}

#[test]
fn hex_literal() {
    assert_eq!(tokenize("0xff").unwrap(), vec![hex(0xff)]);
}

#[test]
fn hex_uppercase() {
    assert_eq!(tokenize("0xAB").unwrap(), vec![hex(0xAB)]);
}

#[test]
fn hex_mixed_case() {
    assert_eq!(tokenize("0xDeAdBeEf").unwrap(), vec![hex(0xDEADBEEF)]);
}

// ---------------------------------------------------------------
// Keywords
// ---------------------------------------------------------------

#[test]
fn all_keywords() {
    for &(kw_val, kw_str) in KEYWORDS {
        let result = tokenize(kw_str).unwrap();
        assert_eq!(result, vec![kw(kw_val)], "keyword: {kw_str}");
    }
}

#[test]
fn keyword_boundary_prevents_partial_match() {
    // `letter` should NOT be keyword `let` + name `ter`
    assert_eq!(tokenize("letter").unwrap(), vec![name("letter")]);
}

#[test]
fn keyword_boundary_with_digits() {
    // `if2` should be name, not keyword `if` + number `2`
    assert_eq!(tokenize("if2").unwrap(), vec![name("if2")]);
}

#[test]
fn keyword_followed_by_punctuator() {
    // `-` is not an identifier char, so `let` matches as keyword.
    assert_eq!(
        tokenize("let-x").unwrap(),
        vec![kw(Keyword::Let), punc(Jpunc::Minus), name("x")]
    );
}

#[test]
fn keyword_assert_vs_as() {
    // `assert` should match as keyword `assert`, not `as` + name `sert`
    assert_eq!(tokenize("assert").unwrap(), vec![kw(Keyword::Assert)]);
}

#[test]
fn keyword_as_standalone() {
    assert_eq!(tokenize("as").unwrap(), vec![kw(Keyword::As)]);
}

// ---------------------------------------------------------------
// Punctuators
// ---------------------------------------------------------------

#[test]
fn all_single_punctuators() {
    let cases = [
        ('.', Jpunc::Dot),
        (';', Jpunc::Semicolon),
        (',', Jpunc::Comma),
        (':', Jpunc::Colon),
        ('&', Jpunc::Ampersand),
        ('$', Jpunc::Dollar),
        ('@', Jpunc::At),
        ('?', Jpunc::Question),
        ('!', Jpunc::Bang),
        ('(', Jpunc::LParen),
        (')', Jpunc::RParen),
        ('{', Jpunc::LBrace),
        ('}', Jpunc::RBrace),
        ('[', Jpunc::LBracket),
        (']', Jpunc::RBracket),
        ('=', Jpunc::Equals),
        ('<', Jpunc::LessThan),
        ('>', Jpunc::GreaterThan),
        ('#', Jpunc::Hash),
        ('+', Jpunc::Plus),
        ('-', Jpunc::Minus),
        ('*', Jpunc::Star),
        ('/', Jpunc::Slash),
        ('%', Jpunc::Percent),
        ('_', Jpunc::Underscore),
    ];
    for (ch, expected) in cases {
        let input = String::from(ch);
        let result = tokenize(&input).unwrap();
        assert_eq!(result, vec![punc(expected)], "punctuator: {ch}");
    }
}

// ---------------------------------------------------------------
// Names and Types
// ---------------------------------------------------------------

#[test]
fn simple_name() {
    assert_eq!(tokenize("foo").unwrap(), vec![name("foo")]);
}

#[test]
fn name_with_underscore() {
    assert_eq!(tokenize("foo_bar").unwrap(), vec![name("foo_bar")]);
}

#[test]
fn name_with_digits() {
    assert_eq!(tokenize("x1").unwrap(), vec![name("x1")]);
}

#[test]
fn name_no_uppercase() {
    // Names only contain [a-z0-9_], so `fooBar` is name `foo` + type `Bar`
    assert_eq!(
        tokenize("fooBar").unwrap(),
        vec![name("foo"), typ("Bar")]
    );
}

#[test]
fn simple_type() {
    assert_eq!(tokenize("Foo").unwrap(), vec![typ("Foo")]);
}

#[test]
fn single_uppercase_type() {
    assert_eq!(tokenize("F").unwrap(), vec![typ("F")]);
}

#[test]
fn type_no_digits() {
    // Types are [A-Z][a-z]*, so `Foo123` is type `Foo` + number `123`
    assert_eq!(
        tokenize("Foo123").unwrap(),
        vec![typ("Foo"), num(123)]
    );
}

#[test]
fn type_no_uppercase_continuation() {
    // `FOO` is type `F` + type `O` + type `O` (uppercase is not in [a-z])
    // Wait — `O` starts with uppercase, so it's a Type. Each uppercase letter
    // followed by no lowercase is a single-char Type.
    assert_eq!(
        tokenize("FOO").unwrap(),
        vec![typ("F"), typ("O"), typ("O")]
    );
}

// ---------------------------------------------------------------
// Symbol literals (% prefix)
// ---------------------------------------------------------------

#[test]
fn symbol_number() {
    assert_eq!(tokenize("%42").unwrap(), vec![const_num(42)]);
}

#[test]
fn symbol_string() {
    assert_eq!(tokenize("%'hello'").unwrap(), vec![const_str("hello")]);
}

#[test]
fn symbol_boolean() {
    assert_eq!(tokenize("%true").unwrap(), vec![const_bool(true)]);
}

#[test]
fn symbol_hex() {
    assert_eq!(tokenize("%0xff").unwrap(), vec![const_hex(0xff)]);
}

#[test]
fn percent_alone_is_punctuator() {
    // `%` not followed by a valid literal is a punctuator
    assert_eq!(
        tokenize("% 42").unwrap(),
        vec![punc(Jpunc::Percent), num(42)]
    );
}

// ---------------------------------------------------------------
// Function call pseudo-punctuator ((
// ---------------------------------------------------------------

#[test]
fn name_paren_becomes_double_paren() {
    assert_eq!(
        tokenize("foo(bar)").unwrap(),
        vec![
            name("foo"),
            punc(Jpunc::DoubleParen),
            name("bar"),
            punc(Jpunc::RParen),
        ]
    );
}

#[test]
fn type_paren_becomes_double_paren() {
    assert_eq!(
        tokenize("Foo(42)").unwrap(),
        vec![
            typ("Foo"),
            punc(Jpunc::DoubleParen),
            num(42),
            punc(Jpunc::RParen),
        ]
    );
}

#[test]
fn fun_flag_persists_across_whitespace() {
    // After name `foo`, fun=true. Whitespace is consumed between tokens.
    // Then `(` is encountered with fun=true → DoubleParen.
    assert_eq!(
        tokenize("foo (bar)").unwrap(),
        vec![
            name("foo"),
            punc(Jpunc::DoubleParen),
            name("bar"),
            punc(Jpunc::RParen),
        ]
    );
}

#[test]
fn fun_flag_false_after_literal() {
    // After number literal, fun=false, so `(` stays as LParen
    assert_eq!(
        tokenize("42(bar)").unwrap(),
        vec![
            num(42),
            punc(Jpunc::LParen),
            name("bar"),
            punc(Jpunc::RParen),
        ]
    );
}

#[test]
fn fun_flag_false_after_keyword() {
    // After keyword `lambda`, fun=false, so `(` stays as LParen
    assert_eq!(
        tokenize("lambda (c)").unwrap(),
        vec![
            kw(Keyword::Lambda),
            punc(Jpunc::LParen),
            name("c"),
            punc(Jpunc::RParen),
        ]
    );
}

#[test]
fn fun_flag_false_after_punctuator() {
    // After `+` punctuator, fun=false, so `(` is LParen
    assert_eq!(
        tokenize("+(b)").unwrap(),
        vec![
            punc(Jpunc::Plus),
            punc(Jpunc::LParen),
            name("b"),
            punc(Jpunc::RParen),
        ]
    );
}

// ---------------------------------------------------------------
// Comments
// ---------------------------------------------------------------

#[test]
fn line_comment() {
    assert_eq!(tokenize("// comment\n42").unwrap(), vec![num(42)]);
}

#[test]
fn block_comment() {
    assert_eq!(tokenize("/* block */ 42").unwrap(), vec![num(42)]);
}

#[test]
fn block_comment_multiline() {
    assert_eq!(
        tokenize("/* line1\nline2\nline3 */ 42").unwrap(),
        vec![num(42)]
    );
}

#[test]
fn only_block_comment() {
    assert_eq!(tokenize("/* comment */").unwrap(), vec![]);
}

#[test]
fn only_line_comment() {
    assert_eq!(tokenize("// comment\n").unwrap(), vec![]);
}

#[test]
fn multiple_comments() {
    assert_eq!(
        tokenize("// line1\n// line2\n42").unwrap(),
        vec![num(42)]
    );
}

// ---------------------------------------------------------------
// Boolean boundary behavior (jest — no boundary check)
// ---------------------------------------------------------------

#[test]
fn boolean_no_boundary_true() {
    // `trueblue` → boolean `true` then name `blue` (jest has no boundary check)
    assert_eq!(
        tokenize("trueblue").unwrap(),
        vec![bool_lit(true), name("blue")]
    );
}

#[test]
fn boolean_no_boundary_false() {
    // `falsehood` → boolean `false` then name("hood")
    assert_eq!(
        tokenize("falsehood").unwrap(),
        vec![bool_lit(false), name("hood")]
    );
}

// ---------------------------------------------------------------
// Hex backtracking
// ---------------------------------------------------------------

#[test]
fn zero_x_without_digits() {
    // `0x` without hex digits: hex fails, backtrack, `0` parses as number,
    // then `x` parses as name
    assert_eq!(
        tokenize("0x").unwrap(),
        vec![num(0), name("x")]
    );
}

// ---------------------------------------------------------------
// Error cases
// ---------------------------------------------------------------

#[test]
fn unterminated_string() {
    let err = tokenize("'hello").unwrap_err();
    assert_eq!(err.kind, ErrorKind::UnterminatedString);
}

#[test]
fn unterminated_block_comment() {
    let err = tokenize("/* unterminated").unwrap_err();
    assert_eq!(err.kind, ErrorKind::UnterminatedBlockComment);
}

// ---------------------------------------------------------------
// Full program tests (from Hoon test files)
// ---------------------------------------------------------------

/// example-atom.hoon: `let a:@ = 42;\n\n(a a a)\n`
#[test]
fn example_atom() {
    let input = "let a:@ = 42;\n\n(a a a)\n";
    let expected = vec![
        kw(Keyword::Let),
        name("a"),
        punc(Jpunc::Colon),
        punc(Jpunc::At),
        punc(Jpunc::Equals),
        num(42),
        punc(Jpunc::Semicolon),
        punc(Jpunc::LParen),
        name("a"),
        name("a"),
        name("a"),
        punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// call.hoon: `func a(b:@) -> @ {\n  +(b)\n};\n\na(23)\n\n`
#[test]
fn call() {
    let input = "func a(b:@) -> @ {\n  +(b)\n};\n\na(23)\n\n";
    let expected = vec![
        kw(Keyword::Func),
        name("a"),
        punc(Jpunc::DoubleParen),
        name("b"),
        punc(Jpunc::Colon),
        punc(Jpunc::At),
        punc(Jpunc::RParen),
        punc(Jpunc::Minus),
        punc(Jpunc::GreaterThan),
        punc(Jpunc::At),
        punc(Jpunc::LBrace),
        punc(Jpunc::Plus),
        punc(Jpunc::LParen),
        name("b"),
        punc(Jpunc::RParen),
        punc(Jpunc::RBrace),
        punc(Jpunc::Semicolon),
        name("a"),
        punc(Jpunc::DoubleParen),
        num(23),
        punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// match-case.hoon:
/// `let a: @ = 3;\n\nswitch a {\n  1 -> 0;\n  2 -> 21;\n  3 -> 42;\n  4 -> 63;\n  _ -> 84;\n}\n`
#[test]
fn match_case() {
    let input =
        "let a: @ = 3;\n\nswitch a {\n  1 -> 0;\n  2 -> 21;\n  3 -> 42;\n  4 -> 63;\n  _ -> 84;\n}\n";
    let expected = vec![
        kw(Keyword::Let),
        name("a"),
        punc(Jpunc::Colon),
        punc(Jpunc::At),
        punc(Jpunc::Equals),
        num(3),
        punc(Jpunc::Semicolon),
        kw(Keyword::Switch),
        name("a"),
        punc(Jpunc::LBrace),
        num(1),
        punc(Jpunc::Minus),
        punc(Jpunc::GreaterThan),
        num(0),
        punc(Jpunc::Semicolon),
        num(2),
        punc(Jpunc::Minus),
        punc(Jpunc::GreaterThan),
        num(21),
        punc(Jpunc::Semicolon),
        num(3),
        punc(Jpunc::Minus),
        punc(Jpunc::GreaterThan),
        num(42),
        punc(Jpunc::Semicolon),
        num(4),
        punc(Jpunc::Minus),
        punc(Jpunc::GreaterThan),
        num(63),
        punc(Jpunc::Semicolon),
        punc(Jpunc::Underscore),
        punc(Jpunc::Minus),
        punc(Jpunc::GreaterThan),
        num(84),
        punc(Jpunc::Semicolon),
        punc(Jpunc::RBrace),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// compose.hoon: compose with object, lambda, and block comment
#[test]
fn compose() {
    let input = "compose\n  object {\n    b = 5\n    a = lambda (c: @) -> @ {\n      +(c)\n    }\n  };\na(b)\n\n/*\n=>\n  |%\n  ++  b  5\n  ++  a  |=(c=@ +(c))\n  --\n(a b)\n\n[7 [1 [1 5] 8 [1 0] [1 4 0 6] 0 1] 8 [9 3 0 1] 9 2 10 [6 7 [0 3] 9 2 0 1] 0 2]\n*/\n";
    let expected = vec![
        kw(Keyword::Compose),
        kw(Keyword::Object),
        punc(Jpunc::LBrace),
        name("b"),
        punc(Jpunc::Equals),
        num(5),
        name("a"),
        punc(Jpunc::Equals),
        kw(Keyword::Lambda),
        punc(Jpunc::LParen),
        name("c"),
        punc(Jpunc::Colon),
        punc(Jpunc::At),
        punc(Jpunc::RParen),
        punc(Jpunc::Minus),
        punc(Jpunc::GreaterThan),
        punc(Jpunc::At),
        punc(Jpunc::LBrace),
        punc(Jpunc::Plus),
        punc(Jpunc::LParen),
        name("c"),
        punc(Jpunc::RParen),
        punc(Jpunc::RBrace),
        punc(Jpunc::RBrace),
        punc(Jpunc::Semicolon),
        name("a"),
        punc(Jpunc::DoubleParen),
        name("b"),
        punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// fib.hoon
#[test]
fn fib() {
    let input = "// fibonacci\n\nfunc fib(n:@) -> @ {\n  if n == 0 {\n    1\n  } else if n == 1 {\n    1\n  } else {\n    $(n - 1) + $(n - 2)\n  }\n};\n\n(\n  fib(0)\n  fib(1)\n  fib(2)\n  fib(3)\n  fib(4)\n  fib(5)\n  fib(6)\n  fib(7)\n  fib(8)\n  fib(9)\n  fib(10)\n)\n";
    let expected = vec![
        kw(Keyword::Func),
        name("fib"),
        punc(Jpunc::DoubleParen),
        name("n"),
        punc(Jpunc::Colon),
        punc(Jpunc::At),
        punc(Jpunc::RParen),
        punc(Jpunc::Minus),
        punc(Jpunc::GreaterThan),
        punc(Jpunc::At),
        punc(Jpunc::LBrace),
        kw(Keyword::If),
        name("n"),
        punc(Jpunc::Equals),
        punc(Jpunc::Equals),
        num(0),
        punc(Jpunc::LBrace),
        num(1),
        punc(Jpunc::RBrace),
        kw(Keyword::Else),
        kw(Keyword::If),
        name("n"),
        punc(Jpunc::Equals),
        punc(Jpunc::Equals),
        num(1),
        punc(Jpunc::LBrace),
        num(1),
        punc(Jpunc::RBrace),
        kw(Keyword::Else),
        punc(Jpunc::LBrace),
        punc(Jpunc::Dollar),
        punc(Jpunc::LParen),
        name("n"),
        punc(Jpunc::Minus),
        num(1),
        punc(Jpunc::RParen),
        punc(Jpunc::Plus),
        punc(Jpunc::Dollar),
        punc(Jpunc::LParen),
        name("n"),
        punc(Jpunc::Minus),
        num(2),
        punc(Jpunc::RParen),
        punc(Jpunc::RBrace),
        punc(Jpunc::RBrace),
        punc(Jpunc::Semicolon),
        punc(Jpunc::LParen),
        name("fib"),
        punc(Jpunc::DoubleParen),
        num(0),
        punc(Jpunc::RParen),
        name("fib"),
        punc(Jpunc::DoubleParen),
        num(1),
        punc(Jpunc::RParen),
        name("fib"),
        punc(Jpunc::DoubleParen),
        num(2),
        punc(Jpunc::RParen),
        name("fib"),
        punc(Jpunc::DoubleParen),
        num(3),
        punc(Jpunc::RParen),
        name("fib"),
        punc(Jpunc::DoubleParen),
        num(4),
        punc(Jpunc::RParen),
        name("fib"),
        punc(Jpunc::DoubleParen),
        num(5),
        punc(Jpunc::RParen),
        name("fib"),
        punc(Jpunc::DoubleParen),
        num(6),
        punc(Jpunc::RParen),
        name("fib"),
        punc(Jpunc::DoubleParen),
        num(7),
        punc(Jpunc::RParen),
        name("fib"),
        punc(Jpunc::DoubleParen),
        num(8),
        punc(Jpunc::RParen),
        name("fib"),
        punc(Jpunc::DoubleParen),
        num(9),
        punc(Jpunc::RParen),
        name("fib"),
        punc(Jpunc::DoubleParen),
        num(10),
        punc(Jpunc::RParen),
        punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// dec.hoon
#[test]
fn dec() {
    let input = "func dec(a:@) -> @ {\n  let b = 0;\n  loop;\n  if a == +(b) {\n    b\n  } else {\n    b = +(b);\n    recur\n  }\n};\n\ndec(43)\n";
    let expected = vec![
        kw(Keyword::Func), name("dec"), punc(Jpunc::DoubleParen), name("a"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), punc(Jpunc::At), punc(Jpunc::LBrace),
        kw(Keyword::Let), name("b"), punc(Jpunc::Equals), num(0), punc(Jpunc::Semicolon),
        kw(Keyword::Loop), punc(Jpunc::Semicolon),
        kw(Keyword::If), name("a"), punc(Jpunc::Equals), punc(Jpunc::Equals), punc(Jpunc::Plus), punc(Jpunc::LParen), name("b"), punc(Jpunc::RParen),
        punc(Jpunc::LBrace), name("b"), punc(Jpunc::RBrace),
        kw(Keyword::Else), punc(Jpunc::LBrace),
        name("b"), punc(Jpunc::Equals), punc(Jpunc::Plus), punc(Jpunc::LParen), name("b"), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        kw(Keyword::Recur),
        punc(Jpunc::RBrace), punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        name("dec"), punc(Jpunc::DoubleParen), num(43), punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// eval.hoon
#[test]
fn eval_test() {
    let input = "let a = eval (42 55) (0 2);\n\na\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Equals), kw(Keyword::Eval),
        punc(Jpunc::LParen), num(42), num(55), punc(Jpunc::RParen),
        punc(Jpunc::LParen), num(0), num(2), punc(Jpunc::RParen),
        punc(Jpunc::Semicolon), name("a"),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// let-edit.hoon
#[test]
fn let_edit() {
    let input = "let a: ? = true;\n\na = false;\n\na\n\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Colon), punc(Jpunc::Question),
        punc(Jpunc::Equals), bool_lit(true), punc(Jpunc::Semicolon),
        name("a"), punc(Jpunc::Equals), bool_lit(false), punc(Jpunc::Semicolon),
        name("a"),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// let-inner-exp.hoon
#[test]
fn let_inner_exp() {
    let input = "let a = 42;\n\na\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Equals), num(42), punc(Jpunc::Semicolon),
        name("a"),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// axis-call.hoon
#[test]
fn axis_call() {
    let input = "func a(b:@) -> @ {\n  +(b)\n};\n\n&2(17)\n";
    let expected = vec![
        kw(Keyword::Func), name("a"), punc(Jpunc::DoubleParen), name("b"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), punc(Jpunc::At), punc(Jpunc::LBrace),
        punc(Jpunc::Plus), punc(Jpunc::LParen), name("b"), punc(Jpunc::RParen),
        punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        punc(Jpunc::Ampersand), num(2), punc(Jpunc::LParen), num(17), punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// comparator.hoon
#[test]
fn comparator() {
    let input = "let a = true;\nlet b = a == true;\nlet c = a < 1;\nlet d = a > 2;\nlet e = b != true;\nlet f = a <= 1;\nlet g = a >= 2;\n\ng\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Equals), bool_lit(true), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("b"), punc(Jpunc::Equals), name("a"), punc(Jpunc::Equals), punc(Jpunc::Equals), bool_lit(true), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("c"), punc(Jpunc::Equals), name("a"), punc(Jpunc::LessThan), num(1), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("d"), punc(Jpunc::Equals), name("a"), punc(Jpunc::GreaterThan), num(2), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("e"), punc(Jpunc::Equals), name("b"), punc(Jpunc::Bang), punc(Jpunc::Equals), bool_lit(true), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("f"), punc(Jpunc::Equals), name("a"), punc(Jpunc::LessThan), punc(Jpunc::Equals), num(1), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("g"), punc(Jpunc::Equals), name("a"), punc(Jpunc::GreaterThan), punc(Jpunc::Equals), num(2), punc(Jpunc::Semicolon),
        name("g"),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// inline-lambda-call.hoon
#[test]
fn inline_lambda_call() {
    let input = "lambda (b:@) -> @ {\n  +(b)\n}(41)\n";
    let expected = vec![
        kw(Keyword::Lambda), punc(Jpunc::LParen), name("b"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), punc(Jpunc::At), punc(Jpunc::LBrace),
        punc(Jpunc::Plus), punc(Jpunc::LParen), name("b"), punc(Jpunc::RParen),
        punc(Jpunc::RBrace), punc(Jpunc::LParen), num(41), punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// class-ops.hoon
#[test]
fn class_ops() {
    let input = "compose\n  class Point(x:@ y:@) {\n   add(p:(x:@ y:@)) -> Point {\n     (x + p.x\n      y + p.y)\n   }\n  }\n;\n\nlet point_1 = Point(14 104);\npoint_1 = point_1.add(28 38);\n(point_1.x() point_1.y())\n\n/*\n=>\n  |%\n  ++  b  5\n  ++  a  |=(c=@ +(c))\n  --\n(a b)\n\n[7 [1 [1 5] 8 [1 0] [1 4 0 6] 0 1] 8 [9 3 0 1] 9 2 10 [6 7 [0 3] 9 2 0 1] 0 2]\n*/\n";
    let expected = vec![
        kw(Keyword::Compose), kw(Keyword::Class), typ("Point"), punc(Jpunc::DoubleParen), name("x"), punc(Jpunc::Colon), punc(Jpunc::At), name("y"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::RParen),
        punc(Jpunc::LBrace),
        name("add"), punc(Jpunc::DoubleParen), name("p"), punc(Jpunc::Colon), punc(Jpunc::LParen), name("x"), punc(Jpunc::Colon), punc(Jpunc::At), name("y"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::RParen), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), typ("Point"), punc(Jpunc::LBrace),
        punc(Jpunc::LParen), name("x"), punc(Jpunc::Plus), name("p"), punc(Jpunc::Dot), name("x"),
        name("y"), punc(Jpunc::Plus), name("p"), punc(Jpunc::Dot), name("y"), punc(Jpunc::RParen),
        punc(Jpunc::RBrace),
        punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("point_1"), punc(Jpunc::Equals), typ("Point"), punc(Jpunc::DoubleParen), num(14), num(104), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        name("point_1"), punc(Jpunc::Equals), name("point_1"), punc(Jpunc::Dot), name("add"), punc(Jpunc::DoubleParen), num(28), num(38), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        punc(Jpunc::LParen), name("point_1"), punc(Jpunc::Dot), name("x"), punc(Jpunc::DoubleParen), punc(Jpunc::RParen), name("point_1"), punc(Jpunc::Dot), name("y"), punc(Jpunc::DoubleParen), punc(Jpunc::RParen), punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// class-state.hoon
#[test]
fn class_state() {
    let input = "compose\n  class Point(x:@ y:@) {\n    inc(q:@) -> @ {\n      +(q)\n    }\n  }\n;\n\nlet point_1 = Point(70 80);\nlet point_2 = Point(90 100);\n((point_2.x() point_2.y()) (point_1.x() point_1.y()))\n\n/*\n!=\n=>  mini=mini\n=>\n  ^=  door\n  |_  [x=@ y=@]\n  ++  add\n    |=  p=[x=@ y=@]\n    [(add:mini x x.p) (add:mini y y.p)]\n  ++  inc\n    |=  q=@\n    +(q)\n  --\n=/  point_1\n  ~(. door [70 80])\n=/  point_2\n  ~(. door [90 100])\n[[+13 +12]:point_2 [+13 +12]:point_1]\n*/\n";
    let expected = vec![
        kw(Keyword::Compose), kw(Keyword::Class), typ("Point"), punc(Jpunc::DoubleParen), name("x"), punc(Jpunc::Colon), punc(Jpunc::At), name("y"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::RParen),
        punc(Jpunc::LBrace),
        name("inc"), punc(Jpunc::DoubleParen), name("q"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), punc(Jpunc::At), punc(Jpunc::LBrace),
        punc(Jpunc::Plus), punc(Jpunc::LParen), name("q"), punc(Jpunc::RParen),
        punc(Jpunc::RBrace),
        punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("point_1"), punc(Jpunc::Equals), typ("Point"), punc(Jpunc::DoubleParen), num(70), num(80), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("point_2"), punc(Jpunc::Equals), typ("Point"), punc(Jpunc::DoubleParen), num(90), num(100), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        punc(Jpunc::LParen),
        punc(Jpunc::LParen), name("point_2"), punc(Jpunc::Dot), name("x"), punc(Jpunc::DoubleParen), punc(Jpunc::RParen), name("point_2"), punc(Jpunc::Dot), name("y"), punc(Jpunc::DoubleParen), punc(Jpunc::RParen), punc(Jpunc::RParen),
        punc(Jpunc::LParen), name("point_1"), punc(Jpunc::Dot), name("x"), punc(Jpunc::DoubleParen), punc(Jpunc::RParen), name("point_1"), punc(Jpunc::Dot), name("y"), punc(Jpunc::DoubleParen), punc(Jpunc::RParen), punc(Jpunc::RParen),
        punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// compose-cores.hoon
#[test]
fn compose_cores() {
    let input = "func g(a:@) -> @ {\n  29\n};\n\ncompose\n  with this; object {\n    b = lambda (c:@) -> @ {\n      g(5)\n    }\n    c = 89\n  };\n\nb(3)\n";
    let expected = vec![
        kw(Keyword::Func), name("g"), punc(Jpunc::DoubleParen), name("a"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), punc(Jpunc::At), punc(Jpunc::LBrace),
        num(29),
        punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        kw(Keyword::Compose), kw(Keyword::With), kw(Keyword::This), punc(Jpunc::Semicolon),
        kw(Keyword::Object), punc(Jpunc::LBrace),
        name("b"), punc(Jpunc::Equals), kw(Keyword::Lambda), punc(Jpunc::LParen), name("c"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), punc(Jpunc::At), punc(Jpunc::LBrace),
        name("g"), punc(Jpunc::DoubleParen), num(5), punc(Jpunc::RParen),
        punc(Jpunc::RBrace),
        name("c"), punc(Jpunc::Equals), num(89),
        punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        name("b"), punc(Jpunc::DoubleParen), num(3), punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// hoon-ffi.hoon
#[test]
fn hoon_ffi() {
    let input = "let a = 1;\nlet b = 41;\nlet c = 43;\nlet d = 6;\nlet e = 7;\nlet f = 252;\n\n(hoon.add(a b)\n hoon.sub(c a)\n hoon.mul(d e)\n hoon.div(f d)\n)\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Equals), num(1), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("b"), punc(Jpunc::Equals), num(41), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("c"), punc(Jpunc::Equals), num(43), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("d"), punc(Jpunc::Equals), num(6), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("e"), punc(Jpunc::Equals), num(7), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("f"), punc(Jpunc::Equals), num(252), punc(Jpunc::Semicolon),
        punc(Jpunc::LParen),
        name("hoon"), punc(Jpunc::Dot), name("add"), punc(Jpunc::DoubleParen), name("a"), name("b"), punc(Jpunc::RParen),
        name("hoon"), punc(Jpunc::Dot), name("sub"), punc(Jpunc::DoubleParen), name("c"), name("a"), punc(Jpunc::RParen),
        name("hoon"), punc(Jpunc::Dot), name("mul"), punc(Jpunc::DoubleParen), name("d"), name("e"), punc(Jpunc::RParen),
        name("hoon"), punc(Jpunc::Dot), name("div"), punc(Jpunc::DoubleParen), name("f"), name("d"), punc(Jpunc::RParen),
        punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// hoon-alias.hoon
#[test]
fn hoon_alias() {
    let input = "import hoon as lib;\n\nlet a:@ = 6;\nlet b:@ = 7;\n\nlib.mul(a b)\n";
    let expected = vec![
        kw(Keyword::Import), name("hoon"), kw(Keyword::As), name("lib"), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("a"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::Equals), num(6), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("b"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::Equals), num(7), punc(Jpunc::Semicolon),
        name("lib"), punc(Jpunc::Dot), name("mul"), punc(Jpunc::DoubleParen), name("a"), name("b"), punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// multi-limb.hoon
#[test]
fn multi_limb() {
    let input = "let a: (p:@ q:(k:@ v:@)) = (52 30 42);\n\n(a.q.v)  // reduces to a.q.v, so also testing tuple-of-one\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Colon),
        punc(Jpunc::LParen), name("p"), punc(Jpunc::Colon), punc(Jpunc::At),
        name("q"), punc(Jpunc::Colon), punc(Jpunc::LParen), name("k"), punc(Jpunc::Colon), punc(Jpunc::At), name("v"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::RParen), punc(Jpunc::RParen),
        punc(Jpunc::Equals), punc(Jpunc::LParen), num(52), num(30), num(42), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        punc(Jpunc::LParen), name("a"), punc(Jpunc::Dot), name("q"), punc(Jpunc::Dot), name("v"), punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// match-type.hoon
#[test]
fn match_type() {
    let input = "let a: @ = 3;\n\nmatch a {\n  %1 -> 0;\n  %2 -> 21;\n  %3 -> 42;\n  %4 -> 63;\n  _ -> 84;\n}\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::Equals), num(3), punc(Jpunc::Semicolon),
        kw(Keyword::Match), name("a"), punc(Jpunc::LBrace),
        const_num(1), punc(Jpunc::Minus), punc(Jpunc::GreaterThan), num(0), punc(Jpunc::Semicolon),
        const_num(2), punc(Jpunc::Minus), punc(Jpunc::GreaterThan), num(21), punc(Jpunc::Semicolon),
        const_num(3), punc(Jpunc::Minus), punc(Jpunc::GreaterThan), num(42), punc(Jpunc::Semicolon),
        const_num(4), punc(Jpunc::Minus), punc(Jpunc::GreaterThan), num(63), punc(Jpunc::Semicolon),
        punc(Jpunc::Underscore), punc(Jpunc::Minus), punc(Jpunc::GreaterThan), num(84), punc(Jpunc::Semicolon),
        punc(Jpunc::RBrace),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// infix-arithmetic.hoon
#[test]
fn infix_arithmetic() {
    let input = "[ (41 + 5) - 4\n  (126 * 2) / 6\n  ((6 ** 2) + 6) % 100\n  (2 ** 5) + 10\n  1 + 2 + 39\n  (50 - 9) + 1\n]\n";
    let expected = vec![
        punc(Jpunc::LBracket),
        punc(Jpunc::LParen), num(41), punc(Jpunc::Plus), num(5), punc(Jpunc::RParen), punc(Jpunc::Minus), num(4),
        punc(Jpunc::LParen), num(126), punc(Jpunc::Star), num(2), punc(Jpunc::RParen), punc(Jpunc::Slash), num(6),
        punc(Jpunc::LParen), punc(Jpunc::LParen), num(6), punc(Jpunc::Star), punc(Jpunc::Star), num(2), punc(Jpunc::RParen), punc(Jpunc::Plus), num(6), punc(Jpunc::RParen), punc(Jpunc::Percent), num(100),
        punc(Jpunc::LParen), num(2), punc(Jpunc::Star), punc(Jpunc::Star), num(5), punc(Jpunc::RParen), punc(Jpunc::Plus), num(10),
        num(1), punc(Jpunc::Plus), num(2), punc(Jpunc::Plus), num(39),
        punc(Jpunc::LParen), num(50), punc(Jpunc::Minus), num(9), punc(Jpunc::RParen), punc(Jpunc::Plus), num(1),
        punc(Jpunc::RBracket),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// infix-comparator.hoon
#[test]
fn infix_comparator() {
    let input = "(\n    1 < 0\n    0 <= 1\n    0 == 1\n    1 > 0\n    0 >= 0\n    1 != 1\n)\n";
    let expected = vec![
        punc(Jpunc::LParen),
        num(1), punc(Jpunc::LessThan), num(0),
        num(0), punc(Jpunc::LessThan), punc(Jpunc::Equals), num(1),
        num(0), punc(Jpunc::Equals), punc(Jpunc::Equals), num(1),
        num(1), punc(Jpunc::GreaterThan), num(0),
        num(0), punc(Jpunc::GreaterThan), punc(Jpunc::Equals), num(0),
        num(1), punc(Jpunc::Bang), punc(Jpunc::Equals), num(1),
        punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// type-point.hoon
#[test]
fn type_point() {
    let input = "/*  A class is broadly equivalent to a Hoon door. It has a top-level\n    sample which represents its state, along with methods that have\n    each their own samples.\n\n    A class must be composed into the subject to be accessible.\n*/\ncompose\n  class Foo(x:@) {\n    bar(p:@) -> Foo {\n      p\n    }\n  }\n; // end compose\n\n//  let name:Type = value;\nlet a:Foo = Foo(41);\n//  let name = Type(value);\nlet b = Foo(42);\n//  let name:type = value;\nlet c:@ = 43;\n\n(Foo(40) a b c)\n";
    let expected = vec![
        kw(Keyword::Compose), kw(Keyword::Class), typ("Foo"), punc(Jpunc::DoubleParen), name("x"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::RParen),
        punc(Jpunc::LBrace),
        name("bar"), punc(Jpunc::DoubleParen), name("p"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), typ("Foo"), punc(Jpunc::LBrace),
        name("p"),
        punc(Jpunc::RBrace),
        punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("a"), punc(Jpunc::Colon), typ("Foo"), punc(Jpunc::Equals), typ("Foo"), punc(Jpunc::DoubleParen), num(41), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("b"), punc(Jpunc::Equals), typ("Foo"), punc(Jpunc::DoubleParen), num(42), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("c"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::Equals), num(43), punc(Jpunc::Semicolon),
        punc(Jpunc::LParen), typ("Foo"), punc(Jpunc::DoubleParen), num(40), punc(Jpunc::RParen), name("a"), name("b"), name("c"), punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// type-point-2.hoon
#[test]
fn type_point_2() {
    let input = "compose\n  class Point(x:Uint y:Uint) {\n   add(p:(x:Uint y:Uint)) -> Point {\n     (x + p.x\n      y + p.y)\n   }\n   sub(p:(x:Uint y:Uint)) -> Point {\n     (x - p.x\n      y - p.y)\n   }\n  }\n;\n\nlet point_1 = Point(104 124);\npoint_1 = point_1.add(38 38);\nlet point_2 = Point(30 40);\n//&2\npoint_2 = point_2.add(212 302);\n//&1\npoint_1 = point_1.sub(100 20);\n//&1\n( (point_1.x() point_1.y())\n  (point_2.x() point_2.y())\n)/**/\n";
    let expected = vec![
        kw(Keyword::Compose), kw(Keyword::Class), typ("Point"), punc(Jpunc::DoubleParen), name("x"), punc(Jpunc::Colon), typ("Uint"), name("y"), punc(Jpunc::Colon), typ("Uint"), punc(Jpunc::RParen),
        punc(Jpunc::LBrace),
        name("add"), punc(Jpunc::DoubleParen), name("p"), punc(Jpunc::Colon), punc(Jpunc::LParen), name("x"), punc(Jpunc::Colon), typ("Uint"), name("y"), punc(Jpunc::Colon), typ("Uint"), punc(Jpunc::RParen), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), typ("Point"), punc(Jpunc::LBrace),
        punc(Jpunc::LParen), name("x"), punc(Jpunc::Plus), name("p"), punc(Jpunc::Dot), name("x"), name("y"), punc(Jpunc::Plus), name("p"), punc(Jpunc::Dot), name("y"), punc(Jpunc::RParen),
        punc(Jpunc::RBrace),
        name("sub"), punc(Jpunc::DoubleParen), name("p"), punc(Jpunc::Colon), punc(Jpunc::LParen), name("x"), punc(Jpunc::Colon), typ("Uint"), name("y"), punc(Jpunc::Colon), typ("Uint"), punc(Jpunc::RParen), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), typ("Point"), punc(Jpunc::LBrace),
        punc(Jpunc::LParen), name("x"), punc(Jpunc::Minus), name("p"), punc(Jpunc::Dot), name("x"), name("y"), punc(Jpunc::Minus), name("p"), punc(Jpunc::Dot), name("y"), punc(Jpunc::RParen),
        punc(Jpunc::RBrace),
        punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("point_1"), punc(Jpunc::Equals), typ("Point"), punc(Jpunc::DoubleParen), num(104), num(124), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        name("point_1"), punc(Jpunc::Equals), name("point_1"), punc(Jpunc::Dot), name("add"), punc(Jpunc::DoubleParen), num(38), num(38), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("point_2"), punc(Jpunc::Equals), typ("Point"), punc(Jpunc::DoubleParen), num(30), num(40), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        name("point_2"), punc(Jpunc::Equals), name("point_2"), punc(Jpunc::Dot), name("add"), punc(Jpunc::DoubleParen), num(212), num(302), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        name("point_1"), punc(Jpunc::Equals), name("point_1"), punc(Jpunc::Dot), name("sub"), punc(Jpunc::DoubleParen), num(100), num(20), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        punc(Jpunc::LParen), punc(Jpunc::LParen), name("point_1"), punc(Jpunc::Dot), name("x"), punc(Jpunc::DoubleParen), punc(Jpunc::RParen), name("point_1"), punc(Jpunc::Dot), name("y"), punc(Jpunc::DoubleParen), punc(Jpunc::RParen), punc(Jpunc::RParen),
        punc(Jpunc::LParen), name("point_2"), punc(Jpunc::Dot), name("x"), punc(Jpunc::DoubleParen), punc(Jpunc::RParen), name("point_2"), punc(Jpunc::Dot), name("y"), punc(Jpunc::DoubleParen), punc(Jpunc::RParen), punc(Jpunc::RParen),
        punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// type-point-3.hoon
#[test]
fn type_point_3() {
    let input = "compose\n  class Point(x:Uint y:Uint) {\n    add(p:(x:Uint y:Uint)) -> Point {\n      (x + p.x\n       y + p.y)\n    }\n    add_cell(p:(x:Uint y:Uint)) -> (Uint Uint) {\n      (x + p.x\n       y + p.y)\n    }\n    inc(q:Uint) -> @ {\n      +(q)\n    }\n  }\n;\n\nlet one = Point(2 13);\nlet two = one.add(30 19);\nlet three = one.inc(41);\n(two.add_cell(10 10) three)\n";
    let expected = vec![
        kw(Keyword::Compose), kw(Keyword::Class), typ("Point"), punc(Jpunc::DoubleParen), name("x"), punc(Jpunc::Colon), typ("Uint"), name("y"), punc(Jpunc::Colon), typ("Uint"), punc(Jpunc::RParen),
        punc(Jpunc::LBrace),
        name("add"), punc(Jpunc::DoubleParen), name("p"), punc(Jpunc::Colon), punc(Jpunc::LParen), name("x"), punc(Jpunc::Colon), typ("Uint"), name("y"), punc(Jpunc::Colon), typ("Uint"), punc(Jpunc::RParen), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), typ("Point"), punc(Jpunc::LBrace),
        punc(Jpunc::LParen), name("x"), punc(Jpunc::Plus), name("p"), punc(Jpunc::Dot), name("x"), name("y"), punc(Jpunc::Plus), name("p"), punc(Jpunc::Dot), name("y"), punc(Jpunc::RParen),
        punc(Jpunc::RBrace),
        name("add_cell"), punc(Jpunc::DoubleParen), name("p"), punc(Jpunc::Colon), punc(Jpunc::LParen), name("x"), punc(Jpunc::Colon), typ("Uint"), name("y"), punc(Jpunc::Colon), typ("Uint"), punc(Jpunc::RParen), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), punc(Jpunc::LParen), typ("Uint"), typ("Uint"), punc(Jpunc::RParen), punc(Jpunc::LBrace),
        punc(Jpunc::LParen), name("x"), punc(Jpunc::Plus), name("p"), punc(Jpunc::Dot), name("x"), name("y"), punc(Jpunc::Plus), name("p"), punc(Jpunc::Dot), name("y"), punc(Jpunc::RParen),
        punc(Jpunc::RBrace),
        name("inc"), punc(Jpunc::DoubleParen), name("q"), punc(Jpunc::Colon), typ("Uint"), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), punc(Jpunc::At), punc(Jpunc::LBrace),
        punc(Jpunc::Plus), punc(Jpunc::LParen), name("q"), punc(Jpunc::RParen),
        punc(Jpunc::RBrace),
        punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("one"), punc(Jpunc::Equals), typ("Point"), punc(Jpunc::DoubleParen), num(2), num(13), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("two"), punc(Jpunc::Equals), name("one"), punc(Jpunc::Dot), name("add"), punc(Jpunc::DoubleParen), num(30), num(19), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("three"), punc(Jpunc::Equals), name("one"), punc(Jpunc::Dot), name("inc"), punc(Jpunc::DoubleParen), num(41), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        punc(Jpunc::LParen), name("two"), punc(Jpunc::Dot), name("add_cell"), punc(Jpunc::DoubleParen), num(10), num(10), punc(Jpunc::RParen), name("three"), punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// lists.hoon
#[test]
fn lists() {
    let input = "let d = [11];\n\nlet c = [9 10];\n\nlet b = [6 7 8];\n\nlet a = [1 2 3 4 5];\n\n\n[a b c d]\n";
    let expected = vec![
        kw(Keyword::Let), name("d"), punc(Jpunc::Equals), punc(Jpunc::LBracket), num(11), punc(Jpunc::RBracket), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("c"), punc(Jpunc::Equals), punc(Jpunc::LBracket), num(9), num(10), punc(Jpunc::RBracket), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("b"), punc(Jpunc::Equals), punc(Jpunc::LBracket), num(6), num(7), num(8), punc(Jpunc::RBracket), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("a"), punc(Jpunc::Equals), punc(Jpunc::LBracket), num(1), num(2), num(3), num(4), num(5), punc(Jpunc::RBracket), punc(Jpunc::Semicolon),
        punc(Jpunc::LBracket), name("a"), name("b"), name("c"), name("d"), punc(Jpunc::RBracket),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// lists-nested.hoon
#[test]
fn lists_nested() {
    let input = "let a:List(@) = [1];\n\nlet b:List(@) = [1 2];\n\nlet c:List(@) = [1 2 3];\n\nlet d:List((@ @)) = [(1 2) (3 4)];\n\nlet e:List((@ List(@))) = [(1 [2]) (3 [4 5])];\n\n(a b c d e)\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Colon), typ("List"), punc(Jpunc::DoubleParen), punc(Jpunc::At), punc(Jpunc::RParen), punc(Jpunc::Equals), punc(Jpunc::LBracket), num(1), punc(Jpunc::RBracket), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("b"), punc(Jpunc::Colon), typ("List"), punc(Jpunc::DoubleParen), punc(Jpunc::At), punc(Jpunc::RParen), punc(Jpunc::Equals), punc(Jpunc::LBracket), num(1), num(2), punc(Jpunc::RBracket), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("c"), punc(Jpunc::Colon), typ("List"), punc(Jpunc::DoubleParen), punc(Jpunc::At), punc(Jpunc::RParen), punc(Jpunc::Equals), punc(Jpunc::LBracket), num(1), num(2), num(3), punc(Jpunc::RBracket), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("d"), punc(Jpunc::Colon), typ("List"), punc(Jpunc::DoubleParen), punc(Jpunc::LParen), punc(Jpunc::At), punc(Jpunc::At), punc(Jpunc::RParen), punc(Jpunc::RParen), punc(Jpunc::Equals), punc(Jpunc::LBracket), punc(Jpunc::LParen), num(1), num(2), punc(Jpunc::RParen), punc(Jpunc::LParen), num(3), num(4), punc(Jpunc::RParen), punc(Jpunc::RBracket), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("e"), punc(Jpunc::Colon), typ("List"), punc(Jpunc::DoubleParen), punc(Jpunc::LParen), punc(Jpunc::At), typ("List"), punc(Jpunc::DoubleParen), punc(Jpunc::At), punc(Jpunc::RParen), punc(Jpunc::RParen), punc(Jpunc::RParen), punc(Jpunc::Equals), punc(Jpunc::LBracket), punc(Jpunc::LParen), num(1), punc(Jpunc::LBracket), num(2), punc(Jpunc::RBracket), punc(Jpunc::RParen), punc(Jpunc::LParen), num(3), punc(Jpunc::LBracket), num(4), num(5), punc(Jpunc::RBracket), punc(Jpunc::RParen), punc(Jpunc::RBracket), punc(Jpunc::Semicolon),
        punc(Jpunc::LParen), name("a"), name("b"), name("c"), name("d"), name("e"), punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// lists-indexing.hoon
#[test]
fn lists_indexing() {
    let input = "let a = [100 200 300 400 500];\nlet b:List(@ @) = [(10 20) (30 40) (50 60)];\n\n(hoon.snag(0 a) hoon.snag(2 b))\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Equals), punc(Jpunc::LBracket), num(100), num(200), num(300), num(400), num(500), punc(Jpunc::RBracket), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("b"), punc(Jpunc::Colon), typ("List"), punc(Jpunc::DoubleParen), punc(Jpunc::At), punc(Jpunc::At), punc(Jpunc::RParen), punc(Jpunc::Equals), punc(Jpunc::LBracket), punc(Jpunc::LParen), num(10), num(20), punc(Jpunc::RParen), punc(Jpunc::LParen), num(30), num(40), punc(Jpunc::RParen), punc(Jpunc::LParen), num(50), num(60), punc(Jpunc::RParen), punc(Jpunc::RBracket), punc(Jpunc::Semicolon),
        punc(Jpunc::LParen), name("hoon"), punc(Jpunc::Dot), name("snag"), punc(Jpunc::DoubleParen), num(0), name("a"), punc(Jpunc::RParen), name("hoon"), punc(Jpunc::Dot), name("snag"), punc(Jpunc::DoubleParen), num(2), name("b"), punc(Jpunc::RParen), punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// sets.hoon
#[test]
fn sets() {
    let input = "let a:Set(@) = {1};\n\nlet b:Set(@) = {1 2};\n\nlet c:Set(@) = {1 2 3 2 1};\n\nlet d:Set((@ @)) = {(1 2) (3 4) (1 2)};\n\nlet e:Set((@ Set(@))) = {(1 {2}) (3 {4 5})};\n\n(a b c d e)\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Colon), typ("Set"), punc(Jpunc::DoubleParen), punc(Jpunc::At), punc(Jpunc::RParen), punc(Jpunc::Equals), punc(Jpunc::LBrace), num(1), punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("b"), punc(Jpunc::Colon), typ("Set"), punc(Jpunc::DoubleParen), punc(Jpunc::At), punc(Jpunc::RParen), punc(Jpunc::Equals), punc(Jpunc::LBrace), num(1), num(2), punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("c"), punc(Jpunc::Colon), typ("Set"), punc(Jpunc::DoubleParen), punc(Jpunc::At), punc(Jpunc::RParen), punc(Jpunc::Equals), punc(Jpunc::LBrace), num(1), num(2), num(3), num(2), num(1), punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("d"), punc(Jpunc::Colon), typ("Set"), punc(Jpunc::DoubleParen), punc(Jpunc::LParen), punc(Jpunc::At), punc(Jpunc::At), punc(Jpunc::RParen), punc(Jpunc::RParen), punc(Jpunc::Equals), punc(Jpunc::LBrace), punc(Jpunc::LParen), num(1), num(2), punc(Jpunc::RParen), punc(Jpunc::LParen), num(3), num(4), punc(Jpunc::RParen), punc(Jpunc::LParen), num(1), num(2), punc(Jpunc::RParen), punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("e"), punc(Jpunc::Colon), typ("Set"), punc(Jpunc::DoubleParen), punc(Jpunc::LParen), punc(Jpunc::At), typ("Set"), punc(Jpunc::DoubleParen), punc(Jpunc::At), punc(Jpunc::RParen), punc(Jpunc::RParen), punc(Jpunc::RParen), punc(Jpunc::Equals), punc(Jpunc::LBrace), punc(Jpunc::LParen), num(1), punc(Jpunc::LBrace), num(2), punc(Jpunc::RBrace), punc(Jpunc::RParen), punc(Jpunc::LParen), num(3), punc(Jpunc::LBrace), num(4), num(5), punc(Jpunc::RBrace), punc(Jpunc::RParen), punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        punc(Jpunc::LParen), name("a"), name("b"), name("c"), name("d"), name("e"), punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// hoon-arithmetic.hoon
#[test]
fn hoon_arithmetic() {
    let input = "import hoon;\n\nlet a:@ = 5;\nlet b:@ = 37;\n\n(\n  hoon.dec(43)\n  hoon.add(5 37)\n  hoon.add(a b)\n  hoon.sub(47 a)\n  hoon.lent([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42])\n)\n";
    let expected = vec![
        kw(Keyword::Import), name("hoon"), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("a"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::Equals), num(5), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("b"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::Equals), num(37), punc(Jpunc::Semicolon),
        punc(Jpunc::LParen),
        name("hoon"), punc(Jpunc::Dot), name("dec"), punc(Jpunc::DoubleParen), num(43), punc(Jpunc::RParen),
        name("hoon"), punc(Jpunc::Dot), name("add"), punc(Jpunc::DoubleParen), num(5), num(37), punc(Jpunc::RParen),
        name("hoon"), punc(Jpunc::Dot), name("add"), punc(Jpunc::DoubleParen), name("a"), name("b"), punc(Jpunc::RParen),
        name("hoon"), punc(Jpunc::Dot), name("sub"), punc(Jpunc::DoubleParen), num(47), name("a"), punc(Jpunc::RParen),
        name("hoon"), punc(Jpunc::Dot), name("lent"), punc(Jpunc::DoubleParen), punc(Jpunc::LBracket),
        num(1), num(2), num(3), num(4), num(5), num(6), num(7), num(8), num(9), num(10),
        num(11), num(12), num(13), num(14), num(15), num(16), num(17), num(18), num(19), num(20),
        num(21), num(22), num(23), num(24), num(25), num(26), num(27), num(28), num(29), num(30),
        num(31), num(32), num(33), num(34), num(35), num(36), num(37), num(38), num(39), num(40),
        num(41), num(42),
        punc(Jpunc::RBracket), punc(Jpunc::RParen),
        punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

// ---------------------------------------------------------------
// Tests for files with mismatched Hoon test-tokenize expectations.
// Correct tokens computed from actual source text.
// ---------------------------------------------------------------

/// assert.hoon (Hoon test-tokenize is mismatched; correct tokens below)
#[test]
fn assert_test() {
    let input = "let a: @ = 5;\nlet b: @ = 0;\n\nassert a != 0;\nlet c = ?((a a));\nloop;\n\nif a == +(b) {\n  b\n} else {\n  b = +(b);\n  recur\n}\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::Equals), num(5), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("b"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::Equals), num(0), punc(Jpunc::Semicolon),
        kw(Keyword::Assert), name("a"), punc(Jpunc::Bang), punc(Jpunc::Equals), num(0), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("c"), punc(Jpunc::Equals), punc(Jpunc::Question), punc(Jpunc::LParen), punc(Jpunc::LParen), name("a"), name("a"), punc(Jpunc::RParen), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        kw(Keyword::Loop), punc(Jpunc::Semicolon),
        kw(Keyword::If), name("a"), punc(Jpunc::Equals), punc(Jpunc::Equals), punc(Jpunc::Plus), punc(Jpunc::LParen), name("b"), punc(Jpunc::RParen),
        punc(Jpunc::LBrace), name("b"), punc(Jpunc::RBrace),
        kw(Keyword::Else), punc(Jpunc::LBrace),
        name("b"), punc(Jpunc::Equals), punc(Jpunc::Plus), punc(Jpunc::LParen), name("b"), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        kw(Keyword::Recur),
        punc(Jpunc::RBrace),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// if-else.hoon (Hoon test-tokenize is mismatched; correct tokens below)
#[test]
fn if_else() {
    let input = "let a: @ = 3;\n\nif a == 3 {\n  42\n} else {\n  17\n}\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::Equals), num(3), punc(Jpunc::Semicolon),
        kw(Keyword::If), name("a"), punc(Jpunc::Equals), punc(Jpunc::Equals), num(3),
        punc(Jpunc::LBrace), num(42), punc(Jpunc::RBrace),
        kw(Keyword::Else), punc(Jpunc::LBrace), num(17), punc(Jpunc::RBrace),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// if-elseif-else.hoon (Hoon test-tokenize is mismatched; correct tokens below)
#[test]
fn if_elseif_else() {
    let input = "let a: @ = 3;\n\nif a == 3 {\n  42\n} else if a == 5 {\n  17\n} else {\n  15\n}\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::Equals), num(3), punc(Jpunc::Semicolon),
        kw(Keyword::If), name("a"), punc(Jpunc::Equals), punc(Jpunc::Equals), num(3),
        punc(Jpunc::LBrace), num(42), punc(Jpunc::RBrace),
        kw(Keyword::Else), kw(Keyword::If), name("a"), punc(Jpunc::Equals), punc(Jpunc::Equals), num(5),
        punc(Jpunc::LBrace), num(17), punc(Jpunc::RBrace),
        kw(Keyword::Else), punc(Jpunc::LBrace), num(15), punc(Jpunc::RBrace),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// call-let-edit.hoon (Hoon test-tokenize is mismatched; correct tokens below)
#[test]
fn call_let_edit() {
    let input = "func a(c:@) -> @ {\n  +(c)\n};\n\nlet b: @ = 42;\nb = a(23);\n\nb\n";
    let expected = vec![
        kw(Keyword::Func), name("a"), punc(Jpunc::DoubleParen), name("c"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), punc(Jpunc::At), punc(Jpunc::LBrace),
        punc(Jpunc::Plus), punc(Jpunc::LParen), name("c"), punc(Jpunc::RParen),
        punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("b"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::Equals), num(42), punc(Jpunc::Semicolon),
        name("b"), punc(Jpunc::Equals), name("a"), punc(Jpunc::DoubleParen), num(23), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        name("b"),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// inline-lambda-no-arg.hoon (Hoon test-tokenize is mismatched; correct tokens below)
#[test]
fn inline_lambda_no_arg() {
    let input = "lambda (b:@) -> @ {\n  +(b)\n}()\n";
    let expected = vec![
        kw(Keyword::Lambda), punc(Jpunc::LParen), name("b"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), punc(Jpunc::At), punc(Jpunc::LBrace),
        punc(Jpunc::Plus), punc(Jpunc::LParen), name("b"), punc(Jpunc::RParen),
        punc(Jpunc::RBrace), punc(Jpunc::LParen), punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// inline-point.hoon (Hoon test-tokenize is mismatched; correct tokens below)
#[test]
fn inline_point() {
    let input = "let a: @ = 5;\nlet b: @ = 0;\nloop;\nif a == +(b) {\n  b\n} else {\n  b = +(b);\n  $(b)\n}\n\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::Equals), num(5), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("b"), punc(Jpunc::Colon), punc(Jpunc::At), punc(Jpunc::Equals), num(0), punc(Jpunc::Semicolon),
        kw(Keyword::Loop), punc(Jpunc::Semicolon),
        kw(Keyword::If), name("a"), punc(Jpunc::Equals), punc(Jpunc::Equals), punc(Jpunc::Plus), punc(Jpunc::LParen), name("b"), punc(Jpunc::RParen),
        punc(Jpunc::LBrace), name("b"), punc(Jpunc::RBrace),
        kw(Keyword::Else), punc(Jpunc::LBrace),
        name("b"), punc(Jpunc::Equals), punc(Jpunc::Plus), punc(Jpunc::LParen), name("b"), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        punc(Jpunc::Dollar), punc(Jpunc::LParen), name("b"), punc(Jpunc::RParen),
        punc(Jpunc::RBrace),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// in-subj-call.hoon (Hoon test-tokenize is mismatched; correct tokens below)
#[test]
fn in_subj_call() {
    let input = "let a = 17;\n\nlet b = lambda ((b:@ c:&1)) -> @ {\n  if c == 18 {\n    +(b)\n  } else {\n    b\n  }\n}(23 &1);\n\n&1\n";
    let expected = vec![
        kw(Keyword::Let), name("a"), punc(Jpunc::Equals), num(17), punc(Jpunc::Semicolon),
        kw(Keyword::Let), name("b"), punc(Jpunc::Equals), kw(Keyword::Lambda),
        punc(Jpunc::LParen), punc(Jpunc::LParen), name("b"), punc(Jpunc::Colon), punc(Jpunc::At), name("c"), punc(Jpunc::Colon), punc(Jpunc::Ampersand), num(1), punc(Jpunc::RParen), punc(Jpunc::RParen),
        punc(Jpunc::Minus), punc(Jpunc::GreaterThan), punc(Jpunc::At), punc(Jpunc::LBrace),
        kw(Keyword::If), name("c"), punc(Jpunc::Equals), punc(Jpunc::Equals), num(18),
        punc(Jpunc::LBrace), punc(Jpunc::Plus), punc(Jpunc::LParen), name("b"), punc(Jpunc::RParen), punc(Jpunc::RBrace),
        kw(Keyword::Else), punc(Jpunc::LBrace), name("b"), punc(Jpunc::RBrace),
        punc(Jpunc::RBrace), punc(Jpunc::LParen), num(23), punc(Jpunc::Ampersand), num(1), punc(Jpunc::RParen), punc(Jpunc::Semicolon),
        punc(Jpunc::Ampersand), num(1),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}

/// baby.hoon (Hoon test-tokenize is mismatched; correct tokens below)
#[test]
fn baby() {
    let input = "compose with 0; object {\n  load = crash\n  peek = crash\n  poke = (a:* -> (* &1)) {\n    (a &1)\n  }\n  wish = crash\n};\n\npoke(3)\n";
    let expected = vec![
        kw(Keyword::Compose), kw(Keyword::With), num(0), punc(Jpunc::Semicolon),
        kw(Keyword::Object), punc(Jpunc::LBrace),
        name("load"), punc(Jpunc::Equals), kw(Keyword::Crash),
        name("peek"), punc(Jpunc::Equals), kw(Keyword::Crash),
        name("poke"), punc(Jpunc::Equals),
        punc(Jpunc::LParen), name("a"), punc(Jpunc::Colon), punc(Jpunc::Star), punc(Jpunc::Minus), punc(Jpunc::GreaterThan), punc(Jpunc::LParen), punc(Jpunc::Star), punc(Jpunc::Ampersand), num(1), punc(Jpunc::RParen), punc(Jpunc::RParen),
        punc(Jpunc::LBrace), punc(Jpunc::LParen), name("a"), punc(Jpunc::Ampersand), num(1), punc(Jpunc::RParen), punc(Jpunc::RBrace),
        name("wish"), punc(Jpunc::Equals), kw(Keyword::Crash),
        punc(Jpunc::RBrace), punc(Jpunc::Semicolon),
        name("poke"), punc(Jpunc::DoubleParen), num(3), punc(Jpunc::RParen),
    ];
    assert_eq!(tokenize(input).unwrap(), expected);
}
