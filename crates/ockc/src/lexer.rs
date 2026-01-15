use std::error::Error;
use std::fmt;

use crate::ast::{AtomLiteral, Keyword, Literal, NounLiteral, Punct, Span, TokenKind};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LexError {
    pub span: Span,
    pub message: String,
}

impl fmt::Display for LexError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "{} at {}..{}",
            self.message, self.span.start, self.span.end
        )
    }
}

impl Error for LexError {}

pub fn tokenize(input: &str) -> Result<Vec<(TokenKind, Span)>, LexError> {
    let bytes = input.as_bytes();
    let mut tokens = Vec::new();
    let mut i = 0;
    let mut saw_ws = true;
    let mut prev_kind: Option<TokenKind> = None;

    while i < bytes.len() {
        let ch = bytes[i] as char;

        if ch.is_ascii_whitespace() {
            saw_ws = true;
            i += 1;
            continue;
        }

        if ch == '/' && i + 1 < bytes.len() {
            let next = bytes[i + 1] as char;
            if next == '/' {
                i = skip_line_comment(bytes, i + 2);
                saw_ws = true;
                continue;
            }
            if next == '*' {
                let end = skip_block_comment(bytes, i + 2)?;
                i = end;
                saw_ws = true;
                continue;
            }
        }

        let start = i;

        if ch == '"' {
            let (value, end) = parse_string(bytes, i + 1, '"')?;
            push_token(
                &mut tokens,
                TokenKind::Literal(Literal::Noun(NounLiteral::String(value))),
                start..end,
                &mut prev_kind,
                &mut saw_ws,
            );
            i = end;
            continue;
        }

        if ch == '\'' {
            let (value, end) = parse_string(bytes, i + 1, '\'')?;
            push_token(
                &mut tokens,
                TokenKind::Literal(Literal::Atom(AtomLiteral::Chars(value))),
                start..end,
                &mut prev_kind,
                &mut saw_ws,
            );
            i = end;
            continue;
        }

        if ch == '~' && i + 1 < bytes.len() {
            let next = bytes[i + 1] as char;
            if next.is_ascii_digit() || matches!(next, 'd' | 'h' | 'm' | 's') {
                let end = take_while(bytes, i + 1, is_span_char);
                let lit = &input[start..end];
                push_token(
                    &mut tokens,
                    TokenKind::Literal(Literal::Atom(AtomLiteral::Span(lit.to_string()))),
                    start..end,
                    &mut prev_kind,
                    &mut saw_ws,
                );
                i = end;
                continue;
            }
        }

        if ch == '@' && i + 1 < bytes.len() {
            let next = bytes[i + 1] as char;
            if next.is_ascii_digit() {
                let end = take_while(bytes, i + 1, is_date_char);
                let lit = &input[start..end];
                push_token(
                    &mut tokens,
                    TokenKind::Literal(Literal::Atom(AtomLiteral::Date(lit.to_string()))),
                    start..end,
                    &mut prev_kind,
                    &mut saw_ws,
                );
                i = end;
                continue;
            }
        }

        if ch == '/' && i + 1 < bytes.len() {
            let next = bytes[i + 1] as char;
            if next.is_ascii_alphabetic() || next == '_' {
                let end = take_while(bytes, i + 1, is_path_char);
                let lit = &input[start..end];
                push_token(
                    &mut tokens,
                    TokenKind::Literal(Literal::Noun(NounLiteral::Path(lit.to_string()))),
                    start..end,
                    &mut prev_kind,
                    &mut saw_ws,
                );
                i = end;
                continue;
            }
        }

        if ch == '%' && i + 1 < bytes.len() {
            let next = bytes[i + 1] as char;
            if next.is_ascii_digit() {
                let end = take_while(bytes, i + 1, |c| c.is_ascii_digit());
                let lit = &input[i + 1..end];
                push_token(
                    &mut tokens,
                    TokenKind::Literal(Literal::Atom(AtomLiteral::Constant(Box::new(
                        AtomLiteral::Number(lit.to_string()),
                    )))),
                    start..end,
                    &mut prev_kind,
                    &mut saw_ws,
                );
                i = end;
                continue;
            }
            if is_ident_start(next) {
                let end = take_while(bytes, i + 1, is_ident_continue);
                let ident = &input[i + 1..end];
                push_token(
                    &mut tokens,
                    TokenKind::Literal(Literal::Atom(AtomLiteral::Constant(Box::new(
                        AtomLiteral::Chars(ident.to_string()),
                    )))),
                    start..end,
                    &mut prev_kind,
                    &mut saw_ws,
                );
                i = end;
                continue;
            }
        }

        if is_ident_start(ch) {
            let end = take_while(bytes, i + 1, is_ident_continue);
            let ident = &input[start..end];
            let kind = if ident == "true" {
                TokenKind::Literal(Literal::Atom(AtomLiteral::Logical(true)))
            } else if ident == "false" {
                TokenKind::Literal(Literal::Atom(AtomLiteral::Logical(false)))
            } else if let Some(keyword) = keyword_from_str(ident) {
                TokenKind::Keyword(keyword)
            } else if is_type_ident(ident) {
                TokenKind::Type(ident.to_string())
            } else {
                TokenKind::Name(ident.to_string())
            };
            push_token(&mut tokens, kind, start..end, &mut prev_kind, &mut saw_ws);
            i = end;
            if i < bytes.len() && bytes[i] as char == '-' {
                return Err(LexError {
                    span: i..i + 1,
                    message: "invalid identifier: '-' is not allowed; use '_' or add spaces for subtraction"
                        .to_string(),
                });
            }
            continue;
        }

        if ch.is_ascii_digit() || is_signed_number_start(ch, bytes, i, &prev_kind) {
            let (literal, end) = parse_number(input, bytes, i)?;
            push_token(
                &mut tokens,
                TokenKind::Literal(Literal::Atom(literal)),
                start..end,
                &mut prev_kind,
                &mut saw_ws,
            );
            i = end;
            continue;
        }

        let (kind, end) = match ch {
            '-' => {
                if i + 1 < bytes.len() && bytes[i + 1] as char == '>' {
                    (TokenKind::Punct(Punct::Arrow), i + 2)
                } else {
                    (TokenKind::Punct(Punct::Minus), i + 1)
                }
            }
            '*' => {
                if i + 1 < bytes.len() && bytes[i + 1] as char == '*' {
                    (TokenKind::Punct(Punct::StarStar), i + 2)
                } else {
                    (TokenKind::Punct(Punct::Star), i + 1)
                }
            }
            '+' => (TokenKind::Punct(Punct::Plus), i + 1),
            '/' => (TokenKind::Punct(Punct::Slash), i + 1),
            '%' => (TokenKind::Punct(Punct::Percent), i + 1),
            '.' => (TokenKind::Punct(Punct::Dot), i + 1),
            ';' => (TokenKind::Punct(Punct::Semi), i + 1),
            ',' => (TokenKind::Punct(Punct::Comma), i + 1),
            ':' => (TokenKind::Punct(Punct::Colon), i + 1),
            '&' => (TokenKind::Punct(Punct::Amp), i + 1),
            '$' => (TokenKind::Punct(Punct::Dollar), i + 1),
            '@' => (TokenKind::Punct(Punct::At), i + 1),
            '?' => (TokenKind::Punct(Punct::Question), i + 1),
            '!' => {
                if i + 1 < bytes.len() && bytes[i + 1] as char == '=' {
                    (TokenKind::Punct(Punct::NotEq), i + 2)
                } else {
                    (TokenKind::Punct(Punct::Bang), i + 1)
                }
            }
            '(' => {
                let prev_call = matches!(
                    prev_kind,
                    Some(TokenKind::Name(_)) | Some(TokenKind::Type(_))
                );
                let call = prev_call && !saw_ws;
                let punct = if call {
                    Punct::CallOpen
                } else {
                    Punct::OpenParen
                };
                (TokenKind::Punct(punct), i + 1)
            }
            ')' => (TokenKind::Punct(Punct::CloseParen), i + 1),
            '{' => (TokenKind::Punct(Punct::OpenBrace), i + 1),
            '}' => (TokenKind::Punct(Punct::CloseBrace), i + 1),
            '[' => (TokenKind::Punct(Punct::OpenBracket), i + 1),
            ']' => (TokenKind::Punct(Punct::CloseBracket), i + 1),
            '=' => {
                if i + 1 < bytes.len() && bytes[i + 1] as char == '=' {
                    (TokenKind::Punct(Punct::EqEq), i + 2)
                } else {
                    (TokenKind::Punct(Punct::Equals), i + 1)
                }
            }
            '<' => {
                if i + 1 < bytes.len() && bytes[i + 1] as char == '=' {
                    (TokenKind::Punct(Punct::LessEq), i + 2)
                } else {
                    (TokenKind::Punct(Punct::Less), i + 1)
                }
            }
            '>' => {
                if i + 1 < bytes.len() && bytes[i + 1] as char == '=' {
                    (TokenKind::Punct(Punct::GreaterEq), i + 2)
                } else {
                    (TokenKind::Punct(Punct::Greater), i + 1)
                }
            }
            '#' => (TokenKind::Punct(Punct::Hash), i + 1),
            '_' => (TokenKind::Punct(Punct::Underscore), i + 1),
            _ => {
                let end = i + 1;
                let message = format!("unexpected character '{ch}'");
                return Err(LexError {
                    span: start..end,
                    message,
                });
            }
        };

        push_token(&mut tokens, kind, start..end, &mut prev_kind, &mut saw_ws);
        i = end;
    }

    Ok(tokens)
}

fn keyword_from_str(s: &str) -> Option<Keyword> {
    match s {
        "let" => Some(Keyword::Let),
        "func" => Some(Keyword::Func),
        "lambda" => Some(Keyword::Lambda),
        "class" => Some(Keyword::Class),
        "struct" => Some(Keyword::Struct),
        "impl" => Some(Keyword::Impl),
        "trait" => Some(Keyword::Trait),
        "union" => Some(Keyword::Union),
        "alias" => Some(Keyword::Alias),
        "object" => Some(Keyword::Object),
        "if" => Some(Keyword::If),
        "else" => Some(Keyword::Else),
        "crash" => Some(Keyword::Crash),
        "assert" => Some(Keyword::Assert),
        "compose" => Some(Keyword::Compose),
        "loop" => Some(Keyword::Loop),
        "defer" => Some(Keyword::Defer),
        "recur" => Some(Keyword::Recur),
        "match" => Some(Keyword::Match),
        "switch" => Some(Keyword::Switch),
        "eval" => Some(Keyword::Eval),
        "with" => Some(Keyword::With),
        "this" => Some(Keyword::This),
        "import" => Some(Keyword::Import),
        "as" => Some(Keyword::As),
        "print" => Some(Keyword::Print),
        _ => None,
    }
}

fn is_ident_start(ch: char) -> bool {
    ch.is_ascii_alphabetic() || ch == '_'
}

fn is_ident_continue(ch: char) -> bool {
    ch.is_ascii_alphanumeric() || ch == '_'
}

fn is_type_ident(s: &str) -> bool {
    let mut chars = s.chars();
    let Some(first) = chars.next() else {
        return false;
    };
    if !first.is_ascii_uppercase() {
        return false;
    }
    chars.all(|ch| ch.is_ascii_alphanumeric())
}

fn is_signed_number_start(ch: char, bytes: &[u8], idx: usize, prev: &Option<TokenKind>) -> bool {
    if !matches!(ch, '+' | '-') {
        return false;
    }
    if idx + 1 >= bytes.len() {
        return false;
    }
    let next = bytes[idx + 1] as char;
    if !next.is_ascii_digit() {
        return false;
    }
    can_start_signed(prev)
}

fn can_start_signed(prev: &Option<TokenKind>) -> bool {
    match prev {
        None => true,
        Some(TokenKind::Keyword(_)) => true,
        Some(TokenKind::Punct(punct)) => matches!(
            punct,
            Punct::OpenParen
                | Punct::OpenBracket
                | Punct::OpenBrace
                | Punct::Comma
                | Punct::Semi
                | Punct::Colon
                | Punct::Equals
                | Punct::Arrow
        ),
        _ => false,
    }
}

fn take_while<F>(bytes: &[u8], mut idx: usize, mut pred: F) -> usize
where
    F: FnMut(char) -> bool,
{
    while idx < bytes.len() {
        let ch = bytes[idx] as char;
        if !pred(ch) {
            break;
        }
        idx += 1;
    }
    idx
}

fn parse_string(bytes: &[u8], mut idx: usize, quote: char) -> Result<(String, usize), LexError> {
    let mut out = String::new();
    while idx < bytes.len() {
        let ch = bytes[idx] as char;
        if ch == quote {
            return Ok((out, idx + 1));
        }
        if ch == '\\' {
            if idx + 1 >= bytes.len() {
                return Err(LexError {
                    span: idx..idx + 1,
                    message: "unterminated escape".to_string(),
                });
            }
            let next = bytes[idx + 1] as char;
            let escaped = match next {
                'n' => '\n',
                't' => '\t',
                'r' => '\r',
                '\\' => '\\',
                '\'' => '\'',
                '"' => '"',
                other => other,
            };
            out.push(escaped);
            idx += 2;
            continue;
        }
        if ch.is_ascii() {
            out.push(ch);
            idx += 1;
            continue;
        }
        return Err(LexError {
            span: idx..idx + 1,
            message: "non-ascii character in string".to_string(),
        });
    }
    Err(LexError {
        span: idx..idx + 1,
        message: "unterminated string".to_string(),
    })
}

fn parse_number(input: &str, bytes: &[u8], start: usize) -> Result<(AtomLiteral, usize), LexError> {
    let mut idx = start;
    let mut signed = false;
    if matches!(bytes[idx] as char, '+' | '-') {
        signed = true;
        idx += 1;
    }

    if idx + 1 < bytes.len() && bytes[idx] as char == '0' {
        let next = bytes[idx + 1] as char;
        if next == 'x' || next == 'X' {
            idx += 2;
            let end = take_while(bytes, idx, |c| c.is_ascii_hexdigit());
            let lit = &input[start..end];
            return Ok((AtomLiteral::Hex(lit.to_string()), end));
        }
    }

    let int_end = take_while(bytes, idx, |c| c.is_ascii_digit());
    if int_end == idx {
        return Err(LexError {
            span: start..start + 1,
            message: "invalid numeric literal".to_string(),
        });
    }

    let mut end = int_end;
    let mut is_real = false;
    if end < bytes.len()
        && bytes[end] as char == '.'
        && end + 1 < bytes.len()
        && (bytes[end + 1] as char).is_ascii_digit()
    {
        is_real = true;
        end += 1;
        end = take_while(bytes, end, |c| c.is_ascii_digit());
    }
    if end < bytes.len() {
        let ch = bytes[end] as char;
        if ch == 'e' || ch == 'E' {
            is_real = true;
            end += 1;
            if end < bytes.len() && matches!(bytes[end] as char, '+' | '-') {
                end += 1;
            }
            let exp_end = take_while(bytes, end, |c| c.is_ascii_digit());
            if exp_end == end {
                return Err(LexError {
                    span: start..end,
                    message: "invalid exponent in numeric literal".to_string(),
                });
            }
            end = exp_end;
        }
    }

    let lit = &input[start..end];
    if is_real {
        return Ok((AtomLiteral::Real(lit.to_string()), end));
    }
    if signed {
        return Ok((AtomLiteral::Sint(lit.to_string()), end));
    }
    Ok((AtomLiteral::Number(lit.to_string()), end))
}

fn is_span_char(ch: char) -> bool {
    ch.is_ascii_alphanumeric() || matches!(ch, '.' | '~')
}

fn is_date_char(ch: char) -> bool {
    ch.is_ascii_alphanumeric() || ch == '.'
}

fn is_path_char(ch: char) -> bool {
    ch.is_ascii_alphanumeric() || matches!(ch, '_' | '-' | '/' | '(' | ')')
}

fn skip_line_comment(bytes: &[u8], mut idx: usize) -> usize {
    while idx < bytes.len() {
        if bytes[idx] as char == '\n' {
            return idx + 1;
        }
        idx += 1;
    }
    idx
}

fn skip_block_comment(bytes: &[u8], mut idx: usize) -> Result<usize, LexError> {
    while idx + 1 < bytes.len() {
        if bytes[idx] as char == '*' && bytes[idx + 1] as char == '/' {
            return Ok(idx + 2);
        }
        idx += 1;
    }
    Err(LexError {
        span: idx..idx + 1,
        message: "unterminated block comment".to_string(),
    })
}

fn push_token(
    tokens: &mut Vec<(TokenKind, Span)>,
    kind: TokenKind,
    span: Span,
    prev_kind: &mut Option<TokenKind>,
    saw_ws: &mut bool,
) {
    *prev_kind = Some(kind.clone());
    *saw_ws = false;
    tokens.push((kind, span));
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::ast::{AtomLiteral, Literal, Punct, TokenKind};

    #[test]
    fn tokenizes_constant_atom() {
        let tokens = tokenize("%1").expect("tokenize");
        assert_eq!(tokens.len(), 1);
        match &tokens[0].0 {
            TokenKind::Literal(Literal::Atom(AtomLiteral::Constant(inner))) => {
                assert!(matches!(**inner, AtomLiteral::Number(ref n) if n == "1"));
            }
            other => panic!("unexpected token: {other:?}"),
        }
    }

    #[test]
    fn tokenizes_call_open_without_whitespace() {
        let tokens = tokenize("foo(bar)").expect("tokenize");
        let kinds: Vec<TokenKind> = tokens.into_iter().map(|(kind, _)| kind).collect();
        assert!(matches!(kinds[0], TokenKind::Name(_)));
        assert!(matches!(kinds[1], TokenKind::Punct(Punct::CallOpen)));
    }

    #[test]
    fn tokenizes_open_paren_with_whitespace() {
        let tokens = tokenize("foo (bar)").expect("tokenize");
        let kinds: Vec<TokenKind> = tokens.into_iter().map(|(kind, _)| kind).collect();
        assert!(matches!(kinds[0], TokenKind::Name(_)));
        assert!(matches!(kinds[1], TokenKind::Punct(Punct::OpenParen)));
    }
}
