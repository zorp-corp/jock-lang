export RUST_BACKTRACE := full
export RUST_LOG := info
export MINIMAL_LOG_FORMAT := true

ifneq (,$(wildcard ./.env))
	include .env
	export
endif

.DEFAULT_GOAL := build
.PHONY: build
build:
	cargo build --release

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

PROFILE_DEV_DEBUG = --profile dev
PROFILE_RELEASE = --profile release

.PHONY: build
build: build-dev-debug

.PHONY: release
release: build-release

.PHONY: test
test:
	@if [ $(words $(MAKECMDGOALS)) -lt 2 ]; then \
		echo "Usage: make test <number>"; \
		exit 1; \
	fi
	$(call show_env_vars)
	RUST_LOG=TRACE cargo run $(PROFILE_RELEASE) -- --new test $(word 2,$(MAKECMDGOALS))
	@exit 0

.PHONY: exec
exec:
	@if [ $(words $(MAKECMDGOALS)) -lt 2 ]; then \
		echo "Usage: make exec <number>"; \
		exit 1; \
	fi
	$(call show_env_vars)
	RUST_LOG=TRACE cargo run $(PROFILE_RELEASE) -- --new exec $(word 2,$(MAKECMDGOALS))
	@exit 0

%::
	@:

.PHONY: release-exec-all
release-exec-all:
	$(call show_env_vars)
	@echo "Running release exec-all"
	RUST_LOG=TRACE MINIMAL_LOG_FORMAT=true cargo run $(PROFILE_RELEASE) -- --new exec-all
	@exit 0

.PHONY: release-test-all
release-test-all:
	$(call show_env_vars)
	@echo "Running release test-all"
	RUST_LOG=TRACE MINIMAL_LOG_FORMAT=true cargo run $(PROFILE_RELEASE) -- --new test-all
	@exit 0

.PHONY: build
build: jockc jockt ## Build the Jock compiler and tester

.PHONY: clean
clean: ## Clean all projects
	@set -e; \
	rm -rf .data.hoonc/ ; \
	rm -rf target/ ; \
	rm -rf assets/*.jam ; \
	cargo clean
	@exit 0

HOON_TARGETS=assets/jockc.jam assets/jockt.jam

assets/jockc.jam:
	@set -e; \
	RUST_LOG=trace MINIMAL_LOG_FORMAT=true ./hoonc crates/jockc/hoon/main.hoon crates/jockc/hoon; \
	mv out.jam assets/jockc.jam; \
	exit 0

assets/jockt.jam:
	@set -e; \
	RUST_LOG=trace MINIMAL_LOG_FORMAT=true ./hoonc crates/jockt/hoon/main.hoon crates/jockt/hoon; \
	mv out.jam assets/jockt.jam; \
	exit 0

.PHONY: jockc
jockc: $(HOON_TARGETS) ## Compile the Jock compiler
	@set -e; \
	RUST_LOG=trace MINIMAL_LOG_FORMAT=true ./hoonc crates/jockc/hoon/main.hoon crates/jockc/hoon; \
	mv out.jam assets/jockc.jam; \
	cargo build $(PROFILE_RELEASE); \
	exit 0

.PHONY: jockt
jockt: $(HOON_TARGETS) ## Compile the Jock tester
	@set -e; \
	RUST_LOG=trace MINIMAL_LOG_FORMAT=true ./hoonc crates/jockt/hoon/main.hoon crates/jockt/hoon; \
	mv out.jam assets/jockt.jam; \
	cargo build $(PROFILE_RELEASE); \
	exit 0
