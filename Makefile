.DEFAULT_GOAL := help
.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Slow!
PROFILE_DEV_DEBUG = --profile dev
# Fast!
PROFILE_DEV_FAST = --profile dev-fast
# Fastest!
PROFILE_RELEASE = --profile release

# Retrieve latest choo build.
CHOO_URL=https://github.com/zorp-corp/nockapp
CHOO_TAG=$(shell git ls-remote --tags $(CHOO_URL) | grep 'refs/tags/choo-' | grep -o 'refs/tags/.*' | sed 's/refs\/tags\///' | sort -V | tail -n1)

-: ## -----------------------------------------------------------
-: ## --------------  Commonly used commands below --------------
-: ## -----------------------------------------------------------

.PHONY: build
build: build-dev-fast ## Build in default profile (dev-fast)

.PHONY: release
release: build-release

.PHONY: release-test-zero
release-test-zero:
	cargo run $(PROFILE_RELEASE) -- --new test-n 0

.PHONY: release-test-all
release-test-all:
	cargo run $(PROFILE_RELEASE) -- --new test-all

-: ## -----------------------------------------------------------
-: ## ---------- Rest of the commands in the Makefile -----------
-: ## -----------------------------------------------------------

.PHONY: build-dev-fast
build-dev-fast: ## Slower to compile, faster to execute. Builds all projects
	@set -e; \
	./choo hoon/main.hoon hoon; \
	cp out.jam assets/jocktest.jam; \
	cargo build $(PROFILE_DEV_FAST)

.PHONY: build-parallel
build-parallel: ## profiling profile with parallel feature enabled
	@set -e; \
	./choo hoon/main.hoon hoon; \
	cp out.jam assets/jocktest.jam; \
	cargo build $(FEATURES_PARALLEL) $(PROFILE_PROFILING)

.PHONY: build
build-dev-debug: ## Fast to compile, slow to execute. Builds all projects
	@set -e; \
	./choo hoon/main.hoon hoon; \
	cp out.jam assets/jocktest.jam; \
	cargo build

.PHONY: build-release
build-release: ## Slowest to compile, fastest to execute. Builds all projects
	@set -e; \
	./choo hoon/main.hoon hoon; \
	cp out.jam assets/jocktest.jam; \
	cargo build $(PROFILE_RELEASE)

.PHONY: update-choo
update-choo:
	curl -L -o choo "$(CHOO_URL)/releases/download/$(CHOO_TAG)/choo"
	chmod u+x choo

.PHONY: choo-version
choo-version:
	@echo "Latest choo version: $(CHOO_TAG)"
