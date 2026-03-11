use crate::error::{ErrorKind, LexError, Position};
use crate::token::{AtomVariant, Jatom, Jpunc, Keyword, Token, KEYWORDS};

/// A lexer that tokenizes Jock source code.
///
/// Precisely translates the Hoon tokenizer from `jock.hoon` lines 45-219.
pub struct Lexer<'a> {
    input: &'a [u8],
    pos: usize,
    /// Tracks whether the previous token was a Name or Type,
    /// used to synthesize the `((` pseudo-punctuator for function calls.
    fun: bool,
}

impl<'a> Lexer<'a> {
    pub fn new(input: &'a str) -> Self {
        Lexer {
            input: input.as_bytes(),
            pos: 0,
            fun: false,
        }
    }

    fn peek(&self) -> Option<u8> {
        self.input.get(self.pos).copied()
    }

    fn advance(&mut self) {
        self.pos += 1;
    }

    /// Compute a `Position` for the given byte offset.
    fn position_at(&self, offset: usize) -> Position {
        let slice = &self.input[..offset];
        let line = slice.iter().filter(|&&b| b == b'\n').count() + 1;
        let col_start = slice.iter().rposition(|&b| b == b'\n').map_or(0, |i| i + 1);
        Position {
            offset,
            line,
            column: offset - col_start + 1,
        }
    }

    fn error(&self, kind: ErrorKind) -> LexError {
        LexError {
            kind,
            position: self.position_at(self.pos),
        }
    }

    fn error_at(&self, kind: ErrorKind, offset: usize) -> LexError {
        LexError {
            kind,
            position: self.position_at(offset),
        }
    }

    // ---------------------------------------------------------------
    // Whitespace and comment skipping (Hoon: val, var, gav, gae)
    // ---------------------------------------------------------------

    /// Try to skip a line comment `// ... \n`.
    /// Returns `true` if a comment was consumed.
    ///
    /// Corresponds to Hoon `val` (lines 112-116).
    /// The comment MUST end with `\n`. If `//` is present but no `\n`
    /// follows before EOF, the `//` is NOT consumed as a comment.
    fn skip_line_comment(&mut self) -> bool {
        if self.pos + 1 < self.input.len()
            && self.input[self.pos] == b'/'
            && self.input[self.pos + 1] == b'/'
        {
            // Check that there is a newline somewhere after //
            let start = self.pos;
            let mut i = self.pos + 2;
            loop {
                if i >= self.input.len() {
                    // No newline found before EOF — not a valid line comment
                    return false;
                }
                if self.input[i] == b'\n' {
                    self.pos = i + 1; // consume past the newline
                    return true;
                }
                let b = self.input[i];
                // Hoon val allows: prn (0x20..=0x7e) or tab (0x09)
                if (0x20..=0x7e).contains(&b) || b == 0x09 {
                    i += 1;
                } else {
                    // Non-printable, non-tab, non-newline character
                    // Restore and fail
                    self.pos = start;
                    return false;
                }
            }
        }
        false
    }

    /// Try to skip a block comment `/* ... */`.
    /// Returns `Ok(true)` if consumed, `Ok(false)` if not a block comment start,
    /// or `Err` if the block comment is unterminated.
    ///
    /// Corresponds to Hoon `var` (lines 117-121).
    fn skip_block_comment(&mut self) -> Result<bool, LexError> {
        if self.pos + 1 < self.input.len()
            && self.input[self.pos] == b'/'
            && self.input[self.pos + 1] == b'*'
        {
            let start = self.pos;
            let mut i = self.pos + 2;
            loop {
                if i + 1 >= self.input.len() {
                    return Err(self.error_at(ErrorKind::UnterminatedBlockComment, start));
                }
                if self.input[i] == b'*' && self.input[i + 1] == b'/' {
                    self.pos = i + 2;
                    return Ok(true);
                }
                let b = self.input[i];
                // Hoon var allows: prn (0x20..=0x7e), tab (0x09), newline (0x0a)
                if (0x20..=0x7e).contains(&b) || b == 0x09 || b == 0x0a {
                    i += 1;
                } else {
                    return Err(self.error_at(ErrorKind::UnterminatedBlockComment, start));
                }
            }
        }
        Ok(false)
    }

    /// Skip whitespace and comments.
    /// Corresponds to Hoon `gav` (line 122): `(cold ~ (star ;~(pose val var gah)))`.
    fn skip_whitespace_and_comments(&mut self) -> Result<(), LexError> {
        loop {
            // Try line comment
            if self.skip_line_comment() {
                continue;
            }
            // Try block comment
            if self.skip_block_comment()? {
                continue;
            }
            // Try whitespace (gah: space, tab, newline)
            match self.peek() {
                Some(b' ' | b'\t' | b'\n' | b'\r') => {
                    self.advance();
                    continue;
                }
                _ => break,
            }
        }
        Ok(())
    }

    // ---------------------------------------------------------------
    // Token parsers
    // ---------------------------------------------------------------

    /// Try to match a keyword at the current position.
    /// The character after the keyword must NOT be a character that can
    /// continue a name or type (`[a-zA-Z0-9_]`), ensuring keywords are
    /// not matched as prefixes of identifiers.
    ///
    /// Keywords are tried in list order (Hoon lines 167-173).
    fn try_keyword(&mut self) -> Option<Keyword> {
        let remaining = &self.input[self.pos..];
        for &(kw, s) in KEYWORDS {
            let s_bytes = s.as_bytes();
            if remaining.starts_with(s_bytes) {
                // Boundary check: next char must not be [a-zA-Z0-9_]
                let after = self.pos + s_bytes.len();
                if after < self.input.len() {
                    let next = self.input[after];
                    if next.is_ascii_alphanumeric() || next == b'_' {
                        continue;
                    }
                }
                self.pos = after;
                return Some(kw);
            }
        }
        None
    }

    /// Try to parse a boolean literal (`true` or `false`).
    /// Uses `jest` (exact prefix match) — NO boundary check.
    ///
    /// Corresponds to Hoon `loobean` (lines 131-133).
    fn try_boolean(&mut self) -> Option<bool> {
        let remaining = &self.input[self.pos..];
        if remaining.starts_with(b"true") {
            self.pos += 4;
            return Some(true);
        }
        if remaining.starts_with(b"false") {
            self.pos += 5;
            return Some(false);
        }
        None
    }

    /// Try to parse a hexadecimal literal `0x...`.
    ///
    /// Corresponds to Hoon `hexadecimal` (line 130).
    fn try_hexadecimal(&mut self) -> Result<Option<u64>, LexError> {
        let remaining = &self.input[self.pos..];
        if !remaining.starts_with(b"0x") {
            return Ok(None);
        }
        let saved = self.pos;
        self.pos += 2; // skip "0x"

        // Must have at least one hex digit
        let start = self.pos;
        while self.pos < self.input.len() && self.input[self.pos].is_ascii_hexdigit() {
            self.pos += 1;
        }
        if self.pos == start {
            // No hex digits after 0x — backtrack fully
            self.pos = saved;
            return Ok(None);
        }

        let hex_str =
            std::str::from_utf8(&self.input[start..self.pos]).expect("hex digits are valid utf8");
        match u64::from_str_radix(hex_str, 16) {
            Ok(val) => Ok(Some(val)),
            Err(_) => Err(self.error_at(ErrorKind::NumberOverflow, saved)),
        }
    }

    /// Try to parse a decimal number literal.
    ///
    /// Corresponds to Hoon `number` (line 129): `dem:ag`.
    fn try_number(&mut self) -> Result<Option<u64>, LexError> {
        let start = self.pos;
        while self.pos < self.input.len() && self.input[self.pos].is_ascii_digit() {
            self.pos += 1;
        }
        if self.pos == start {
            return Ok(None);
        }
        let num_str =
            std::str::from_utf8(&self.input[start..self.pos]).expect("digits are valid utf8");
        match num_str.parse::<u64>() {
            Ok(val) => Ok(Some(val)),
            Err(_) => Err(self.error_at(ErrorKind::NumberOverflow, start)),
        }
    }

    /// Try to parse a single-quoted string literal `'...'`.
    ///
    /// Corresponds to Hoon `string` (line 128).
    /// Content is any printable ASCII (0x20..=0x7e) except single quote.
    fn try_string(&mut self) -> Result<Option<String>, LexError> {
        if self.peek() != Some(b'\'') {
            return Ok(None);
        }
        let start = self.pos;
        self.advance(); // skip opening quote
        let content_start = self.pos;

        loop {
            match self.peek() {
                Some(b'\'') => {
                    let content = std::str::from_utf8(&self.input[content_start..self.pos])
                        .expect("printable ASCII is valid utf8");
                    let s = content.to_string();
                    self.advance(); // skip closing quote
                    return Ok(Some(s));
                }
                Some(b) if (0x20..=0x7e).contains(&b) => {
                    self.advance();
                }
                Some(_) | None => {
                    return Err(self.error_at(ErrorKind::UnterminatedString, start));
                }
            }
        }
    }

    /// Try to parse a literal (boolean, hex, number, or string).
    /// Tried in order: boolean → hex → number → string.
    ///
    /// Corresponds to Hoon `literal` (line 136).
    fn try_literal(&mut self) -> Result<Option<Jatom>, LexError> {
        // Boolean
        if let Some(b) = self.try_boolean() {
            return Ok(Some(Jatom {
                variant: AtomVariant::Loobean(b),
                constant: false,
            }));
        }
        // Hexadecimal
        if let Some(val) = self.try_hexadecimal()? {
            return Ok(Some(Jatom {
                variant: AtomVariant::Hexadecimal(val),
                constant: false,
            }));
        }
        // Number
        if let Some(val) = self.try_number()? {
            return Ok(Some(Jatom {
                variant: AtomVariant::Number(val),
                constant: false,
            }));
        }
        // String
        if let Some(s) = self.try_string()? {
            return Ok(Some(Jatom {
                variant: AtomVariant::String(s),
                constant: false,
            }));
        }
        Ok(None)
    }

    /// Try to parse a symbol literal (`%` followed by a literal).
    /// The result has `constant = true`.
    ///
    /// Corresponds to Hoon `symbol` (line 138) and `tagged-symbol` (line 137).
    fn try_symbol(&mut self) -> Result<Option<Jatom>, LexError> {
        if self.peek() != Some(b'%') {
            return Ok(None);
        }
        let saved = self.pos;
        self.advance(); // skip '%'

        match self.try_literal()? {
            Some(mut atom) => {
                atom.constant = true;
                Ok(Some(atom))
            }
            None => {
                // Not a symbol — backtrack so '%' can be parsed as punctuator
                self.pos = saved;
                Ok(None)
            }
        }
    }

    /// Try to parse a name (identifier).
    /// Names start with lowercase `[a-z]`, followed by `[a-z0-9_]*`.
    ///
    /// Corresponds to Hoon `snek` (lines 155-157):
    /// `;~(plug low (star ;~(pose nud low cab)))`.
    fn try_name(&mut self) -> Option<String> {
        let start = self.pos;
        match self.peek() {
            Some(b) if b.is_ascii_lowercase() => self.advance(),
            _ => return None,
        }
        while let Some(b) = self.peek() {
            if b.is_ascii_lowercase() || b.is_ascii_digit() || b == b'_' {
                self.advance();
            } else {
                break;
            }
        }
        let s = std::str::from_utf8(&self.input[start..self.pos])
            .expect("ascii is valid utf8")
            .to_string();
        Some(s)
    }

    /// Try to parse a single-character punctuator.
    ///
    /// Corresponds to Hoon `punctuator` (lines 183-190).
    /// `DoubleParen` substitution is handled in `next_token`, not here.
    fn try_punctuator(&mut self) -> Option<Jpunc> {
        let b = self.peek()?;
        let punc = Jpunc::from_char(b)?;
        self.advance();
        Some(punc)
    }

    /// Try to parse a type name.
    /// Types start with uppercase `[A-Z]`, followed by `[a-z]*`.
    ///
    /// Corresponds to Hoon `aul` (lines 161-163):
    /// `;~(plug hig (star low))`.
    fn try_type(&mut self) -> Option<String> {
        let start = self.pos;
        match self.peek() {
            Some(b) if b.is_ascii_uppercase() => self.advance(),
            _ => return None,
        }
        while let Some(b) = self.peek() {
            if b.is_ascii_lowercase() {
                self.advance();
            } else {
                break;
            }
        }
        let s = std::str::from_utf8(&self.input[start..self.pos])
            .expect("ascii is valid utf8")
            .to_string();
        Some(s)
    }

    /// Parse the next token, following the Hoon precedence order (lines 200-208):
    /// 1. Keyword  2. Symbol  3. Literal  4. Name  5. Punctuator  6. Type
    ///
    /// Returns `Ok(None)` at end of input.
    fn next_token(&mut self) -> Result<Option<Token>, LexError> {
        if self.pos >= self.input.len() {
            return Ok(None);
        }

        // 1. Keyword
        if let Some(kw) = self.try_keyword() {
            self.fun = false;
            return Ok(Some(Token::Keyword(kw)));
        }

        // 2. Symbol (%literal)
        if let Some(atom) = self.try_symbol()? {
            self.fun = false;
            return Ok(Some(Token::Literal(atom)));
        }

        // 3. Literal (boolean, hex, number, string)
        if let Some(atom) = self.try_literal()? {
            self.fun = false;
            return Ok(Some(Token::Literal(atom)));
        }

        // 4. Name
        if let Some(name) = self.try_name() {
            self.fun = true;
            return Ok(Some(Token::Name(name)));
        }

        // 5. Punctuator (with DoubleParen substitution)
        if let Some(punc) = self.try_punctuator() {
            let token = if self.fun && punc == Jpunc::LParen {
                Token::Punctuator(Jpunc::DoubleParen)
            } else {
                Token::Punctuator(punc)
            };
            self.fun = false;
            return Ok(Some(token));
        }

        // 6. Type
        if let Some(ty) = self.try_type() {
            self.fun = true;
            return Ok(Some(Token::Type(ty)));
        }

        // Nothing matched
        let c = self.input[self.pos] as char;
        Err(self.error(ErrorKind::UnexpectedCharacter(c)))
    }

    /// Tokenize the entire input.
    ///
    /// Corresponds to Hoon `parse-tokens` (lines 213-218):
    /// `(ifix [gae gae] tokens:tokenize)` wrapped in `full`.
    pub fn tokenize_all(&mut self) -> Result<Vec<Token>, LexError> {
        let mut tokens = Vec::new();

        // Leading whitespace/comments (gae)
        self.skip_whitespace_and_comments()?;

        loop {
            match self.next_token()? {
                Some(tok) => {
                    tokens.push(tok);
                    // Skip whitespace/comments between tokens (gav)
                    self.skip_whitespace_and_comments()?;
                }
                None => break,
            }
        }

        // `full` combinator: ensure all input was consumed
        if self.pos < self.input.len() {
            return Err(self.error(ErrorKind::TrailingInput));
        }

        Ok(tokens)
    }
}
