mise := ~/.local/bin/mise

VERSION_MAJOR = 0
VERSION_MINOR = 1
VERSION_PATCH = 0
VERSION = $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
GIT_SHORT_HASH = $(shell git rev-parse --short HEAD)

define HELP_BODY
USAGE: make <subcommand>

SUBCOMMANDS:
  help                    Show help.
  setup                   Set up development environment.
  clean                   Clean build folder.
  env                     Show build environment.
  build                   Build (debug).
  test                    Run tests.
  format                  Format source code.
  lint                    Lint source code.

endef
export HELP_BODY

help:
	@echo "$$HELP_BODY"

setup:
	curl "https://mise.run" | sh

clean:
	@$(mise) run clean

env:
	@$(mise) run env

build: env
	@$(mise) run build

test:
	@$(mise) run test

format:
	@$(mise) install
	@$(mise) run format

lint:
	@$(mise) install
	@$(mise) run lint
