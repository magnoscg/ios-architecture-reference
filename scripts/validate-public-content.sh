#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repository_root"

fail() {
  echo "Public-content validation failed: $*" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "missing required file: $1"
}

image_dimensions() {
  local image="$1"
  local width height
  width="$(sips -g pixelWidth "$image" | awk '/pixelWidth/ { print $2 }')"
  height="$(sips -g pixelHeight "$image" | awk '/pixelHeight/ { print $2 }')"
  printf '%sx%s' "$width" "$height"
}

check_assets() {
  local required_assets=(
    "docs/images/social-preview.svg"
    "docs/images/social-preview.png"
    "docs/images/architecture-list-light.png"
    "docs/images/architecture-detail-light.png"
    "docs/images/architecture-list-dark.png"
    "docs/images/architecture-detail-dark.png"
  )

  require_file "ASSET_PROVENANCE.md"
  require_file "scripts/assets.sha256"

  for asset in "${required_assets[@]}"; do
    require_file "$asset"
  done

  [[ "$(image_dimensions docs/images/social-preview.png)" == "1280x640" ]] || \
    fail "docs/images/social-preview.png must be 1280x640"
  grep -Eq 'viewBox="0 0 1280 640"|width="1280"[^>]*height="640"' docs/images/social-preview.svg || \
    fail "docs/images/social-preview.svg must declare a 1280x640 canvas"
  grep -Fq 'Single app target' docs/images/social-preview.svg || \
    fail "the social preview must describe the production boundary as a single app target"

  for screenshot in \
    docs/images/architecture-list-light.png \
    docs/images/architecture-detail-light.png \
    docs/images/architecture-list-dark.png \
    docs/images/architecture-detail-dark.png; do
    [[ "$(image_dimensions "$screenshot")" == "1206x2622" ]] || \
      fail "$screenshot must be an authentic 1206x2622 simulator capture"
  done

  shasum -a 256 -c scripts/assets.sha256

  while IFS= read -r asset; do
    grep -Fq "$asset" ASSET_PROVENANCE.md || fail "asset is missing from ASSET_PROVENANCE.md: $asset"
    grep -Fq "  $asset" scripts/assets.sha256 || fail "asset is missing from scripts/assets.sha256: $asset"
  done < <(
    find docs/images -type f \
      \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.svg' -o -iname '*.pdf' \) \
      | sort
  )

  [[ ! -e Arquitectura/Resources/Assets.xcassets/pokeball.imageset/pokeball.svg ]] || \
    fail "the unverified Pokeball SVG must not be distributed"

  echo "Validated asset dimensions, provenance and SHA-256 manifest."
}

if [[ "${1:-}" == "--assets-only" ]]; then
  check_assets
  exit 0
fi

if [[ $# -ne 0 ]]; then
  fail "unknown argument: $1"
fi

required_files=(
  ".swiftformat"
  ".swiftlint.yml"
  "README.md"
  "README.es.md"
  "ARCHITECTURE.md"
  "ARCHITECTURE.es.md"
  "SECURITY.md"
  "CONTRIBUTING.md"
  "ASSET_PROVENANCE.md"
  "THIRD_PARTY_NOTICES.md"
  "LICENSE.md"
  "Arquitectura.xcodeproj/project.pbxproj"
  "Arquitectura.xcodeproj/xcshareddata/xcschemes/Arquitectura-Dev.xcscheme"
  "ArquitecturaTests/ArquitecturaTests.xctestplan"
  "docs/PROJECT-STRUCTURE.md"
  "docs/PROJECT-STRUCTURE.es.md"
  "docs/KNOWN-LIMITATIONS.md"
  "docs/KNOWN-LIMITATIONS.es.md"
  "docs/SOURCE-PROVENANCE.md"
  "docs/V1-SPM-REFERENCE.md"
)

for required_file in "${required_files[@]}"; do
  require_file "$required_file"
done

required_directories=(
  "Arquitectura/App"
  "Arquitectura/Core"
  "Arquitectura/Data"
  "Arquitectura/Domain"
  "Arquitectura/Features"
  "ArquitecturaTests"
)

for required_directory in "${required_directories[@]}"; do
  [[ -d "$required_directory" ]] || fail "missing required directory: $required_directory"
done

public_root_allowlist=(
  ".github"
  ".gitignore"
  ".swiftformat"
  ".swiftlint.yml"
  "ARCHITECTURE.es.md"
  "ARCHITECTURE.md"
  "ASSET_PROVENANCE.md"
  "Arquitectura"
  "Arquitectura.xcodeproj"
  "ArquitecturaTests"
  "CHANGELOG.md"
  "CONTRIBUTING.md"
  "LICENSE.md"
  "Makefile"
  "README.es.md"
  "README.md"
  "SECURITY.md"
  "THIRD_PARTY_NOTICES.md"
  "docs"
  "scripts"
)

while IFS= read -r root_entry; do
  is_allowed_root=0
  for allowed_root in "${public_root_allowlist[@]}"; do
    if [[ "$root_entry" == "$allowed_root" ]]; then
      is_allowed_root=1
      break
    fi
  done

  [[ "$is_allowed_root" -eq 1 ]] || fail "an unexpected repository-root entry is outside the public allowlist"
done < <(
  find . -mindepth 1 -maxdepth 1 ! -name .git ! -name .build -print |
    sed 's#^\./##' |
    sort
)

for forbidden_path in Example Sources Tests Package.swift; do
  [[ ! -e "$forbidden_path" ]] || fail "legacy or private path must not be distributed: $forbidden_path"
done

if git ls-files | grep -Eq '(^|/)(xcuserdata|\.swiftpm|\.build|\.claude|\.opencode|\.agents|logs|models)(/|$)|\.xcuserstate$|\.DS_Store$'; then
  fail "a local, generated or private path is tracked"
fi

if grep -RIniE \
  --exclude-dir=.git --exclude-dir=.build --exclude-dir=__pycache__ \
  --exclude='validate-public-content.sh' --exclude='V1-SPM-REFERENCE.md' --exclude='CHANGELOG.md' \
  '4 modules|4 m[oó]dulos|15 tests|15 pruebas|15 Swift Testing' .; then
  fail "a stale v1 module or test-count claim was found"
fi

if grep -RInIE \
  --exclude-dir=.git --exclude-dir=.build --exclude-dir=__pycache__ \
  --exclude='validate-public-content.sh' \
  'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|github_pat_[A-Za-z0-9_]{20,}|ghp_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|sk-[A-Za-z0-9]{20,}|sk_live_[A-Za-z0-9]+|xox[baprs]-[A-Za-z0-9-]+|Bearer [A-Za-z0-9._-]{20,}' .; then
  fail "a credential-like value was found"
fi

if grep -RInIE \
  --exclude-dir=.git --exclude-dir=.build --exclude-dir=__pycache__ \
  --exclude='validate-public-content.sh' \
  '(/Users/[^/]+/|/home/[^/]+/|file:///)' .; then
  fail "a local absolute path leaked into public content"
fi

grep -Fq 'BlueprintName = "Arquitectura"' \
  Arquitectura.xcodeproj/xcshareddata/xcschemes/Arquitectura-Dev.xcscheme || \
  fail "Arquitectura-Dev is not a shared app scheme"
grep -Fq 'ArquitecturaTests/ArquitecturaTests.xctestplan' \
  Arquitectura.xcodeproj/xcshareddata/xcschemes/Arquitectura-Dev.xcscheme || \
  fail "Arquitectura-Dev does not reference the shared test plan"
grep -Fq 'architecture_details.json in Resources' Arquitectura.xcodeproj/project.pbxproj || \
  fail "architecture_details.json is not explicitly copied into the app bundle"
grep -Fq 'DEVELOPMENT_TEAM = "";' Arquitectura.xcodeproj/project.pbxproj || \
  fail "Xcode signing teams must remain consumer-defined"
if grep -F 'DEVELOPMENT_TEAM =' Arquitectura.xcodeproj/project.pbxproj |
  grep -Fvq 'DEVELOPMENT_TEAM = "";'; then
  fail "a concrete Apple development-team identifier is present"
fi
grep -Fq '"name" : "ArquitecturaTests"' ArquitecturaTests/ArquitecturaTests.xctestplan || \
  fail "the test plan does not include ArquitecturaTests"
if grep -Fq 'ArquitecturaUITests' ArquitecturaTests/ArquitecturaTests.xctestplan; then
  fail "the test plan must not claim an empty UI test target"
fi

grep -Fq 'REPLACE_WITH_YOUR_PRODUCTION_CERTIFICATE_HASH' \
  Arquitectura/App/Config/Xcconfig/Production.xcconfig || \
  fail "Production must remain an illustrative template until configured by a consumer"
grep -Fq '81f37c52f7a385247999ad30cc0d5a913f57192b' docs/SOURCE-PROVENANCE.md || \
  fail "source provenance must identify the fixed private source snapshot"

./scripts/count-swift-tests.sh
python3 scripts/validate_architecture_catalog.py
python3 scripts/validate_markdown_links.py
python3 scripts/validate_doc_pairs.py
check_assets
git diff --check

echo "Validated the Xcode reference, public boundary and documentation evidence."
