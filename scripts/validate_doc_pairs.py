#!/usr/bin/env python3
"""Validate structural and technical parity for English/Spanish documentation pairs."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlsplit


DOCUMENT_PAIRS = (
    ("README.md", "README.es.md"),
    ("ARCHITECTURE.md", "ARCHITECTURE.es.md"),
    ("docs/PROJECT-STRUCTURE.md", "docs/PROJECT-STRUCTURE.es.md"),
    ("docs/KNOWN-LIMITATIONS.md", "docs/KNOWN-LIMITATIONS.es.md"),
)
MARKDOWN_LINK = re.compile(r"!?\[[^\]]*]\(([^)]+)\)")
HTML_LINK = re.compile(r"(?:href|src|srcset)=[\"']([^\"']+)[\"']", re.IGNORECASE)
HEADING = re.compile(r"^(#{1,6})\s+", re.MULTILINE)
FENCE = re.compile(r"^(```|~~~)([^\n]*)$", re.MULTILINE)
IGNORED_SCHEMES = {"app", "data", "http", "https", "mailto"}


def extract_target(raw_target: str) -> str:
    target = raw_target.strip()
    if target.startswith("<") and ">" in target:
        return target[1 : target.index(">")]
    return target.split(maxsplit=1)[0]


def normalized_local_links(markdown: str) -> list[str]:
    links: list[str] = []
    raw_targets = MARKDOWN_LINK.findall(markdown)
    raw_targets.extend(HTML_LINK.findall(markdown))
    for raw_target in raw_targets:
        target = extract_target(raw_target)
        parsed = urlsplit(target)
        if not target or target.startswith("#") or parsed.scheme.lower() in IGNORED_SCHEMES:
            continue
        path = unquote(parsed.path).replace(".es.md", ".md")
        links.append(path)
    return sorted(links)


def fence_languages(markdown: str) -> list[str]:
    languages: list[str] = []
    active_marker = ""
    for marker, metadata in FENCE.findall(markdown):
        if not active_marker:
            active_marker = marker
            languages.append(metadata.strip())
        elif marker == active_marker:
            active_marker = ""
    return languages


def validate_pair(english: str, spanish: str, label: str) -> list[str]:
    errors: list[str] = []
    english_headings = [len(marker) for marker in HEADING.findall(english)]
    spanish_headings = [len(marker) for marker in HEADING.findall(spanish)]

    if english_headings != spanish_headings:
        errors.append(f"{label}: heading hierarchy differs")
    if fence_languages(english) != fence_languages(spanish):
        errors.append(f"{label}: code-block structure differs")
    if normalized_local_links(english) != normalized_local_links(spanish):
        errors.append(f"{label}: repository-local link targets differ")
    return errors


def validate_pairs(repository_root: Path) -> list[str]:
    errors: list[str] = []
    for english_path, spanish_path in DOCUMENT_PAIRS:
        english_file = repository_root / english_path
        spanish_file = repository_root / spanish_path
        if not english_file.is_file() or not spanish_file.is_file():
            errors.append(f"{english_path} ↔ {spanish_path}: one side is missing")
            continue
        errors.extend(
            validate_pair(
                english_file.read_text(encoding="utf-8"),
                spanish_file.read_text(encoding="utf-8"),
                f"{english_path} ↔ {spanish_path}",
            )
        )
    return errors


def main() -> int:
    repository_root = Path(__file__).resolve().parent.parent
    errors = validate_pairs(repository_root)
    if errors:
        print("English/Spanish documentation parity failed:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    print(f"Validated structural and technical parity for {len(DOCUMENT_PAIRS)} English/Spanish pairs.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
