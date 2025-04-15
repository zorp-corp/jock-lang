# Infix operators

## Arithmetic

- `+` addition, resolves to `++add`, `++add:rd`, or `add()` method.
- `-` subtraction, resolves to `++sub`, `++sub:rd`, or `sub()` method.
- `*` multiplication, resolves to `++mul`, `++mul:rd`, or `mul()` method.
- `/` divison, resolves to `++div`, `++div:rd`, or `div()` method.
- `%` remainder after division, resolves to `++dvr` or `mod()` method.
- `**` exponentiation, resolves to `++pow` or `pow()` method.

Precedence needs to be clear:  most likely simply left-to-right or using `()` around single terms.

## Logical

- `&&`/`and` AND
- `||`/`or` OR
- `^`/`xor` XOR
- `!`/`not` NOT

## Not infix

- `+` prefix unary positive, resolves to `abs()` method.
- `-` prefix unary negation, resolves to `neg()` method.
- `||` prefix/postfix absolute value, resolves to `abs()` method.
