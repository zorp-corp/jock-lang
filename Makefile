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

.PHONY: release-test-all
release-test-all:
	$(call show_env_vars)
	@echo "Running release test-all"
	RUST_LOG=TRACE MINIMAL_LOG_FORMAT=true cargo run $(PROFILE_RELEASE) -- --new test-all

.PHONY: build
build-dev-debug:
	$(call show_env_vars)
	RUST_LOG=trace ./choo hoon/main.hoon hoon; \
	mv out.jam assets/jocktest.jam; \
	cargo build $(PROFILE_DEV_DEBUG)

.PHONY: build-release
build-release:
	$(call show_env_vars)
	RUST_LOG=trace ./choo hoon/main.hoon hoon; \
	mv out.jam assets/jocktest.jam; \
	cargo build $(PROFILE_RELEASE)

.PHONY: clean
clean: ## Clean all projects
	@set -e; \
	rm -rf .data.choo/ ; \
	rm -rf target/ ; \
	cargo clean
