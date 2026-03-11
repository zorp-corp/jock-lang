/// Recursive descent parser for Jock.
///
/// Mirrors the Hoon parser functions in `jock.hoon` lines 399-1383.
/// Each `match_*` method corresponds to a Hoon `++match-*` arm.
use jock_tokenizer::{AtomVariant, Jatom, Jpunc, Keyword, Token};

use crate::ast::*;
use crate::error::*;

pub struct Parser {
    tokens: Vec<Token>,
    pos: usize,
}

impl Parser {
    pub fn new(tokens: Vec<Token>) -> Self {
        Self { tokens, pos: 0 }
    }

    // ── Cursor helpers ──────────────────────────────────────────

    fn at_end(&self) -> bool {
        self.pos >= self.tokens.len()
    }

    fn peek(&self) -> Option<&Token> {
        self.tokens.get(self.pos)
    }

    fn peek_at(&self, offset: usize) -> Option<&Token> {
        self.tokens.get(self.pos + offset)
    }

    fn has_punctuator(&self, punc: Jpunc) -> bool {
        matches!(self.peek(), Some(Token::Punctuator(p)) if *p == punc)
    }

    fn has_punctuator_at(&self, offset: usize, punc: Jpunc) -> bool {
        matches!(self.peek_at(offset), Some(Token::Punctuator(p)) if *p == punc)
    }

    fn has_keyword(&self, kw: Keyword) -> bool {
        matches!(self.peek(), Some(Token::Keyword(k)) if *k == kw)
    }

    /// Consume the next token if it is the expected punctuator, else error.
    fn expect_punctuator(&mut self, punc: Jpunc) -> Result<(), ParseError> {
        if self.has_punctuator(punc) {
            self.pos += 1;
            Ok(())
        } else {
            Err(self.error(format!("punctuator {:?}", punc)))
        }
    }

    /// Extract a name (cord) from a token, if it is Name or Type.
    fn get_name(tok: &Token) -> Option<String> {
        match tok {
            Token::Name(n) => Some(n.clone()),
            Token::Type(t) => Some(t.clone()),
            _ => None,
        }
    }

    /// Check if a name starts with an uppercase letter (i.e. is a type name).
    fn is_type_name(name: &str) -> bool {
        name.chars().next().is_some_and(|c| c.is_ascii_uppercase())
    }

    /// Create a Jlimb from a name string. Type names become Jlimb::Type,
    /// others become Jlimb::Name.  Mirrors `++make-jlimb` (line 728-733).
    fn make_jlimb(name: &str) -> Jlimb {
        if Self::is_type_name(name) {
            Jlimb::Type(name.to_string())
        } else {
            Jlimb::Name(name.to_string())
        }
    }

    fn error(&self, expected: String) -> ParseError {
        ParseError {
            kind: if self.at_end() {
                ParseErrorKind::UnexpectedEndOfInput { expected }
            } else {
                ParseErrorKind::UnexpectedToken {
                    expected,
                    found: self.peek().cloned(),
                }
            },
            position: self.pos,
        }
    }

    /// Scan ahead (without consuming) to determine if the current position
    /// starts an anonymous lambda.
    /// Two forms:
    ///   1. `(params) -> ret { body }` — arrow AFTER the closing paren
    ///   2. `(params -> ret) { body }` — arrow INSIDE the parens (baby.jock style)
    /// In both cases the token after the matching `)` must be `{`.
    fn is_lambda_ahead(&self) -> bool {
        // Current pos is right after the '(' was consumed.
        let mut depth = 1u32;
        let mut i = self.pos;
        let mut has_arrow_inside = false;
        while i < self.tokens.len() {
            match &self.tokens[i] {
                Token::Punctuator(Jpunc::LParen) => depth += 1,
                Token::Punctuator(Jpunc::RParen) => {
                    depth -= 1;
                    if depth == 0 {
                        let after = i + 1;
                        // Form 1: arrow after closing paren
                        if matches!(
                            (self.tokens.get(after), self.tokens.get(after + 1)),
                            (
                                Some(Token::Punctuator(Jpunc::Minus)),
                                Some(Token::Punctuator(Jpunc::GreaterThan)),
                            )
                        ) {
                            return true;
                        }
                        // Form 2: arrow was inside the parens, `{` follows
                        return has_arrow_inside
                            && matches!(
                                self.tokens.get(after),
                                Some(Token::Punctuator(Jpunc::LBrace))
                            );
                    }
                }
                // Detect `-` `>` at depth 1
                Token::Punctuator(Jpunc::Minus) if depth == 1 => {
                    if matches!(
                        self.tokens.get(i + 1),
                        Some(Token::Punctuator(Jpunc::GreaterThan))
                    ) {
                        has_arrow_inside = true;
                    }
                }
                _ => {}
            }
            i += 1;
        }
        false
    }

    // ── Top-level parse ─────────────────────────────────────────

    /// Parse all tokens into a single Jock AST.  Returns error if tokens
    /// remain unconsumed.
    pub fn parse(&mut self) -> Result<Jock, ParseError> {
        let jock = self.match_jock()?;
        if !self.at_end() {
            return Err(ParseError {
                kind: ParseErrorKind::UnexpectedToken {
                    expected: "end of input".into(),
                    found: self.peek().cloned(),
                },
                position: self.pos,
            });
        }
        Ok(jock)
    }

    // ── match-jock (lines 399-433) ──────────────────────────────

    /// Main expression parser.  Dispatches on the leading token, then
    /// checks for trailing infix operators.
    pub fn match_jock(&mut self) -> Result<Jock, ParseError> {
        if self.at_end() {
            return Err(self.error("jock expression".into()));
        }

        let lock = match self.peek().unwrap() {
            Token::Literal(_) => self.match_literal()?,
            Token::Name(_) => self.match_start_name()?,
            Token::Keyword(_) => self.match_keyword()?,
            Token::Punctuator(_) => self.match_start_punctuator()?,
            Token::Type(_) => self.match_start_name()?,
        };

        if self.at_end() {
            return Ok(lock);
        }

        // Check for infix operator
        let save = self.pos;
        if let Some((op_name, is_comparator, is_operator)) = self.any_operator() {
            // Special case: `-` followed by `>` is the arrow `->`, not minus.
            if op_name == "-"
                && matches!(self.peek(), Some(Token::Punctuator(Jpunc::GreaterThan)))
            {
                // Re-attach: not an operator, it's part of `->`.
                self.pos = save;
                return Ok(lock);
            }

            if is_comparator {
                let comp = Self::parse_comparator_from_str(&op_name);
                let rock = self.match_inner_jock()?;
                return Ok(Jock::Compare {
                    comp,
                    a: Box::new(lock),
                    b: Box::new(rock),
                });
            }

            if is_operator {
                let op = Self::parse_operator_from_str(&op_name);
                let rock = self.match_inner_jock()?;
                return Ok(Jock::Operator {
                    op,
                    a: Box::new(lock),
                    b: Some(Box::new(rock)),
                });
            }

            // Not a recognized infix — rewind.
            self.pos = save;
        }

        Ok(lock)
    }

    // ── match-inner-jock (lines 435-484) ────────────────────────

    /// Parse an expression in "inner" (subexpression) position.
    /// Allows only a subset of keywords (object, class, with, this, crash).
    fn match_inner_jock(&mut self) -> Result<Jock, ParseError> {
        if self.at_end() {
            return Err(self.error("inner jock expression".into()));
        }

        // Some keywords are allowed in inner position — fall through to match_jock
        if matches!(
            self.peek(),
            Some(Token::Keyword(
                Keyword::Object
                    | Keyword::Class
                    | Keyword::With
                    | Keyword::This
                    | Keyword::Crash
            ))
        ) {
            return self.match_jock();
        }

        let lock = match self.peek().unwrap() {
            Token::Literal(_) => self.match_literal()?,
            Token::Name(_) | Token::Type(_) => self.match_start_name()?,
            Token::Punctuator(_) => self.match_start_punctuator()?,
            _ => return Err(self.error("inner expression".into())),
        };

        if self.at_end() {
            return Ok(lock);
        }

        // Check for infix comparator
        if self.is_comparator_ahead() {
            let comp = self.match_comparator()?;
            let rock = self.match_inner_jock()?;
            return Ok(Jock::Compare {
                comp,
                a: Box::new(lock),
                b: Box::new(rock),
            });
        }

        // Check for infix operator
        if self.is_operator_ahead() {
            let op = self.match_operator()?;
            let rock = self.match_inner_jock()?;
            return Ok(Jock::Operator {
                op,
                a: Box::new(lock),
                b: Some(Box::new(rock)),
            });
        }

        Ok(lock)
    }

    // ── match-pair-inner-jock (lines 486-517) ───────────────────

    /// Parse a tuple/cell inside parentheses.
    /// Called when we're inside `( ... )` and need to read one or more
    /// inner jock expressions and build a cell.
    fn match_pair_inner_jock(&mut self) -> Result<Jock, ParseError> {
        if self.at_end() {
            return Err(self.error("pair expression".into()));
        }

        if self.has_punctuator(Jpunc::LParen) {
            self.pos += 1; // consume '('

            let jock_one = self.match_inner_jock()?;

            if self.has_punctuator(Jpunc::RParen) {
                self.pos += 1;
                return Ok(jock_one);
            }

            // Multiple elements → build cells (right-nested)
            let mut parts = vec![jock_one];
            while !self.has_punctuator(Jpunc::RParen) {
                parts.push(self.match_inner_jock()?);
            }
            self.pos += 1; // consume ')'

            // Build right-nested cell from parts
            return Ok(Self::build_cell(parts));
        }

        // Fall through to other expression types
        match self.peek() {
            Some(Token::Literal(_)) => self.match_literal(),
            Some(Token::Name(_) | Token::Type(_)) => self.match_start_name(),
            Some(Token::Punctuator(_)) => self.match_start_punctuator(),
            _ => Err(self.error("pair inner expression".into())),
        }
    }

    /// Build a right-nested cell from a list of Jock values.
    /// `[a, b, c]` → `Cell(a, Cell(b, c))`
    fn build_cell(mut parts: Vec<Jock>) -> Jock {
        assert!(parts.len() >= 2);
        let last = parts.pop().unwrap();
        parts.into_iter().rev().fold(last, |acc, part| Jock::Cell {
            p: Box::new(part),
            q: Box::new(acc),
        })
    }

    // ── match-start-punctuator (lines 556-656) ──────────────────

    fn match_start_punctuator(&mut self) -> Result<Jock, ParseError> {
        if self.at_end() {
            return Err(self.error("punctuator expression".into()));
        }

        let punc = match self.peek() {
            Some(Token::Punctuator(p)) => *p,
            _ => return Err(self.error("punctuator".into())),
        };
        self.pos += 1; // consume the punctuator

        match punc {
            // Increment  +(expr)
            Jpunc::Plus => {
                let jock = self.match_block_inner(Jpunc::LParen, Jpunc::RParen, |p| {
                    p.match_inner_jock()
                })?;
                Ok(Jock::Increment {
                    val: Box::new(jock),
                })
            }

            // Cell-check  ?(expr)
            Jpunc::Question => {
                let jock = self.match_block_inner(Jpunc::LParen, Jpunc::RParen, |p| {
                    p.match_inner_jock()
                })?;
                Ok(Jock::CellCheck {
                    val: Box::new(jock),
                })
            }

            // Recur  $ or $(expr)
            Jpunc::Dollar => {
                if !self.has_punctuator(Jpunc::LParen) {
                    return Ok(Jock::Call {
                        func: Box::new(Jock::Limb(vec![Jlimb::Axis(0)])),
                        arg: None,
                    });
                }
                if self.has_punctuator_at(1, Jpunc::RParen) {
                    self.pos += 2; // skip '(' ')'
                    return Ok(Jock::Call {
                        func: Box::new(Jock::Limb(vec![Jlimb::Axis(0)])),
                        arg: None,
                    });
                }
                let arg = self.match_block_inner(Jpunc::LParen, Jpunc::RParen, |p| {
                    p.match_inner_jock()
                })?;
                Ok(Jock::Call {
                    func: Box::new(Jock::Limb(vec![Jlimb::Axis(0)])),
                    arg: Some(Box::new(arg)),
                })
            }

            // Axis address  &N
            Jpunc::Ampersand => {
                let axis = self.match_axis()?;
                let limbs = vec![axis];

                if self.at_end() || !self.has_punctuator(Jpunc::LParen) {
                    return Ok(Jock::Limb(limbs));
                }

                let arg = self.match_block_inner(Jpunc::LParen, Jpunc::RParen, |p| {
                    p.match_inner_jock()
                })?;
                Ok(Jock::Call {
                    func: Box::new(Jock::Limb(limbs)),
                    arg: Some(Box::new(arg)),
                })
            }

            // Set  {expr expr ...}
            Jpunc::LBrace => {
                let jock_one = self.match_inner_jock()?;
                let mut elements = vec![jock_one];

                while !self.has_punctuator(Jpunc::RBrace) {
                    elements.push(self.match_inner_jock()?);
                }
                self.pos += 1; // consume '}'

                Ok(Jock::Set {
                    typ: JypeLeaf::None { name: None },
                    val: elements,
                })
            }

            // Tuple  (expr expr) or anonymous lambda (params) -> ret { body }
            Jpunc::LParen => {
                // Check if this is an anonymous lambda: (params) -> ret { body }
                // by scanning ahead to find the matching ')' and checking for '->'
                if self.is_lambda_ahead() {
                    // Back up to include the '(' we consumed
                    self.pos -= 1;
                    let lambda = self.match_lambda_from_paren()?;

                    if self.at_end() || !self.has_punctuator(Jpunc::LParen) {
                        return Ok(Jock::Lambda(lambda));
                    }

                    // Immediate call: lambda(...)
                    self.pos += 1; // consume '('
                    if self.has_punctuator(Jpunc::RParen) {
                        self.pos += 1;
                        return Ok(Jock::Call {
                            func: Box::new(Jock::Lambda(lambda)),
                            arg: None,
                        });
                    }

                    self.pos -= 1;
                    let arg = self.match_pair_inner_jock()?;
                    return Ok(Jock::Call {
                        func: Box::new(Jock::Lambda(lambda)),
                        arg: Some(Box::new(arg)),
                    });
                }

                // Re-insert the '(' and delegate to match_pair_inner_jock
                self.pos -= 1;
                self.match_pair_inner_jock()
            }

            // Lambda call via ((
            Jpunc::DoubleParen => {
                // The DoubleParen was consumed. Parse lambda starting with next token
                // as if the '(' of the lambda args is the current token.
                // Insert a synthetic '(' for match_lambda.
                let lambda = self.match_lambda_from_paren()?;

                if self.at_end() || !self.has_punctuator(Jpunc::DoubleParen) {
                    return Ok(Jock::Lambda(lambda));
                }

                // Chained call: lambda((args)
                self.pos += 1; // consume '(('
                if self.has_punctuator(Jpunc::RParen) {
                    self.pos += 1;
                    return Ok(Jock::Call {
                        func: Box::new(Jock::Lambda(lambda)),
                        arg: None,
                    });
                }

                // Re-insert '(' for pair parsing
                let arg = self.match_call_arg()?;
                self.expect_punctuator(Jpunc::RParen)?;
                Ok(Jock::Call {
                    func: Box::new(Jock::Lambda(lambda)),
                    arg: Some(Box::new(arg)),
                })
            }

            // List  [expr expr ...]
            Jpunc::LBracket => {
                let jock_one = self.match_inner_jock()?;
                let mut elements = vec![jock_one];

                while !self.has_punctuator(Jpunc::RBracket) {
                    elements.push(self.match_inner_jock()?);
                }
                self.pos += 1; // consume ']'

                // Lists are null-terminated with [%atom %number 0]
                elements.push(Jock::Atom(Jatom {
                    variant: AtomVariant::Number(0),
                    constant: false,
                }));

                Ok(Jock::List {
                    typ: JypeLeaf::None { name: None },
                    val: elements,
                })
            }

            _ => Err(ParseError {
                kind: ParseErrorKind::UnexpectedToken {
                    expected: "start-punctuator".into(),
                    found: Some(Token::Punctuator(punc)),
                },
                position: self.pos - 1,
            }),
        }
    }

    // ── match-axis (lines 658-664) ──────────────────────────────

    fn match_axis(&mut self) -> Result<Jlimb, ParseError> {
        // Current token should be a number literal
        match self.peek() {
            Some(Token::Literal(atom)) => {
                if let AtomVariant::Number(n) = &atom.variant {
                    let n = *n;
                    self.pos += 1;
                    Ok(Jlimb::Axis(n))
                } else {
                    Err(self.error("numeric axis".into()))
                }
            }
            _ => Err(self.error("numeric axis".into())),
        }
    }

    // ── match-start-name (lines 666-726) ────────────────────────

    fn match_start_name(&mut self) -> Result<Jock, ParseError> {
        if self.at_end() {
            return Err(self.error("name expression".into()));
        }

        let name = match self.peek() {
            Some(Token::Name(n)) => n.clone(),
            Some(Token::Type(t)) => t.clone(),
            _ => return Err(self.error("name or type".into())),
        };
        self.pos += 1;

        let mut limbs: Vec<Jlimb> = vec![Self::make_jlimb(&name)];

        // No more tokens
        if self.at_end() {
            return Ok(Jock::Limb(limbs));
        }

        // ';' — end of expression (consumed outside)
        if self.has_punctuator(Jpunc::Semicolon) {
            return Ok(Jock::Limb(limbs));
        }

        // Wing chain: name.name.name...
        if self.has_punctuator(Jpunc::Dot) {
            let mut extra = Vec::new();
            while self.has_punctuator(Jpunc::Dot) {
                self.pos += 1; // consume '.'
                match self.peek().and_then(Self::get_name) {
                    Some(n) => {
                        extra.push(Self::make_jlimb(&n));
                        self.pos += 1;
                    }
                    None => return Err(self.error("name in wing".into())),
                }
            }
            // Prepend original name to wing
            limbs = std::iter::once(Self::make_jlimb(&name))
                .chain(extra)
                .collect();
        }

        // Edit: name = val; next
        if self.has_punctuator(Jpunc::Equals) {
            // Check for '==' (comparator, not edit)
            if self.has_punctuator_at(1, Jpunc::Equals) {
                return Ok(Jock::Limb(limbs));
            }

            self.pos += 1; // consume '='
            let val = self.match_inner_jock()?;
            self.expect_punctuator(Jpunc::Semicolon)?;
            let next = self.match_jock()?;
            return Ok(Jock::Edit {
                limb: limbs,
                val: Box::new(val),
                next: Box::new(next),
            });
        }

        // Call: name(( or name(
        if self.has_punctuator(Jpunc::DoubleParen) || self.has_punctuator(Jpunc::LParen) {
            // Check for empty call: name()
            if self.has_punctuator_at(1, Jpunc::RParen) {
                self.pos += 2; // skip '((' or '(' and ')'
                return Ok(Jock::Call {
                    func: Box::new(Jock::Limb(limbs)),
                    arg: None,
                });
            }

            // Normalize DoubleParen to LParen for argument parsing
            if self.has_punctuator(Jpunc::DoubleParen) {
                // DoubleParen consumed, treat next tokens as inside parens
                self.pos += 1;
            }

            let arg = self.match_call_arg()?;
            return Ok(Jock::Call {
                func: Box::new(Jock::Limb(limbs)),
                arg: Some(Box::new(arg)),
            });
        }

        Ok(Jock::Limb(limbs))
    }

    /// Parse a function call argument list.
    /// Handles single and multi-arg calls: `(a)`, `(a b)`.
    fn match_call_arg(&mut self) -> Result<Jock, ParseError> {
        // We're positioned at the '(' (or just after DoubleParen)
        // Check if current is '(' — if so, delegate to match_pair_inner_jock
        if self.has_punctuator(Jpunc::LParen) {
            return self.match_pair_inner_jock();
        }

        // We got here from DoubleParen — read inner exprs until ')'
        let jock_one = self.match_inner_jock()?;
        if self.has_punctuator(Jpunc::RParen) {
            self.pos += 1;
            return Ok(jock_one);
        }

        let mut parts = vec![jock_one];
        while !self.has_punctuator(Jpunc::RParen) {
            parts.push(self.match_inner_jock()?);
        }
        self.pos += 1; // consume ')'

        Ok(Self::build_cell(parts))
    }

    // ── match-keyword (lines 777-1029) ──────────────────────────

    fn match_keyword(&mut self) -> Result<Jock, ParseError> {
        if self.at_end() {
            return Err(self.error("keyword".into()));
        }

        let kw = match self.peek() {
            Some(Token::Keyword(k)) => *k,
            _ => return Err(self.error("keyword".into())),
        };
        self.pos += 1; // consume keyword

        match kw {
            // let name:Type = val; next
            Keyword::Let => {
                let typ = self.match_jype()?;
                self.expect_punctuator(Jpunc::Equals)?;
                let val = self.match_jock()?;
                self.expect_punctuator(Jpunc::Semicolon)?;
                let next = self.match_jock()?;
                Ok(Jock::Let {
                    typ,
                    val: Box::new(val),
                    next: Box::new(next),
                })
            }

            // func name(args) -> RetType { body }; next
            Keyword::Func => {
                let type_name = self.match_jype()?;
                let inp = self.match_block_inner(Jpunc::DoubleParen, Jpunc::RParen, |p| {
                    p.match_jype()
                })?;
                self.expect_punctuator(Jpunc::Minus)?;
                self.expect_punctuator(Jpunc::GreaterThan)?;
                let out = self.match_jype()?;
                let body = self.match_block_inner(Jpunc::LBrace, Jpunc::RBrace, |p| {
                    p.match_jock_body(Jpunc::RBrace)
                })?;
                self.expect_punctuator(Jpunc::Semicolon)?;
                let next = self.match_jock()?;

                let func_type = Jype::leaf(
                    JypeLeaf::Core {
                        body: CoreBody::lambda(LambdaArgument::new(
                            Some(inp.clone()),
                            out.clone(),
                        )),
                        context: None,
                    },
                    type_name.name().to_string(),
                );

                let func_body = Jock::Lambda(Lambda {
                    arg: LambdaArgument::new(Some(inp), out),
                    body: Box::new(body),
                    context: None,
                });

                Ok(Jock::Func {
                    typ: func_type,
                    body: Box::new(func_body),
                    next: Box::new(next),
                })
            }

            // lambda (args) -> RetType { body }
            Keyword::Lambda => {
                // The '(' for args should be current; match_lambda expects it
                let lambda = self.match_lambda_from_paren()?;

                if self.at_end() {
                    return Ok(Jock::Lambda(lambda));
                }

                // Check for immediate call: lambda(...)(...args)
                if !self.has_punctuator(Jpunc::LParen) {
                    return Ok(Jock::Lambda(lambda));
                }

                self.pos += 1; // consume '('
                if self.has_punctuator(Jpunc::RParen) {
                    self.pos += 1;
                    return Ok(Jock::Call {
                        func: Box::new(Jock::Lambda(lambda)),
                        arg: None,
                    });
                }

                // Re-insert '(' for pair parsing
                self.pos -= 1;
                let arg = self.match_pair_inner_jock()?;
                Ok(Jock::Call {
                    func: Box::new(Jock::Lambda(lambda)),
                    arg: Some(Box::new(arg)),
                })
            }

            // class Name(state) { methods }
            Keyword::Class => {
                let state = self.match_jype()?;

                // Check reserved types
                let state_name = state.name().to_string();
                if state_name == "List" || state_name == "Set" {
                    return Err(ParseError {
                        kind: ParseErrorKind::ReservedType(state_name),
                        position: self.pos,
                    });
                }

                self.expect_punctuator(Jpunc::LBrace)?;
                let mut arms: Vec<(String, Jock)> = Vec::new();

                while !self.has_punctuator(Jpunc::RBrace) {
                    // Parse method: name(args) -> RetType { body }
                    let method_type = self.match_jype()?;

                    // Parse args
                    self.expect_punctuator(Jpunc::DoubleParen)?;
                    let mut inp = self.match_jype()?;

                    // Check for second type (cell pair)
                    if !self.has_punctuator(Jpunc::RParen) {
                        let jyp_two = self.match_jype()?;
                        inp = Jype::Cell {
                            p: Box::new(inp),
                            q: Box::new(jyp_two),
                            name: String::new(),
                        };
                    }
                    self.expect_punctuator(Jpunc::RParen)?;

                    // ->
                    self.expect_punctuator(Jpunc::Minus)?;
                    self.expect_punctuator(Jpunc::GreaterThan)?;

                    let out = self.match_jype()?;

                    let core_type = Jype::leaf(
                        JypeLeaf::Core {
                            body: CoreBody::lambda(LambdaArgument::new(
                                Some(inp.clone()),
                                out.clone(),
                            )),
                            context: None,
                        },
                        method_type.name().to_string(),
                    );

                    // Parse body
                    let body = self.match_block_inner(Jpunc::LBrace, Jpunc::RBrace, |p| {
                        p.match_jock()
                    })?;

                    let method_body = Jock::Lambda(Lambda {
                        arg: LambdaArgument::new(Some(inp), out),
                        body: Box::new(body),
                        context: None,
                    });

                    arms.push((
                        method_type.name().to_string(),
                        Jock::Method {
                            typ: core_type,
                            body: Box::new(method_body),
                        },
                    ));
                }
                self.pos += 1; // consume '}'

                Ok(Jock::Class { state, arms })
            }

            // if cond { then } else/else-if ...
            Keyword::If => {
                let cond = self.match_inner_jock()?;
                let then = self.match_block_inner(Jpunc::LBrace, Jpunc::RBrace, |p| {
                    p.match_jock()
                })?;
                let after = self.match_after_if()?;
                Ok(Jock::If {
                    cond: Box::new(cond),
                    then: Box::new(then),
                    after,
                })
            }

            // assert cond; then
            Keyword::Assert => {
                let cond = self.match_inner_jock()?;
                self.expect_punctuator(Jpunc::Semicolon)?;
                let then = self.match_jock()?;
                Ok(Jock::Assert {
                    cond: Box::new(cond),
                    then: Box::new(then),
                })
            }

            // with context; obj-or-lambda
            Keyword::With => {
                let context = self.match_inner_jock()?;
                self.expect_punctuator(Jpunc::Semicolon)?;
                let mut obj_or_lambda = self.match_jock()?;

                // Attach context to object or lambda
                match &mut obj_or_lambda {
                    Jock::Object { q, .. } => {
                        *q = Some(Box::new(context));
                    }
                    Jock::Lambda(lambda) => {
                        lambda.context = Some(Box::new(context));
                    }
                    _ => return Err(self.error("object or lambda after 'with'".into())),
                }

                Ok(obj_or_lambda)
            }

            // object [Name] { field = val ... }
            Keyword::Object => {
                let name = self
                    .peek()
                    .and_then(Self::get_name)
                    .unwrap_or_default();
                if self.peek().and_then(Self::get_name).is_some() {
                    self.pos += 1;
                }

                self.expect_punctuator(Jpunc::LBrace)?;
                let mut fields: Vec<(String, Jock)> = Vec::new();

                while !self.has_punctuator(Jpunc::RBrace) {
                    let field_name = match self.peek().and_then(Self::get_name) {
                        Some(n) => n,
                        None => return Err(self.error("field name".into())),
                    };
                    self.pos += 1;
                    self.expect_punctuator(Jpunc::Equals)?;
                    let val = self.match_jock()?;
                    fields.push((field_name, val));
                }
                self.pos += 1; // consume '}'

                Ok(Jock::Object {
                    name,
                    p: fields,
                    q: None,
                })
            }

            // compose p; q
            Keyword::Compose => {
                let p = self.match_inner_jock()?;
                self.expect_punctuator(Jpunc::Semicolon)?;
                let q = self.match_jock()?;
                Ok(Jock::Compose {
                    p: Box::new(p),
                    q: Box::new(q),
                })
            }

            // match value { cases }
            Keyword::Match => {
                let value = self.match_inner_jock()?;
                let (cases, default) = self.match_block_inner(
                    Jpunc::LBrace,
                    Jpunc::RBrace,
                    |p| p.match_match_cases(),
                )?;
                Ok(Jock::Match {
                    value: Box::new(value),
                    cases,
                    default,
                })
            }

            // switch value { cases }
            Keyword::Switch => {
                let value = self.match_inner_jock()?;
                let (cases, default) = self.match_block_inner(
                    Jpunc::LBrace,
                    Jpunc::RBrace,
                    |p| p.match_match_cases(),
                )?;
                Ok(Jock::Switch {
                    value: Box::new(value),
                    cases,
                    default,
                })
            }

            // loop; next  /  defer; next
            Keyword::Loop => {
                self.expect_punctuator(Jpunc::Semicolon)?;
                let next = self.match_jock()?;
                Ok(Jock::Loop {
                    next: Box::new(next),
                })
            }

            Keyword::Defer => {
                self.expect_punctuator(Jpunc::Semicolon)?;
                let next = self.match_jock()?;
                Ok(Jock::Defer {
                    next: Box::new(next),
                })
            }

            // recur = $
            Keyword::Recur => {
                if !self.has_punctuator(Jpunc::LParen) {
                    return Ok(Jock::Call {
                        func: Box::new(Jock::Limb(vec![Jlimb::Axis(0)])),
                        arg: None,
                    });
                }
                if self.has_punctuator_at(1, Jpunc::RParen) {
                    self.pos += 2;
                    return Ok(Jock::Call {
                        func: Box::new(Jock::Limb(vec![Jlimb::Axis(0)])),
                        arg: None,
                    });
                }
                self.pos += 1; // consume '('
                let arg = self.match_inner_jock()?;
                self.expect_punctuator(Jpunc::RParen)?;
                Ok(Jock::Call {
                    func: Box::new(Jock::Limb(vec![Jlimb::Axis(0)])),
                    arg: Some(Box::new(arg)),
                })
            }

            // this = limb axis 1
            Keyword::This => Ok(Jock::Limb(vec![Jlimb::Axis(1)])),

            // eval p q
            Keyword::Eval => {
                let p = self.match_inner_jock()?;
                let q = self.match_jock()?;
                Ok(Jock::Eval {
                    p: Box::new(p),
                    q: Box::new(q),
                })
            }

            // import name [as alias]; next
            Keyword::Import => {
                let nom = match self.peek() {
                    Some(Token::Name(n)) => n.clone(),
                    _ => return Err(self.error("import name".into())),
                };
                self.pos += 1;

                let mut alias = nom.clone();

                // Optional: as alias
                if self.has_keyword(Keyword::As) {
                    self.pos += 1; // consume 'as'
                    alias = match self.peek() {
                        Some(Token::Name(n)) => n.clone(),
                        _ => return Err(self.error("alias name".into())),
                    };
                    self.pos += 1;
                }

                self.expect_punctuator(Jpunc::Semicolon)?;
                let next = self.match_jock()?;

                // Build a placeholder type for the import
                let import_type = Jype::leaf(
                    JypeLeaf::None { name: None },
                    alias,
                );

                Ok(Jock::Import {
                    name: import_type,
                    next: Box::new(next),
                })
            }

            // print(expr); next
            Keyword::Print => {
                let body = self.match_block_inner(Jpunc::LParen, Jpunc::RParen, |p| {
                    p.match_inner_jock()
                })?;
                self.expect_punctuator(Jpunc::Semicolon)?;
                let next = self.match_jock()?;
                Ok(Jock::Print {
                    body: Box::new(body),
                    next: Box::new(next),
                })
            }

            // crash
            Keyword::Crash => Ok(Jock::Crash),

            _ => Err(ParseError {
                kind: ParseErrorKind::UnexpectedToken {
                    expected: "handled keyword".into(),
                    found: Some(Token::Keyword(kw)),
                },
                position: self.pos - 1,
            }),
        }
    }

    // ── match-jock-body (lines 519-536) ─────────────────────────

    /// Parse a jock expression used as a function body.
    /// Similar to match_jock but does not consume the end delimiter.
    fn match_jock_body(&mut self, end: Jpunc) -> Result<Jock, ParseError> {
        if self.at_end() {
            return Err(self.error("jock body".into()));
        }
        if self.has_punctuator(end) {
            return Err(self.error("non-empty jock body".into()));
        }

        match self.peek().unwrap() {
            Token::Literal(_) => self.match_literal(),
            Token::Name(_) => self.match_start_name(),
            Token::Keyword(_) => self.match_keyword(),
            Token::Punctuator(_) => self.match_start_punctuator(),
            Token::Type(_) => self.match_start_name(),
        }
    }

    // ── match-literal (lines 1219-1225) ─────────────────────────

    fn match_literal(&mut self) -> Result<Jock, ParseError> {
        match self.peek() {
            Some(Token::Literal(atom)) => {
                let atom = atom.clone();
                self.pos += 1;
                Ok(Jock::Atom(atom))
            }
            _ => Err(self.error("literal".into())),
        }
    }

    // ── match-lambda (lines 1115-1123) ──────────────────────────

    /// Parse a lambda expression starting from the '(' of the argument list.
    fn match_lambda_from_paren(&mut self) -> Result<Lambda, ParseError> {
        let arg = self.match_lambda_argument()?;
        let body = self.match_block_inner(Jpunc::LBrace, Jpunc::RBrace, |p| p.match_jock())?;
        Ok(Lambda {
            arg,
            body: Box::new(body),
            context: None,
        })
    }

    // ── match-lambda-argument (lines 1125-1136) ─────────────────

    fn match_lambda_argument(&mut self) -> Result<LambdaArgument, ParseError> {
        self.expect_punctuator(Jpunc::LParen)?;

        // Check for no-arg lambda: () -> out
        if self.has_punctuator(Jpunc::RParen) {
            self.pos += 1;
            self.expect_punctuator(Jpunc::Minus)?;
            self.expect_punctuator(Jpunc::GreaterThan)?;
            let out = self.match_jype()?;
            return Ok(LambdaArgument::new(None, out));
        }

        let inp = self.match_jype()?;

        // Form 2: arrow inside parens — (input -> output)
        if self.has_punctuator(Jpunc::Minus) && self.has_punctuator_at(1, Jpunc::GreaterThan) {
            self.pos += 2; // consume '->'
            let out = self.match_jype()?;
            self.expect_punctuator(Jpunc::RParen)?;
            return Ok(LambdaArgument::new(Some(inp), out));
        }

        // Form 1: arrow after parens — (input) -> output
        self.expect_punctuator(Jpunc::RParen)?;
        self.expect_punctuator(Jpunc::Minus)?;
        self.expect_punctuator(Jpunc::GreaterThan)?;
        let out = self.match_jype()?;
        Ok(LambdaArgument::new(Some(inp), out))
    }

    // ── match-jype (lines 1033-1072) ────────────────────────────

    fn match_jype(&mut self) -> Result<Jype, ParseError> {
        if self.at_end() {
            return Err(self.error("type".into()));
        }

        // Check for name
        let has_name = self.peek().and_then(Self::get_name).is_some();
        let nom = self
            .peek()
            .and_then(Self::get_name)
            .unwrap_or_default();

        if has_name {
            self.pos += 1;
        }

        // Type-qualified name:  name:Type  or  name:@
        if has_name && self.has_punctuator(Jpunc::Colon) {
            self.pos += 1; // consume ':'

            // Check if next is a Type token (metatype like List, Set)
            if matches!(self.peek(), Some(Token::Type(_))) {
                let mut jyp = self.match_metatype()?;
                jyp = jyp.with_name(nom);
                return Ok(jyp);
            }

            let mut jyp = self.match_jype()?;
            jyp = jyp.with_name(nom);
            return Ok(jyp);
        }

        // Tuple cell  (a b)
        if self.has_punctuator(Jpunc::LParen) {
            self.pos += 1; // consume '('
            let jyp_one = self.match_jype()?;
            if self.has_punctuator(Jpunc::RParen) {
                self.pos += 1;
                return Ok(jyp_one);
            }
            let jyp_two = self.match_jype()?;
            self.expect_punctuator(Jpunc::RParen)?;
            return Ok(Jype::Cell {
                p: Box::new(jyp_one),
                q: Box::new(jyp_two),
                name: nom,
            });
        }

        // If non-empty name is a type, match as metatype
        if !nom.is_empty() && Self::is_type_name(&nom) {
            // Re-insert the type token so match_metatype can process it
            self.pos -= 1;
            let jyp = self.match_metatype()?;
            return Ok(jyp);
        }

        // Match leaf type
        let leaf = self.match_jype_leaf()?;
        Ok(Jype::leaf(leaf, nom))
    }

    // ── match-jype-leaf (lines 1076-1113) ───────────────────────

    fn match_jype_leaf(&mut self) -> Result<JypeLeaf, ParseError> {
        if self.at_end() {
            return Ok(JypeLeaf::None { name: None });
        }

        // @  →  atom number
        if self.has_punctuator(Jpunc::At) {
            self.pos += 1;
            return Ok(JypeLeaf::Atom {
                typ: JatomType::Number,
                constant: false,
            });
        }

        // ?  →  atom loobean
        if self.has_punctuator(Jpunc::Question) {
            self.pos += 1;
            return Ok(JypeLeaf::Atom {
                typ: JatomType::Loobean,
                constant: false,
            });
        }

        // *  →  none (noun)
        if self.has_punctuator(Jpunc::Star) {
            self.pos += 1;
            return Ok(JypeLeaf::None { name: None });
        }

        // #  →  none with placeholder
        if self.has_punctuator(Jpunc::Hash) {
            self.pos += 1;
            return Ok(JypeLeaf::None {
                name: Some(String::new()),
            });
        }

        // (  →  core (lambda definition)
        if self.has_punctuator(Jpunc::LParen) {
            let arg = self.match_lambda_argument()?;
            return Ok(JypeLeaf::Core {
                body: CoreBody::lambda(arg),
                context: None,
            });
        }

        // Name or Type limb
        if let Some(nom) = self.peek().and_then(Self::get_name) {
            self.pos += 1;
            return Ok(JypeLeaf::Limb(vec![Self::make_jlimb(&nom)]));
        }

        // Axis (&N)
        if self.has_punctuator(Jpunc::Ampersand) {
            self.pos += 1;
            let axis = self.match_axis()?;
            return Ok(JypeLeaf::Limb(vec![axis]));
        }

        Ok(JypeLeaf::None { name: None })
    }

    // ── match-metatype (lines 736-775) ──────────────────────────

    fn match_metatype(&mut self) -> Result<Jype, ParseError> {
        if self.at_end() {
            return Err(self.error("type".into()));
        }

        let type_tok = match self.peek() {
            Some(Token::Type(t)) => t.clone(),
            _ => return Err(self.error("type name".into())),
        };

        let nom = match self.peek().and_then(Self::get_name) {
            Some(n) => n,
            None => return Err(self.error("name".into())),
        };

        // Short-circuit for primitive types
        match type_tok.as_str() {
            "Atom" | "Uint" => {
                self.pos += 1;
                return Ok(Jype::leaf(
                    JypeLeaf::Atom { typ: JatomType::Number, constant: false },
                    nom,
                ));
            }
            "Uhex" => {
                self.pos += 1;
                return Ok(Jype::leaf(
                    JypeLeaf::Atom { typ: JatomType::Hexadecimal, constant: false },
                    nom,
                ));
            }
            "String" => {
                self.pos += 1;
                return Ok(Jype::leaf(
                    JypeLeaf::Atom { typ: JatomType::String, constant: false },
                    nom,
                ));
            }
            "Loob" => {
                self.pos += 1;
                return Ok(Jype::leaf(
                    JypeLeaf::Atom { typ: JatomType::Loobean, constant: false },
                    nom,
                ));
            }
            _ => {}
        }

        // Determine container type
        let container = match type_tok.as_str() {
            "List" => Some("list"),
            "Set" => Some("set"),
            _ => None,
        };

        self.pos += 1; // consume the type token

        // If no '((' follows, it's a limb reference
        if !self.has_punctuator(Jpunc::DoubleParen) {
            return Ok(Jype::leaf(
                JypeLeaf::Limb(vec![Jlimb::Type(type_tok)]),
                nom,
            ));
        }

        // Parse type arguments: ((type))
        self.pos += 1; // consume '(('
        let jyp_one = self.match_jype()?;

        let jyp = if self.has_punctuator(Jpunc::RParen) {
            jyp_one
        } else {
            let jyp_two = self.match_jype()?;
            Jype::Cell {
                p: Box::new(jyp_one),
                q: Box::new(jyp_two),
                name: String::new(),
            }
        };

        self.expect_punctuator(Jpunc::RParen)?;

        match container {
            Some("list") => Ok(Jype::leaf(
                JypeLeaf::List { typ: Box::new(jyp) },
                nom,
            )),
            Some("set") => Ok(Jype::leaf(
                JypeLeaf::Set { typ: Box::new(jyp) },
                nom,
            )),
            _ => Ok(Jype::leaf(
                JypeLeaf::State { p: Box::new(jyp) },
                nom,
            )),
        }
    }

    // ── match-comparator (lines 1138-1161) ──────────────────────

    fn match_comparator(&mut self) -> Result<Comparator, ParseError> {
        if self.at_end() {
            return Err(self.error("comparator".into()));
        }

        let p1 = match self.peek() {
            Some(Token::Punctuator(p)) => *p,
            _ => return Err(self.error("comparator punctuator".into())),
        };
        self.pos += 1;

        // Check for two-character comparators
        if let Some(Token::Punctuator(p2)) = self.peek() {
            let p2 = *p2;
            match (p1, p2) {
                (Jpunc::Equals, Jpunc::Equals) => {
                    self.pos += 1;
                    return Ok(Comparator::Eq);
                }
                (Jpunc::Bang, Jpunc::Equals) => {
                    self.pos += 1;
                    return Ok(Comparator::Ne);
                }
                (Jpunc::LessThan, Jpunc::Equals) => {
                    self.pos += 1;
                    return Ok(Comparator::Le);
                }
                (Jpunc::GreaterThan, Jpunc::Equals) => {
                    self.pos += 1;
                    return Ok(Comparator::Ge);
                }
                _ => {}
            }
        }

        // Single character comparators
        match p1 {
            Jpunc::LessThan => Ok(Comparator::Lt),
            Jpunc::GreaterThan => Ok(Comparator::Gt),
            _ => Err(ParseError {
                kind: ParseErrorKind::UnexpectedToken {
                    expected: "comparator".into(),
                    found: Some(Token::Punctuator(p1)),
                },
                position: self.pos - 1,
            }),
        }
    }

    // ── match-operator (lines 1163-1186) ────────────────────────

    fn match_operator(&mut self) -> Result<Operator, ParseError> {
        if self.at_end() {
            return Err(self.error("operator".into()));
        }

        let p1 = match self.peek() {
            Some(Token::Punctuator(p)) => *p,
            _ => return Err(self.error("operator punctuator".into())),
        };
        self.pos += 1;

        // Check for ** (power)
        if p1 == Jpunc::Star {
            if let Some(Token::Punctuator(Jpunc::Star)) = self.peek() {
                self.pos += 1;
                return Ok(Operator::Pow);
            }
        }

        match p1 {
            Jpunc::Plus => Ok(Operator::Add),
            Jpunc::Minus => Ok(Operator::Sub),
            Jpunc::Star => Ok(Operator::Mul),
            Jpunc::Slash => Ok(Operator::Div),
            Jpunc::Percent => Ok(Operator::Mod),
            _ => Err(ParseError {
                kind: ParseErrorKind::UnexpectedToken {
                    expected: "operator".into(),
                    found: Some(Token::Punctuator(p1)),
                },
                position: self.pos - 1,
            }),
        }
    }

    // ── match-after-if (lines 1188-1217) ────────────────────────

    fn match_after_if(&mut self) -> Result<AfterIf, ParseError> {
        if !self.has_keyword(Keyword::Else) {
            return Err(self.error("'else'".into()));
        }
        self.pos += 1; // consume 'else'

        // else { ... }
        if self.has_punctuator(Jpunc::LBrace) {
            let then =
                self.match_block_inner(Jpunc::LBrace, Jpunc::RBrace, |p| p.match_jock())?;
            return Ok(AfterIf::Else {
                then: Box::new(then),
            });
        }

        // else if cond { ... } ...
        if !self.has_keyword(Keyword::If) {
            return Err(self.error("'if' or '{'".into()));
        }
        self.pos += 1; // consume 'if'

        let cond = self.match_inner_jock()?;
        let then =
            self.match_block_inner(Jpunc::LBrace, Jpunc::RBrace, |p| p.match_jock())?;
        let after = self.match_after_if()?;

        Ok(AfterIf::ElseIf {
            cond: Box::new(cond),
            then: Box::new(then),
            after: Box::new(after),
        })
    }

    // ── match-match (lines 1242-1273) ───────────────────────────

    fn match_match_cases(
        &mut self,
    ) -> Result<(Vec<(Jock, Jock)>, Option<Box<Jock>>), ParseError> {
        let mut cases = Vec::new();
        let mut default = None;

        while !self.has_punctuator(Jpunc::RBrace) {
            // Default case: _ -> expr;
            if self.has_punctuator(Jpunc::Underscore) {
                self.pos += 1; // consume '_'
                self.expect_punctuator(Jpunc::Minus)?;
                self.expect_punctuator(Jpunc::GreaterThan)?;
                let jock = self.match_jock()?;
                self.expect_punctuator(Jpunc::Semicolon)?;
                default = Some(Box::new(jock));
                // Default must be last — expect '}'
                if !self.has_punctuator(Jpunc::RBrace) {
                    return Err(self.error("'}' after default case".into()));
                }
                break;
            }

            // Regular case: expr -> expr;
            let key = self.match_jock()?;
            self.expect_punctuator(Jpunc::Minus)?;
            self.expect_punctuator(Jpunc::GreaterThan)?;
            let val = self.match_jock()?;
            self.expect_punctuator(Jpunc::Semicolon)?;
            cases.push((key, val));
        }

        Ok((cases, default))
    }

    // ── match-block (lines 1234-1240) ───────────────────────────

    /// Generic delimited block parser.  Consumes `start`, calls `f`,
    /// then consumes `end`.
    fn match_block_inner<T>(
        &mut self,
        start: Jpunc,
        end: Jpunc,
        f: impl FnOnce(&mut Self) -> Result<T, ParseError>,
    ) -> Result<T, ParseError> {
        self.expect_punctuator(start)?;
        let result = f(self)?;
        self.expect_punctuator(end)?;
        Ok(result)
    }

    // ── any-operator (lines 1354-1382) ──────────────────────────

    /// Try to detect an infix operator at the current position.
    /// Returns (operator_string, is_comparator, is_operator) and advances
    /// past the consumed tokens on success.
    fn any_operator(&mut self) -> Option<(String, bool, bool)> {
        let p1 = match self.peek() {
            Some(Token::Punctuator(p)) => *p,
            _ => return None,
        };

        // Two-token operators
        if let Some(Token::Punctuator(p2)) = self.peek_at(1) {
            let p2 = *p2;
            match (p1, p2) {
                (Jpunc::Equals, Jpunc::Equals) => {
                    self.pos += 2;
                    return Some(("==".into(), true, false));
                }
                (Jpunc::LessThan, Jpunc::Equals) => {
                    self.pos += 2;
                    return Some(("<=".into(), true, false));
                }
                (Jpunc::GreaterThan, Jpunc::Equals) => {
                    self.pos += 2;
                    return Some((">=".into(), true, false));
                }
                (Jpunc::Bang, Jpunc::Equals) => {
                    self.pos += 2;
                    return Some(("!=".into(), true, false));
                }
                (Jpunc::Star, Jpunc::Star) => {
                    self.pos += 2;
                    return Some(("**".into(), false, true));
                }
                _ => {}
            }
        }

        // Single-token operators
        match p1 {
            Jpunc::LessThan => {
                self.pos += 1;
                Some(("<".into(), true, false))
            }
            Jpunc::GreaterThan => {
                self.pos += 1;
                Some((">".into(), true, false))
            }
            Jpunc::Plus => {
                self.pos += 1;
                Some(("+".into(), false, true))
            }
            Jpunc::Minus => {
                self.pos += 1;
                Some(("-".into(), false, true))
            }
            Jpunc::Star => {
                self.pos += 1;
                Some(("*".into(), false, true))
            }
            Jpunc::Slash => {
                self.pos += 1;
                Some(("/".into(), false, true))
            }
            Jpunc::Percent => {
                self.pos += 1;
                Some(("%".into(), false, true))
            }
            _ => None,
        }
    }

    // ── Helper: is_comparator_ahead / is_operator_ahead ─────────

    fn is_comparator_ahead(&self) -> bool {
        match self.peek() {
            Some(Token::Punctuator(Jpunc::LessThan)) => true,
            Some(Token::Punctuator(Jpunc::GreaterThan)) => true,
            Some(Token::Punctuator(Jpunc::Equals)) => {
                self.has_punctuator_at(1, Jpunc::Equals)
            }
            Some(Token::Punctuator(Jpunc::Bang)) => {
                self.has_punctuator_at(1, Jpunc::Equals)
            }
            _ => false,
        }
    }

    fn is_operator_ahead(&self) -> bool {
        matches!(
            self.peek(),
            Some(Token::Punctuator(
                Jpunc::Plus
                    | Jpunc::Minus
                    | Jpunc::Star
                    | Jpunc::Slash
                    | Jpunc::Percent
            ))
        )
    }

    fn parse_comparator_from_str(s: &str) -> Comparator {
        match s {
            "<" => Comparator::Lt,
            ">" => Comparator::Gt,
            "==" => Comparator::Eq,
            "!=" => Comparator::Ne,
            "<=" => Comparator::Le,
            ">=" => Comparator::Ge,
            _ => unreachable!("invalid comparator: {}", s),
        }
    }

    fn parse_operator_from_str(s: &str) -> Operator {
        match s {
            "+" => Operator::Add,
            "-" => Operator::Sub,
            "*" => Operator::Mul,
            "/" => Operator::Div,
            "%" => Operator::Mod,
            "**" => Operator::Pow,
            _ => unreachable!("invalid operator: {}", s),
        }
    }
}
