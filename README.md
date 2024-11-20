# Jock, a friendly and practical programming language

This is a developer preview of Jock, a friendly programming language that compiles to Nock.

Visit the [blog post](https://zorp.io/blog/jock) for more information.

The Jock compiler is written in Hoon.

##  Prerequisites

Jock requires a `choo` NockApp executable.  The `Makefile` can retrieve the latest tagged `choo`.  For Linux, run the following:

```bash
make update-choo
```

If you would like a nightly build of `choo`, or if you are using something other than Linux, [clone this repo](https://github.com/zorp-corp/nockapp) and build.
Then copy the `choo` executable to the root folder.

## Building

To build and run Jock with tests:

```bash
make release

./target/release/jock-testing test-all
```

This will execute all of the supplied programs, then run unit tests over each of the compilation steps in producing each program's Nock.
