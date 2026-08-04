.PHONY: all assets build ci format lint simulator-id test test-metadata validate validator-tests verify-bundle

PROJECT := Arquitectura.xcodeproj
SCHEME := Arquitectura-Dev
CONFIGURATION := Debug-Development
DERIVED_DATA_PATH ?= .build/DerivedData
APP_BUNDLE := $(DERIVED_DATA_PATH)/Build/Products/$(CONFIGURATION)-iphonesimulator/Arquitectura.app
SIMULATOR_ID ?= $(shell python3 scripts/select_ios_simulator.py)
DESTINATION ?= platform=iOS Simulator,id=$(SIMULATOR_ID)
XCODEBUILD = xcodebuild \
	-project "$(PROJECT)" \
	-scheme "$(SCHEME)" \
	-configuration "$(CONFIGURATION)" \
	-destination "$(DESTINATION)" \
	-derivedDataPath "$(DERIVED_DATA_PATH)" \
	CODE_SIGNING_ALLOWED=NO \
	ONLY_ACTIVE_ARCH=YES

all: ci

assets:
	./scripts/validate-public-content.sh --assets-only

build:
	$(XCODEBUILD) build

test:
	$(XCODEBUILD) test

format:
	swiftformat --config .swiftformat Arquitectura ArquitecturaTests scripts

lint:
	swiftformat --lint --cache ignore --config .swiftformat Arquitectura ArquitecturaTests scripts
	swiftlint lint --strict --quiet --no-cache --config .swiftlint.yml

simulator-id:
	@python3 scripts/select_ios_simulator.py

test-metadata:
	@./scripts/count-swift-tests.sh

validator-tests:
	python3 -m unittest discover -s scripts/tests -p 'test_*.py'

validate: validator-tests
	./scripts/validate-public-content.sh

verify-bundle:
	test -f "$(APP_BUNDLE)/architecture_details.json"
	cmp -s Arquitectura/Resources/Data/architecture_details.json "$(APP_BUNDLE)/architecture_details.json"

ci:
	$(MAKE) validate
	$(MAKE) lint
	$(MAKE) build
	$(MAKE) verify-bundle
	$(MAKE) test
	git diff --exit-code
