#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repository_root"

count_annotations() {
  local annotation="$1"
  find ArquitecturaTests -type f -name '*.swift' -exec awk -v annotation="$annotation" '
    $0 ~ "^[[:space:]]*@" annotation "([[:space:]]*\\(|[[:space:]]*$)" { count++ }
    END { print count + 0 }
  ' {} + | awk '{ total += $1 } END { print total + 0 }'
}

test_count="$(count_annotations Test)"
suite_count="$(count_annotations Suite)"

if [[ "$test_count" -eq 0 || "$suite_count" -eq 0 ]]; then
  echo "Expected Swift Testing declarations under ArquitecturaTests" >&2
  exit 1
fi

printf 'Swift Testing source: %s @Test declarations across %s @Suite declarations.\n' \
  "$test_count" "$suite_count"
