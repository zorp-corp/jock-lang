![](./img/wordmark-logo.png)

# Jock, a friendly and practical programming language

This is a developer preview of Jock, a friendly programming language that compiles to the [Nock instruction set architecture](#nock).

- [Jock language site](https://jock.org)
- [@JockNockISA on X](https://x.com/JockNockISA)

This repo contains the Jock base language, tutorial materials, and language unit tests.

## Resources

### Jock

The Jock compiler is written in [Hoon](https://docs.urbit.org) and runs on the NockApp architecture, [part of Nockchain](https://github.com/zorp-corp/nockchain).

Jock code results in Nock which can be run on any Nock VM ([Sword](https://github.com/zorp-corp/sword), [Vere](https://github.com/urbit/vere)).

- [Jock tutorial](https://docs.jock.org/getting-started)
- [Jock docs](https://docs.jock.org)
- [@JockNockISA on X](https://x.com/JockNockISA)

### Nock

Nock serves as the instruction set architecture for [Nockchain](https://nockchain.org), [zkVM](https://zorp.io/), and [Urbit](https://urbit.org), among other projects.  The Nock ISA is a minimalist combinator calculus.  All computations are reduced to a set of twelve opcodes that are easy to reason about and make proofs about.

- [Zorp, “Nock Definition”](https://zorp.io/nock/)
- [Urbit, “Nock Definition” (with discussion)](https://docs.urbit.org/language/nock/reference/definition)
- [~timluc-miptev, “Nock for Everyday Coders” (tutorial)](https://blog.timlucmiptev.space/part1.html)

### NockApp

The NockApp framework consists of Sword (formerly Ares), a runtime VM interpreter for Nock, the Crown Rust interface, and `hoonc`, which builds Nock programs from Jock or Hoon into executable standalones.

- [NockApp in Nockchain](https://github.com/zorp-corp/nockchain)
- [Announcement post](https://zorp.io/blog/nockapp-dev-alpha)

## Setup

1. Download and build `hoonc`, a NockApp compiler which forms part of Nockchain.

    - ​GitHub:  [zorp-corp/nockchain](https://github.com/zorp-corp/nockchain)

    ```sh
    make install-hoonc
    ```

2. In a separate location, download the Jock language repo (this repo).

    - ​GitHub:  [zorp-corp/jock-lang](https://github.com/zorp-corp/jock-lang)

3. Copy `hoonc` from `nockchain/target/build/release` to the root of `jock-lang`.

    ```sh
    cp nockchain/target/build/release/hoonc jock-lang/
    ```

### `jockc` Jock Compiler

If you are developing Jock code, you should use the Jock compiler tool `jockc`.

4. Build the Jock compiler and command-line execution environment:

    ```sh
    make jockc
    ```

5. Copy `jockc` from `target/build/release` to the root of `jock-lang`.

    ```sh
    cp target/build/release/jockc .
    ```

6. Run a Jock program directly using its path:

    ```sh
    ./jockc ./common/hoon/try/hello-world
    ./jockc ./common/hoon/try/fib 10
    ```

    See available demos:

    ```sh
    ls common/hoon/try
    ```

    Supply a path for library imports:

    ```sh
    ./jockc ./common/hoon/try/import --import-dir ./common/hoon/jib
    ```

7. Run a demo with its name and any arguments:

    ```sh
    ./jockc hello-world
    ./jockc fib 10
    ```

    The demo will output several pieces of information:

    1. `%parse`, the tokenization.
    2. `%jeam`, the Jock abstract syntax tree (AST).
    3. `%mint`, the compiled Nock (which will be rather long; output is currently slow).
    4. `%jype`, the Jock result type.
    5. `%nock`, the evaluated Nock result, as an atom (unsigned decimal value).

    For a tutorial like `hello-world`, the Nock text will be printed as the numeric equivalent of the hexadecimal for the time being.

    (Rust logs from `hoonc` tend to be obnoxiously verbose; to make them more concise, use `MINIMAL_LOG_FORMAT=true` as a command-line environment variable, e.g. `MINIMAL_LOG_FORMAT=true ./jockc fib 10`.  You can also run the same minified log format with `make run fib 10`.)

8. Add a new demo by saving Jock code in `/common/hoon/try` and running it by name.

    If you modify the Hoon code located in `/crates/jockc/hoon/lib` or `/common/hoon/try`, run `make jockc` before running the new code.

    If you modify the Rust code in `/crates/jockc/main.rs`, run `make jockc`.

### `jockt` Jock Test Framework

If you are developing Jock itself, you should use the Jock testing tool `jockt` to verify behavior.

9. Build the Jock testing tool:

    ```sh
    make jockt
    ```

10. Copy `jockt` from `target/build/release` to the root of `jock-lang`.

    ```sh
    cp target/build/release/jockt .
    ```

11. Run a Jock program using its internal index:

    ```sh
    ./jockt exec 5
    # - or -
    make exec 5
    ```

    These are listed in `/hoon/lib/test-jock.hoon`.

    The demo will output several pieces of information:

    1. `%parse`, the tokenization.
    2. `%jeam`, the Jock abstract syntax tree (AST).
    3. `%mint`, the compiled Nock (which will be rather long).
    4. `%jype`, the Jock result type.
    5. `%nock`, the evaluated Nock result, as an atom.

    Alternatively, run all codes:

    ```sh
    ./jockt exec-all
    # - or -
    make release-exec-all
    ```

12. Run a Jock program with all tests:

    ```sh
    ./jockt test 5
    # - or -
    make test 5
    ```

    These indices are identical to those obtained in the previous step from `/hoon/lib/test-jock.hoon`.

    Alternatively, run all tests (slow):

    ```sh
    ./target/release/jocktest test-all
    # - or -
    make release-test-all
    ```

## Releases

- [0.0.0-dp, Developer Preview](https://zorp.io/blog/jock), ~2024.10.24
- 0.1.0-alpha, ~2025.6.26
