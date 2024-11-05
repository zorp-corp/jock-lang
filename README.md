# Jock, a friendly and practical programming language

This is a developer preview of Jock, a friendly programming language that compiles to Nock.

Visit the [blog post](https://zorp.io/blog/jock) for more information.

The Jock compiler is written in Hoon.

##  Building

We recommend including the `choo` NockApp executable in the repo for convenience.  The path to the `choo` executable in these docs assumes this configuration.

```bash
# Building the JockApp pill with Choo (check the latest version)
CHOO_VERSION=0.1.3 bash -c 'curl -L -o choo https://github.com/zorp-corp/nockapp/releases/download/choo-"$CHOO_VERSION"/choo'
chmod u+x choo
./choo hoon/main.hoon hoon

# Produce the Jock NockApp
## Build only
make build
## Build and run release version
make release
## - or -
cargo build --release

# Testing Jock
./target/release/jock-testing test-all
./target/release/jock-testing test-n 5
```

For `choo`, the first argument is the entrypoint to the program, while the second argument is the root directory for source files.
