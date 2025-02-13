# Jock, a friendly and practical programming language

This is a developer preview of Jock, a friendly programming language that compiles to the Nock combinator calculus.

- [Jock language site](https://jock.org)
- [Announcement post](https://zorp.io/blog/jock)

The Jock compiler is written in Hoon and runs on the NockApp architecture.

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

# run all codes in /lib/tests
./target/release/jock-testing exec-all
# - or -
make release-test-all

# run specific code in /lib/tests
./target/release/jock-testing test-n 0
# - or -
make test 0
```
