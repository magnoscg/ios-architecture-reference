#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repository_root"

required_files=(
  "README.md"
  "README.es.md"
  "ARCHITECTURE.md"
  "SECURITY.md"
  "CONTRIBUTING.md"
  "ASSET_PROVENANCE.md"
  "LICENSE.md"
  "Package.swift"
  "docs/images/social-preview.png"
  "docs/images/ogamlabs-signature.png"
  "docs/images/brand-source/logo_ogamlabs_horizontal_full-color_light_1600x500.png"
)

for required_file in "${required_files[@]}"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Missing required public file: $required_file" >&2
    exit 1
  fi
done

module_count="$(find Sources -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
if [[ "$module_count" != "4" ]]; then
  echo "Expected 4 source modules, found $module_count" >&2
  exit 1
fi

if grep -RInE 'CholloGas|Hilo' Sources Tests; then
  echo "Product-specific code crossed the public reference boundary" >&2
  exit 1
fi

if grep -RInE 'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|ghp_[A-Za-z0-9]{20,}|sk_live_[A-Za-z0-9]+|xox[baprs]-[A-Za-z0-9-]+' . \
  --exclude-dir=.git \
  --exclude-dir=.build \
  --exclude='validate-public-content.sh'; then
  echo "A credential-like value was found" >&2
  exit 1
fi

if grep -RIn '/Users/' Sources Tests README.md README.es.md ARCHITECTURE.md SECURITY.md; then
  echo "A local absolute path leaked into distributed content" >&2
  exit 1
fi

if grep -Fq '.package(' Package.swift; then
  echo "The zero-third-party-dependency claim no longer matches Package.swift" >&2
  exit 1
fi

for phrase in \
  'This is an original reference implementation by Oscar Canton.' \
  '15 Swift Testing checks' \
  'Zero third-party package dependencies'; do
  if ! grep -Fq "$phrase" README.md; then
    echo "README evidence is missing: $phrase" >&2
    exit 1
  fi
done

source_logo_hash="$(shasum -a 256 docs/images/brand-source/logo_ogamlabs_horizontal_full-color_light_1600x500.png | awk '{print $1}')"
if [[ "$source_logo_hash" != "4c42e1beda262f4986d6893708196108e636ba3e6c1c9b97594e6682c4550cf5" ]]; then
  echo "The first-party logo export changed unexpectedly" >&2
  exit 1
fi

social_preview_hash="$(shasum -a 256 docs/images/social-preview.png | awk '{print $1}')"
signature_hash="$(shasum -a 256 docs/images/ogamlabs-signature.png | awk '{print $1}')"

if [[ "$social_preview_hash" != "921351cb3439e48855c1bdd50d3b791f6c0d06244baff62a9cb9248b4f577e29" ]]; then
  echo "The social preview does not match the reviewed render" >&2
  exit 1
fi

if [[ "$signature_hash" != "7345557ca0b992f49a2c98a1708fd2f3f80e55df897aade93ef5d4929ab28299" ]]; then
  echo "The README signature does not match the reviewed render" >&2
  exit 1
fi

social_width="$(sips -g pixelWidth docs/images/social-preview.png | awk '/pixelWidth/ {print $2}')"
social_height="$(sips -g pixelHeight docs/images/social-preview.png | awk '/pixelHeight/ {print $2}')"
signature_width="$(sips -g pixelWidth docs/images/ogamlabs-signature.png | awk '/pixelWidth/ {print $2}')"
signature_height="$(sips -g pixelHeight docs/images/ogamlabs-signature.png | awk '/pixelHeight/ {print $2}')"

if [[ "$social_width" != "1280" || "$social_height" != "640" ]]; then
  echo "Social preview must remain 1280x640" >&2
  exit 1
fi

if [[ "$signature_width" != "512" || "$signature_height" != "160" ]]; then
  echo "README signature must remain 512x160" >&2
  exit 1
fi

git diff --check
echo "Validated 4 modules, public boundaries and reviewed brand assets."
