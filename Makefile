.PHONY: all assets build test validate

all: test build validate

assets:
	swift scripts/render-brand-assets.swift

build:
	swift build -c release

test:
	swift test

validate:
	./scripts/validate-public-content.sh
