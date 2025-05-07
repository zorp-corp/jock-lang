# Jock, a friendly and practical programming language

This is a developer preview of Jock, a friendly programming language that compiles to the Nock combinator calculus.

- [Jock language site](https://jock.org)
- [Announcement post](https://zorp.io/blog/jock)

![](./img/wordmark-logo.png)

The Jock compiler is written in [Hoon](https://docs.urbit.org) and runs on the NockApp architecture, [part of Nockchain](https://github.com/zorp-corp/nockchain).

Jock code results in Nock which can be run on any Nock VM ([Sword](https://github.com/zorp-corp/sword), [Vere](https://github.com/urbit/vere)).

## Resources

- [Jock tutorial repo](https://github.com/zorp-corp/jockapp-tutorial)
- [Jock tutorial site](https://docs.jock.org/getting-started)
- [Jock docs](https://docs.jock.org)

## Setup

1. Download and build `choo`, a NockApp compiler which forms part of Nockchain.

    - ​GitHub:  [zorp-corp/nockchain](https://github.com/zorp-corp/nockchain)

    ```sh
    make install-choo
    ```

2. In a separate location, download the Jock language repo (this repo).

    - ​GitHub:  [zorp-corp/jock-lang](https://github.com/zorp-corp/jock-lang)

3. Copy `choo` from `nockchain/target/build/release` to the root of `jock-lang`.

    ```sh
    cp nockchain/target/build/release/choo jock-lang/
    ```

4. Compile the examples:

    ```sh
    cd jockapp-tutorial
    make release
    ```

5. Run one of the available demos from `/hoon/lib/tests`:

    ```bash
    ./target/release/jocktest test 0
    # - or -
    make test 0
    ```

    The demo will output several pieces of information:

    1. `%parse`, the tokenization.
    2. `%jeam`, the Jock abstract syntax tree (AST).
    3. `%mint`, the compiled Nock (which will be rather long).
    4. `%jype`, the Jock result type.
    5. `%nock`, the evaluated Nock result, as an atom.

    Alternatively, run all codes:

    ```bash
    ./target/release/jocktest exec-all
    # - or -
    make release-exec-all
    ```

    Or run all tests (slow):

    ```bash
    ./target/release/jocktest test-all
    # - or -
    make release-test-all

    ```
