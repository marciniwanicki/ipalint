mise := ~/.local/bin/mise

VERSION_MAJOR = 0
VERSION_MINOR = 1
VERSION_PATCH = 0
VERSION = $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
GIT_SHORT_HASH = $(shell git rev-parse --short HEAD)

configure:
	curl "https://mise.run" | sh

env:
	@$(mise) run env

build: env
	@$(mise) run build

clean:
	@$(mise) run clean

test:
	@$(mise) run test

lint:
	@$(mise) run lint

format:
	@$(mise) run format
