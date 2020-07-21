VERSION_MAJOR = 0
VERSION_MINOR = 1
VERSION_PATCH = 0
VERSION = $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
GIT_SHORT_HASH = $(shell git rev-parse --short HEAD)

configure:
	./Scripts/configure.sh

clean:
	./Scripts/clean.sh

build:
	./Scripts/build.sh

test:
	./Scripts/test.sh

lint:
	./Scripts/lint.sh

format:
	./Scripts/format.sh
