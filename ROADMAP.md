# Roadmap

## Cache noun builds

Cache large noun builds.

- Current status:  `hoon` and other libraries are rebuilt every time they are used, which is expensive and should be avoided.

## Floating-point support

Support a fractional-part number system.

(I, @sigilante, have a lot of opinions on this.  Talk to me before digging into this one.)

## Function self-reference by name

Allow functions to refer to themselves by name rather than strictly by `$`.

## Gate-building gate interface

Define a syntax to successfully use gate-building gates from the Hoon FFI.

## Generalized compiler namespace

Supply varargs and other features to the compiler for use in Jock programs.

This involves converting the single `$map` in the compiler door sample to a `mip` with standard entries like `libs` and `args`.

- Current status:  libraries can be supplied to the sample of the compiler door as a `(map term cord)`.  (This should be changed to `(map path cord)` for flexibility, versioning, etc.)  `jockc` supports preprocessed argument insertion, but this should be replaced with this better system.

## Hoon return types

Implement Jock-compatible `$jype` values for Hoon FFI returns.

## `List` syntax support

Include syntactical affordances for indexing, slicing, etc.

```
let mylist = [1 2 3 4 5];
(
    mylist[0]
    mylist[1:4]
)
```

- Current status:  the Hoon FFI permits these operations but no syntax is available.

## `Map` type and syntax

Implement a native `Map` type with syntax support.

```
{
    'a' -> 'A'
    'b' -> 'B'
    'c' -> 'C'
}
```

## Operator associativity

Change to left-to-right association to minimize surprise.

## `Path` type

Implement a `List(String)` type with syntax support.

This will facilitate paths and wires for JockApp interactions.

## `print` keyword

Produce output as a side effect.

```
let a = 5;
print(a);
a
```

- Current status:  PR #53 contains work towards wrapping the environment in a closure so that references can be resolved at runtime.

## `protocol` traits interface

Define a list of methods and type relations to be validated at compile time.

A `protocol` is a definition of the allowed and type signatures that a class must implement.  It may be `total` (only these methods are allowed) or partial (at least these methods are allowed, default).  Eventually, `protocol` will form the basis of an operator overloading system.

```
compose
    protocol Arithmetic {
        add(# #) -> #;
        sub(# #) -> #;
        bitwidth(#) -> ##;
    };

class Number implements Arithmetic {
    add(x:Number y:Number) -> Number {
        x + y
    }
    sub(x:Number y:Number) -> Number {
        if (y > x) {
            crash;
        } else {
            x - y
        }
    }
    bitwidth(x:Number) -> Uint {
        // logic to get log2 + 1
    }
}
```

## REPL development

Produce a feature-complete, fast Jock REPL/CLI.

[Jojo](https://github.com/sigilante/jojo) is a proof of concept, and does not represent any serious thought towards the "best" solution.

## Strings

Implement true strings with operators.

Strings should be `cord` UTF-8 encodings, as `tape`s are several times larger in memory representation.  Strings may or may not be agnostic to quote type (defer this decision).

```
let forename:String = "Buckminster";
let surname:String = "Fuller";
forename + " " + surname
```

- Current status:  Right now we can write strings but operations on them must be routed through the Hoon FFI.  PR #59 contains work towards supporting and testing strings.
