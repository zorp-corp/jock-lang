# Jock, a friendly and practical programming language

This is a developer preview of Jock, a friendly programming language that compiles to Nock.

Visit the [blog post](https://zorp.io/blog/jock) for more information.

The Jock compiler is written in Hoon.

##  Building

Jock requires a `choo` NockApp executable.  The `Makefile` can retrieve the latest tagged `choo`.  If you would like a nightly build, you should simply include the appropriate `choo` in the root folder instead.

```bash
make update-choo
```

To build and run Jock with tests:

```bash
make release

./target/release/jock-testing test-all
```
