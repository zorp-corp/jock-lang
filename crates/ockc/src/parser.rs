use chumsky::input::{Stream, ValueInput};
use chumsky::prelude::*;

use crate::ast::{
    AtomLiteral, AtomType, Comparator, Expr, ExprKind, Lambda, Limb, Literal, Method, NounType,
    Operator, Punct, Span, TokenKind, TypeExpr, TypeExprKind, TypeLeaf,
};
use crate::lexer::tokenize;

#[allow(clippy::needless_lifetimes)]
pub fn parse<'src>(input: &'src str) -> Result<Expr, Vec<Rich<'src, TokenKind, Span>>> {
    let tokens = tokenize(input).map_err(|err| vec![Rich::custom(err.span, err.message)])?;
    for (token, span) in &tokens {
        if let TokenKind::Name(name) = token {
            if name.contains('-') {
                return Err(vec![Rich::custom(
                    span.clone(),
                    "invalid identifier: '-' is not allowed; use '_' or add spaces for subtraction",
                )]);
            }
        }
    }
    parse_tokens(tokens, input.len())
}

pub fn parse_tokens<'src>(
    tokens: Vec<(TokenKind, Span)>,
    input_len: usize,
) -> Result<Expr, Vec<Rich<'src, TokenKind, Span>>> {
    let end_span = input_len..input_len;
    let stream = Stream::from_iter(tokens).map(end_span, |(tok, span)| (tok, span));
    let parser = expr_parser();
    parser.then_ignore(end()).parse(stream).into_result()
}

type ParserExtra<'src> = extra::Err<Rich<'src, TokenKind, Span>>;

type TokenParser<'src, I, O> = Boxed<'src, 'src, I, O, ParserExtra<'src>>;

type CaseBlock = (Vec<(Expr, Expr)>, Option<Expr>);

fn expr_parser<'src, I>() -> TokenParser<'src, I, Expr>
where
    I: ValueInput<'src, Token = TokenKind, Span = Span>,
{
    let type_expr = type_expr_parser::<I>();

    recursive(|expr| {
        let ident = select! { TokenKind::Name(name) => name };
        let type_ident = select! { TokenKind::Type(name) => name };
        let name_or_type = ident.or(type_ident);

        let literal = select! { TokenKind::Literal(lit) => lit }.map_with(|lit, extra| {
            let span = extra.span();
            match lit {
                Literal::Atom(atom) => Expr::new(ExprKind::Atom(atom), span),
                Literal::Noun(noun) => Expr::new(ExprKind::Noun(noun), span),
            }
        });

        let limb_segment = select! {
            TokenKind::Name(name) => Limb::Name(name),
            TokenKind::Type(name) => Limb::Type(name),
        };

        let limb_chain = limb_segment
            .then(
                just_punct(Punct::Dot)
                    .ignore_then(limb_segment)
                    .repeated()
                    .collect::<Vec<_>>(),
            )
            .map_with(|(head, tail), extra| {
                let span = extra.span();
                let mut limbs = Vec::with_capacity(1 + tail.len());
                limbs.push(head);
                limbs.extend(tail);
                Expr::new(ExprKind::Limb(limbs), span)
            });

        let axis = just_punct(Punct::Amp)
            .ignore_then(number_literal())
            .try_map(|num, span: Span| {
                let parsed = num.parse::<u64>().map_err(|_| {
                    Rich::custom(span.clone(), "axis must be a non-negative integer")
                })?;
                Ok(Expr::new(ExprKind::Limb(vec![Limb::Axis(parsed)]), span))
            });

        let tuple = just_punct(Punct::OpenParen)
            .ignore_then(expr.clone().repeated().at_least(1).collect::<Vec<_>>())
            .then_ignore(just_punct(Punct::CloseParen))
            .map(fold_pairs);

        let list = just_punct(Punct::OpenBracket)
            .ignore_then(expr.clone().repeated().at_least(1).collect::<Vec<_>>())
            .then_ignore(just_punct(Punct::CloseBracket))
            .map_with(|items, extra| {
                let span = extra.span();
                Expr::new(
                    ExprKind::List {
                        elements: items,
                        element_type: None,
                    },
                    span,
                )
            });

        let set = just_punct(Punct::OpenBrace)
            .ignore_then(expr.clone().repeated().at_least(1).collect::<Vec<_>>())
            .then_ignore(just_punct(Punct::CloseBrace))
            .map_with(|items, extra| {
                let span = extra.span();
                Expr::new(
                    ExprKind::Set {
                        elements: items,
                        element_type: None,
                    },
                    span,
                )
            });

        let lambda = just_kw(crate::ast::Keyword::Lambda)
            .ignore_then(lambda_signature(type_expr.clone(), expr.clone().boxed()))
            .map_with(|lambda, extra| Expr::new(ExprKind::Lambda(lambda), extra.span()));

        let object = just_kw(crate::ast::Keyword::Object)
            .ignore_then(name_or_type.or_not())
            .then_ignore(just_punct(Punct::OpenBrace))
            .then(object_arms(expr.clone().boxed()))
            .then_ignore(just_punct(Punct::CloseBrace))
            .map_with(|(name, arms), extra| {
                let span = extra.span();
                Expr::new(
                    ExprKind::Object {
                        name,
                        arms,
                        context: None,
                    },
                    span,
                )
            });

        let class = just_kw(crate::ast::Keyword::Class)
            .ignore_then(type_ident)
            .then(parse_lambda_input(type_expr.clone()))
            .then_ignore(just_punct(Punct::OpenBrace))
            .then(class_methods(type_expr.clone(), expr.clone().boxed()))
            .then_ignore(just_punct(Punct::CloseBrace))
            .map_with(|((name, state), methods), extra| {
                let span = extra.span();
                Expr::new(
                    ExprKind::Class {
                        name,
                        state,
                        methods,
                    },
                    span,
                )
            });

        let this = just_kw(crate::ast::Keyword::This)
            .map_with(|_, extra| Expr::new(ExprKind::Limb(vec![Limb::Axis(1)]), extra.span()));

        let crash = just_kw(crate::ast::Keyword::Crash)
            .map_with(|_, extra| Expr::new(ExprKind::Crash, extra.span()));

        let call_args = call_args(expr.clone().boxed());

        let recur_expr = just_kw(crate::ast::Keyword::Recur)
            .then(call_args.clone().or_not())
            .map_with(|(_, args), extra| {
                let span = extra.span();
                let func = Expr::new(ExprKind::Limb(vec![Limb::Axis(0)]), span.clone());
                Expr::new(
                    ExprKind::Call {
                        func: Box::new(func),
                        arg: args.and_then(|call| call.arg).map(Box::new),
                    },
                    span,
                )
            });

        let dollar_recur = just_punct(Punct::Dollar)
            .then(call_args.clone().or_not())
            .map_with(|(_, args), extra| {
                let span = extra.span();
                let func = Expr::new(ExprKind::Limb(vec![Limb::Axis(0)]), span.clone());
                Expr::new(
                    ExprKind::Call {
                        func: Box::new(func),
                        arg: args.and_then(|call| call.arg).map(Box::new),
                    },
                    span,
                )
            });

        let primary = choice((
            lambda,
            object,
            class,
            list,
            set,
            tuple,
            axis,
            this,
            crash,
            recur_expr,
            dollar_recur,
            limb_chain.clone(),
            literal,
        ));

        let call = primary
            .clone()
            .foldl(call_args.clone().repeated(), |func, args| {
                let span = merge_span(&func.span, &args.span);
                Expr::new(
                    ExprKind::Call {
                        func: Box::new(func),
                        arg: args.arg.map(Box::new),
                    },
                    span,
                )
            });

        let increment = just_punct(Punct::Plus)
            .ignore_then(just_punct(Punct::OpenParen))
            .ignore_then(expr.clone())
            .then_ignore(just_punct(Punct::CloseParen))
            .map_with(|value, extra| {
                Expr::new(
                    ExprKind::Increment {
                        value: Box::new(value),
                    },
                    extra.span(),
                )
            });

        let cell_check = just_punct(Punct::Question)
            .ignore_then(just_punct(Punct::OpenParen))
            .ignore_then(expr.clone())
            .then_ignore(just_punct(Punct::CloseParen))
            .map_with(|value, extra| {
                Expr::new(
                    ExprKind::CellCheck {
                        value: Box::new(value),
                    },
                    extra.span(),
                )
            });

        let factor = choice((increment, cell_check, call));

        let pow = factor.clone().foldl(
            just_punct(Punct::StarStar)
                .ignore_then(factor.clone())
                .repeated(),
            |left, right| make_operator(Operator::Pow, left, right),
        );

        let term = pow.clone().foldl(
            choice((
                just_punct(Punct::Star).to(Operator::Mul),
                just_punct(Punct::Slash).to(Operator::Div),
                just_punct(Punct::Percent).to(Operator::Mod),
            ))
            .then(pow.clone())
            .repeated(),
            |left, (op, right)| make_operator(op, left, right),
        );

        let sum = term.clone().foldl(
            choice((
                just_punct(Punct::Plus).to(Operator::Add),
                just_punct(Punct::Minus).to(Operator::Sub),
            ))
            .then(term.clone())
            .repeated(),
            |left, (op, right)| make_operator(op, left, right),
        );

        let compare_op = choice((
            just_punct(Punct::EqEq).to(Comparator::Eq),
            just_punct(Punct::NotEq).to(Comparator::NotEq),
            just_punct(Punct::LessEq).to(Comparator::Le),
            just_punct(Punct::GreaterEq).to(Comparator::Ge),
            just_punct(Punct::Less).to(Comparator::Lt),
            just_punct(Punct::Greater).to(Comparator::Gt),
        ));

        let compare = sum.clone().foldl(
            compare_op.then(sum.clone()).repeated(),
            |left, (op, right)| {
                let span = merge_span(&left.span, &right.span);
                Expr::new(
                    ExprKind::Compare {
                        op,
                        left: Box::new(left),
                        right: Box::new(right),
                    },
                    span,
                )
            },
        );

        let assignment = limb_chain
            .clone()
            .then_ignore(just_punct(Punct::Equals))
            .then(expr.clone())
            .then_ignore(just_punct(Punct::Semi))
            .then(expr.clone())
            .map(|((target, value), next)| {
                let span = merge_span(&target.span, &next.span);
                let target_limbs = match target.kind {
                    ExprKind::Limb(limbs) => limbs,
                    _ => Vec::new(),
                };
                Expr::new(
                    ExprKind::Edit {
                        target: target_limbs,
                        value: Box::new(value),
                        next: Box::new(next),
                    },
                    span,
                )
            });

        let let_expr = just_kw(crate::ast::Keyword::Let)
            .ignore_then(name_or_type)
            .then(
                just_punct(Punct::Colon)
                    .ignore_then(type_expr.clone())
                    .or_not(),
            )
            .then_ignore(just_punct(Punct::Equals))
            .then(expr.clone())
            .then_ignore(just_punct(Punct::Semi))
            .then(expr.clone())
            .map(|(((name, ty), value), next)| {
                let span = merge_span(&value.span, &next.span);
                let value_span = value.span.clone();
                let ty = ty.unwrap_or_else(|| unknown_type(value_span));
                Expr::new(
                    ExprKind::Let {
                        name,
                        ty,
                        value: Box::new(value),
                        next: Box::new(next),
                    },
                    span,
                )
            });

        let func_expr = just_kw(crate::ast::Keyword::Func)
            .ignore_then(name_or_type)
            .then(parse_lambda_input(type_expr.clone()))
            .then_ignore(just_punct(Punct::Arrow))
            .then(type_expr.clone())
            .then(block(expr.clone().boxed()))
            .then_ignore(just_punct(Punct::Semi))
            .then(expr.clone())
            .map(|((((name, input), output), body), next)| {
                let span = merge_span(&body.span, &next.span);
                Expr::new(
                    ExprKind::Func {
                        name,
                        input,
                        output,
                        body: Box::new(body),
                        next: Box::new(next),
                    },
                    span,
                )
            });

        let alias_expr = just_kw(crate::ast::Keyword::Alias)
            .ignore_then(name_or_type)
            .then(name_or_type)
            .map_with(|(name, target), extra| {
                Expr::new(ExprKind::Alias { name, target }, extra.span())
            });

        let if_expr = just_kw(crate::ast::Keyword::If)
            .ignore_then(expr.clone())
            .then(block(expr.clone().boxed()))
            .then(if_after(expr.clone().boxed()))
            .map(|((cond, then), otherwise)| {
                let span = merge_span(&cond.span, &then.span);
                Expr::new(
                    ExprKind::If {
                        cond: Box::new(cond),
                        then: Box::new(then),
                        otherwise: otherwise.map(Box::new),
                    },
                    span,
                )
            });

        let assert_expr = just_kw(crate::ast::Keyword::Assert)
            .ignore_then(expr.clone())
            .then_ignore(just_punct(Punct::Semi))
            .then(expr.clone())
            .map(|(cond, then)| {
                let span = merge_span(&cond.span, &then.span);
                Expr::new(
                    ExprKind::Assert {
                        cond: Box::new(cond),
                        then: Box::new(then),
                    },
                    span,
                )
            });

        let compose_expr = just_kw(crate::ast::Keyword::Compose)
            .ignore_then(expr.clone())
            .then_ignore(just_punct(Punct::Semi))
            .then(expr.clone())
            .map(|(left, right)| {
                let span = merge_span(&left.span, &right.span);
                Expr::new(
                    ExprKind::Compose {
                        left: Box::new(left),
                        right: Box::new(right),
                    },
                    span,
                )
            });

        let loop_expr = just_kw(crate::ast::Keyword::Loop)
            .ignore_then(just_punct(Punct::Semi))
            .ignore_then(expr.clone())
            .map_with(|next, extra| {
                Expr::new(
                    ExprKind::Loop {
                        next: Box::new(next),
                    },
                    extra.span(),
                )
            });

        let defer_expr = just_kw(crate::ast::Keyword::Defer)
            .ignore_then(just_punct(Punct::Semi))
            .ignore_then(expr.clone())
            .map_with(|next, extra| {
                Expr::new(
                    ExprKind::Defer {
                        next: Box::new(next),
                    },
                    extra.span(),
                )
            });

        let match_expr = just_kw(crate::ast::Keyword::Match)
            .ignore_then(expr.clone())
            .then(case_block(expr.clone().boxed()))
            .map(|(value, (cases, default))| {
                let span = value.span.clone();
                Expr::new(
                    ExprKind::Match {
                        value: Box::new(value),
                        cases,
                        default: default.map(Box::new),
                    },
                    span,
                )
            });

        let switch_expr = just_kw(crate::ast::Keyword::Switch)
            .ignore_then(expr.clone())
            .then(case_block(expr.clone().boxed()))
            .map(|(value, (cases, default))| {
                let span = value.span.clone();
                Expr::new(
                    ExprKind::Switch {
                        value: Box::new(value),
                        cases,
                        default: default.map(Box::new),
                    },
                    span,
                )
            });

        let eval_expr = just_kw(crate::ast::Keyword::Eval)
            .ignore_then(call_args.clone())
            .then(call_args.clone())
            .try_map(|(target, sample), _span| {
                let target_expr = target
                    .arg
                    .ok_or_else(|| Rich::custom(target.span.clone(), "eval requires a target"))?;
                let sample_expr = sample
                    .arg
                    .ok_or_else(|| Rich::custom(sample.span.clone(), "eval requires a sample"))?;
                let span = merge_span(&target.span, &sample.span);
                Ok(Expr::new(
                    ExprKind::Eval {
                        target: Box::new(target_expr),
                        sample: Box::new(sample_expr),
                    },
                    span,
                ))
            });

        let import_expr = just_kw(crate::ast::Keyword::Import)
            .ignore_then(name_or_type)
            .then(
                just_kw(crate::ast::Keyword::As)
                    .ignore_then(name_or_type)
                    .or_not(),
            )
            .then_ignore(just_punct(Punct::Semi))
            .then(expr.clone())
            .map(|((module, alias), next)| {
                let span = next.span.clone();
                Expr::new(
                    ExprKind::Import {
                        module,
                        alias,
                        next: Box::new(next),
                    },
                    span,
                )
            });

        let with_expr = just_kw(crate::ast::Keyword::With)
            .ignore_then(expr.clone())
            .then_ignore(just_punct(Punct::Semi))
            .then(expr.clone())
            .map(|(context, body)| {
                let span = merge_span(&context.span, &body.span);
                Expr::new(
                    ExprKind::With {
                        context: Box::new(context),
                        body: Box::new(body),
                    },
                    span,
                )
            });

        let print_expr = just_kw(crate::ast::Keyword::Print)
            .ignore_then(just_punct(Punct::OpenParen))
            .ignore_then(expr.clone())
            .then_ignore(just_punct(Punct::CloseParen))
            .then_ignore(just_punct(Punct::Semi))
            .then(expr.clone())
            .map(|(value, next)| {
                let span = merge_span(&value.span, &next.span);
                Expr::new(
                    ExprKind::Print {
                        value: Box::new(value),
                        next: Box::new(next),
                    },
                    span,
                )
            });

        let expr_stmt = choice((
            let_expr,
            func_expr,
            if_expr,
            assert_expr,
            compose_expr,
            loop_expr,
            defer_expr,
            match_expr,
            switch_expr,
            eval_expr,
            import_expr,
            with_expr,
            print_expr,
            alias_expr,
            assignment,
            compare,
        ));

        expr_stmt.boxed()
    })
    .boxed()
}

fn type_expr_parser<'src, I>() -> TokenParser<'src, I, TypeExpr>
where
    I: ValueInput<'src, Token = TokenKind, Span = Span>,
{
    recursive(|ty| {
        let name_or_type = select! {
            TokenKind::Name(name) => name,
            TokenKind::Type(name) => name,
        };

        let type_name = select! { TokenKind::Type(name) => name };
        let name_name = select! { TokenKind::Name(name) => name };

        let atom_leaf = choice((
            just_punct(Punct::At).map_with(|_, extra| {
                let span = extra.span();
                TypeExpr::new(
                    TypeExprKind::Leaf(TypeLeaf::Atom {
                        atom: AtomType::Number,
                        constant: false,
                    }),
                    None,
                    span,
                )
            }),
            just_punct(Punct::Question).map_with(|_, extra| {
                let span = extra.span();
                TypeExpr::new(
                    TypeExprKind::Leaf(TypeLeaf::Atom {
                        atom: AtomType::Logical,
                        constant: false,
                    }),
                    None,
                    span,
                )
            }),
            just_punct(Punct::Star).map_with(|_, extra| {
                TypeExpr::new(TypeExprKind::Leaf(TypeLeaf::None), None, extra.span())
            }),
            just_punct(Punct::Hash).map_with(|_, extra| {
                TypeExpr::new(TypeExprKind::Leaf(TypeLeaf::None), None, extra.span())
            }),
            just_punct(Punct::Amp)
                .ignore_then(number_literal())
                .try_map(|num, span: Span| {
                    let parsed = num.parse::<u64>().map_err(|_| {
                        Rich::custom(span.clone(), "axis must be a non-negative integer")
                    })?;
                    Ok(TypeExpr::new(
                        TypeExprKind::Leaf(TypeLeaf::Limb(vec![Limb::Axis(parsed)])),
                        None,
                        span,
                    ))
                }),
            type_name.map_with(|name, extra| type_from_type_name(name, extra.span())),
            name_name.map_with(|name, extra| {
                let span = extra.span();
                TypeExpr::new(
                    TypeExprKind::Leaf(TypeLeaf::Limb(vec![Limb::Name(name)])),
                    None,
                    span,
                )
            }),
        ));

        let type_paren_open = just_punct(Punct::OpenParen).or(just_punct(Punct::CallOpen));

        let list_type = just_type_name("List")
            .ignore_then(type_paren_open.clone())
            .ignore_then(ty.clone().repeated().at_least(1).collect::<Vec<_>>())
            .then_ignore(just_punct(Punct::CloseParen))
            .map_with(|items, extra| {
                let span = extra.span();
                let inner = fold_type_pairs(items);
                TypeExpr::new(
                    TypeExprKind::Leaf(TypeLeaf::List(Box::new(inner))),
                    None,
                    span,
                )
            });

        let set_type = just_type_name("Set")
            .ignore_then(type_paren_open.clone())
            .ignore_then(ty.clone().repeated().at_least(1).collect::<Vec<_>>())
            .then_ignore(just_punct(Punct::CloseParen))
            .map_with(|items, extra| {
                let span = extra.span();
                let inner = fold_type_pairs(items);
                TypeExpr::new(
                    TypeExprKind::Leaf(TypeLeaf::Set(Box::new(inner))),
                    None,
                    span,
                )
            });

        let paren_type = type_paren_open
            .ignore_then(ty.clone().repeated().at_least(1).collect::<Vec<_>>())
            .then_ignore(just_punct(Punct::CloseParen))
            .then(just_punct(Punct::Arrow).ignore_then(ty.clone()).or_not())
            .map_with(|(items, output), extra| {
                let span = extra.span();
                let mut input = fold_type_pairs(items);
                if let Some(output) = output {
                    TypeExpr::new(
                        TypeExprKind::Leaf(TypeLeaf::Function {
                            input: Box::new(input),
                            output: Box::new(output),
                        }),
                        None,
                        span,
                    )
                } else {
                    input.span = span;
                    input
                }
            });

        let base = choice((list_type, set_type, paren_type, atom_leaf));

        let labeled = name_or_type
            .then_ignore(just_punct(Punct::Colon))
            .then(ty.clone())
            .map(|(name, ty)| ty.with_name(name));

        labeled.or(base).boxed()
    })
    .boxed()
}

fn number_literal<'src, I>() -> TokenParser<'src, I, String>
where
    I: ValueInput<'src, Token = TokenKind, Span = Span>,
{
    select! {
        TokenKind::Literal(Literal::Atom(AtomLiteral::Number(n))) => n,
        TokenKind::Literal(Literal::Atom(AtomLiteral::Sint(n))) => n,
    }
    .boxed()
}

fn just_kw<'src, I>(kw: crate::ast::Keyword) -> TokenParser<'src, I, ()>
where
    I: ValueInput<'src, Token = TokenKind, Span = Span>,
{
    just(TokenKind::Keyword(kw)).ignored().boxed()
}

fn just_punct<'src, I>(punct: Punct) -> TokenParser<'src, I, ()>
where
    I: ValueInput<'src, Token = TokenKind, Span = Span>,
{
    just(TokenKind::Punct(punct)).ignored().boxed()
}

fn just_type_name<'src, I>(name: &'static str) -> TokenParser<'src, I, ()>
where
    I: ValueInput<'src, Token = TokenKind, Span = Span>,
{
    select! { TokenKind::Type(ident) if ident == name => () }.boxed()
}

fn type_from_type_name(name: String, span: Span) -> TypeExpr {
    let leaf = match name.as_str() {
        "Atom" | "Uint" => TypeLeaf::Atom {
            atom: AtomType::Number,
            constant: false,
        },
        "Int" => TypeLeaf::Atom {
            atom: AtomType::Sint,
            constant: false,
        },
        "Hex" => TypeLeaf::Atom {
            atom: AtomType::Hex,
            constant: false,
        },
        "Real" => TypeLeaf::Atom {
            atom: AtomType::Real,
            constant: false,
        },
        "Real16" => TypeLeaf::Atom {
            atom: AtomType::Real16,
            constant: false,
        },
        "Real32" => TypeLeaf::Atom {
            atom: AtomType::Real32,
            constant: false,
        },
        "Real128" => TypeLeaf::Atom {
            atom: AtomType::Real128,
            constant: false,
        },
        "Logical" => TypeLeaf::Atom {
            atom: AtomType::Logical,
            constant: false,
        },
        "Date" => TypeLeaf::Atom {
            atom: AtomType::Date,
            constant: false,
        },
        "Span" => TypeLeaf::Atom {
            atom: AtomType::Span,
            constant: false,
        },
        "String" => TypeLeaf::Noun(NounType::String),
        "Path" => TypeLeaf::Noun(NounType::Path),
        _ => TypeLeaf::Limb(vec![Limb::Type(name)]),
    };

    TypeExpr::new(TypeExprKind::Leaf(leaf), None, span)
}

fn block<'src, I>(expr: TokenParser<'src, I, Expr>) -> TokenParser<'src, I, Expr>
where
    I: ValueInput<'src, Token = TokenKind, Span = Span>,
{
    just_punct(Punct::OpenBrace)
        .ignore_then(expr)
        .then_ignore(just_punct(Punct::CloseBrace))
        .boxed()
}

fn parse_lambda_input<'src, I>(ty: TokenParser<'src, I, TypeExpr>) -> TokenParser<'src, I, TypeExpr>
where
    I: ValueInput<'src, Token = TokenKind, Span = Span>,
{
    just_punct(Punct::OpenParen)
        .or(just_punct(Punct::CallOpen))
        .ignore_then(ty.repeated().at_least(1).collect::<Vec<_>>())
        .then_ignore(just_punct(Punct::CloseParen))
        .map_with(|items, extra| {
            let span = extra.span();
            let mut folded = fold_type_pairs(items);
            folded.span = span;
            folded
        })
        .boxed()
}

fn lambda_signature<'src, I>(
    ty: TokenParser<'src, I, TypeExpr>,
    expr: TokenParser<'src, I, Expr>,
) -> TokenParser<'src, I, Lambda>
where
    I: ValueInput<'src, Token = TokenKind, Span = Span>,
{
    parse_lambda_input(ty.clone())
        .then_ignore(just_punct(Punct::Arrow))
        .then(ty)
        .then(block(expr))
        .map(|((input, output), body)| Lambda {
            input,
            output,
            body: Box::new(body),
            context: None,
        })
        .boxed()
}

fn object_arms<'src, I>(
    expr: TokenParser<'src, I, Expr>,
) -> TokenParser<'src, I, Vec<(String, Expr)>>
where
    I: ValueInput<'src, Token = TokenKind, Span = Span>,
{
    let name = select! { TokenKind::Name(name) => name };
    name.then_ignore(just_punct(Punct::Equals))
        .then(expr)
        .map(|(name, value)| (name, value))
        .repeated()
        .collect::<Vec<_>>()
        .boxed()
}

fn class_methods<'src, I>(
    ty: TokenParser<'src, I, TypeExpr>,
    expr: TokenParser<'src, I, Expr>,
) -> TokenParser<'src, I, Vec<Method>>
where
    I: ValueInput<'src, Token = TokenKind, Span = Span>,
{
    let name = select! { TokenKind::Name(name) => name };
    name.then(parse_lambda_input(ty.clone()))
        .then_ignore(just_punct(Punct::Arrow))
        .then(ty)
        .then(block(expr))
        .map(|(((name, input), output), body)| Method {
            name,
            input,
            output,
            body: Box::new(body),
        })
        .repeated()
        .collect::<Vec<_>>()
        .boxed()
}

fn call_args<'src, I>(expr: TokenParser<'src, I, Expr>) -> TokenParser<'src, I, CallArgs>
where
    I: ValueInput<'src, Token = TokenKind, Span = Span>,
{
    let open = just_punct(Punct::CallOpen).or(just_punct(Punct::OpenParen));
    open.ignore_then(
        expr.clone()
            .repeated()
            .at_least(1)
            .collect::<Vec<_>>()
            .map(fold_pairs)
            .or_not(),
    )
    .then_ignore(just_punct(Punct::CloseParen))
    .map_with(|arg, extra| CallArgs {
        arg,
        span: extra.span(),
    })
    .boxed()
}

fn case_block<'src, I>(expr: TokenParser<'src, I, Expr>) -> TokenParser<'src, I, CaseBlock>
where
    I: ValueInput<'src, Token = TokenKind, Span = Span>,
{
    let case = expr
        .clone()
        .then_ignore(just_punct(Punct::Arrow))
        .then(expr.clone())
        .then_ignore(just_punct(Punct::Semi))
        .map(|(pattern, value)| (pattern, value));

    let default_case = just_punct(Punct::Underscore)
        .ignore_then(just_punct(Punct::Arrow))
        .ignore_then(expr)
        .then_ignore(just_punct(Punct::Semi));

    just_punct(Punct::OpenBrace)
        .ignore_then(case.repeated().collect::<Vec<_>>())
        .then(default_case.or_not())
        .then_ignore(just_punct(Punct::CloseBrace))
        .boxed()
}

fn if_after<'src, I>(expr: TokenParser<'src, I, Expr>) -> TokenParser<'src, I, Option<Expr>>
where
    I: ValueInput<'src, Token = TokenKind, Span = Span>,
{
    recursive(
        |after: Recursive<
            chumsky::recursive::Direct<'src, 'src, I, Option<Expr>, ParserExtra<'src>>,
        >| {
            let else_if = just_kw(crate::ast::Keyword::Else)
                .ignore_then(just_kw(crate::ast::Keyword::If))
                .ignore_then(expr.clone())
                .then(block(expr.clone()))
                .then(after.clone())
                .map(|((cond, then), otherwise)| {
                    let span = merge_span(&cond.span, &then.span);
                    Expr::new(
                        ExprKind::If {
                            cond: Box::new(cond),
                            then: Box::new(then),
                            otherwise: otherwise.map(Box::new),
                        },
                        span,
                    )
                });

            let else_block = just_kw(crate::ast::Keyword::Else).ignore_then(block(expr.clone()));

            else_if.or(else_block).or_not().boxed()
        },
    )
    .boxed()
}

fn fold_pairs(items: Vec<Expr>) -> Expr {
    let mut iter = items.into_iter().rev();
    let mut acc = match iter.next() {
        Some(expr) => expr,
        None => return Expr::new(ExprKind::Atom(AtomLiteral::Number("0".to_string())), 0..0),
    };

    for expr in iter {
        let span = merge_span(&expr.span, &acc.span);
        acc = Expr::new(ExprKind::Pair(Box::new(expr), Box::new(acc)), span);
    }

    acc
}

fn fold_type_pairs(items: Vec<TypeExpr>) -> TypeExpr {
    let mut iter = items.into_iter().rev();
    let mut acc = match iter.next() {
        Some(ty) => ty,
        None => TypeExpr::new(TypeExprKind::Leaf(TypeLeaf::None), None, 0..0),
    };

    for ty in iter {
        let span = merge_span(&ty.span, &acc.span);
        acc = TypeExpr::new(TypeExprKind::Cell(Box::new(ty), Box::new(acc)), None, span);
    }

    acc
}

fn merge_span(left: &Span, right: &Span) -> Span {
    let start = left.start.min(right.start);
    let end = left.end.max(right.end);
    start..end
}

fn make_operator(op: Operator, left: Expr, right: Expr) -> Expr {
    let span = merge_span(&left.span, &right.span);
    Expr::new(
        ExprKind::Operator {
            op,
            left: Box::new(left),
            right: Box::new(right),
        },
        span,
    )
}

fn unknown_type(span: Span) -> TypeExpr {
    TypeExpr::new(TypeExprKind::Leaf(TypeLeaf::None), None, span)
}

struct CallArgs {
    arg: Option<Expr>,
    span: Span,
}
