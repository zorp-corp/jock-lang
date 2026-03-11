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

/// fib.hoon (partial — the function definition + first few calls)
#[test]
fn fib_func_def() {
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
