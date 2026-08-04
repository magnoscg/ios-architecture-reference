#!/usr/bin/env python3
"""Validate repository-local links in Markdown files."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlsplit


MARKDOWN_LINK = re.compile(r"!?\[[^\]]*]\(([^)]+)\)")
HTML_LINK = re.compile(r"(?:href|src|srcset)=[\"']([^\"']+)[\"']", re.IGNORECASE)
IGNORED_SCHEMES = {"app", "data", "http", "https", "mailto"}


def markdown_without_fenced_code(markdown: str) -> str:
    lines: list[str] = []
    in_fence = False
    fence_character = ""

    for line in markdown.splitlines():
        stripped = line.lstrip()
        if stripped.startswith(("```", "~~~")):
            character = stripped[0]
            if not in_fence:
                in_fence = True
                fence_character = character
            elif character == fence_character:
                in_fence = False
            continue
        if not in_fence:
            lines.append(line)

    return "\n".join(lines)


def extract_target(raw_target: str) -> str:
    target = raw_target.strip()
    if target.startswith("<") and ">" in target:
        return target[1 : target.index(">")]
    return target.split(maxsplit=1)[0]


def local_targets(markdown: str) -> list[str]:
    visible_markdown = markdown_without_fenced_code(markdown)
    raw_targets = MARKDOWN_LINK.findall(visible_markdown)
    raw_targets.extend(HTML_LINK.findall(visible_markdown))

    targets: list[str] = []
    for raw_target in raw_targets:
        target = extract_target(raw_target)
        parsed = urlsplit(target)
        if not target or target.startswith("#") or parsed.scheme.lower() in IGNORED_SCHEMES:
            continue
        targets.append(unquote(parsed.path))
    return targets


def markdown_files(repository_root: Path) -> list[Path]:
    files = list(repository_root.glob("*.md"))
    docs = repository_root / "docs"
    if docs.exists():
        files.extend(docs.rglob("*.md"))
    return sorted(set(files))


def validate_links(repository_root: Path) -> list[str]:
    errors: list[str] = []
    resolved_root = repository_root.resolve()

    for markdown_file in markdown_files(repository_root):
        markdown = markdown_file.read_text(encoding="utf-8")
        for target in local_targets(markdown):
            candidate = resolved_root / target.lstrip("/") if target.startswith("/") else markdown_file.parent / target
            resolved_candidate = candidate.resolve()
            try:
                resolved_candidate.relative_to(resolved_root)
            except ValueError:
                errors.append(f"{markdown_file.relative_to(repository_root)}: link leaves repository: {target}")
                continue
            if not resolved_candidate.exists():
                errors.append(f"{markdown_file.relative_to(repository_root)}: missing link target: {target}")

    return errors


def main() -> int:
    repository_root = Path(__file__).resolve().parent.parent
    errors = validate_links(repository_root)
    if errors:
        print("Invalid local Markdown links:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        return 1

    print("Validated repository-local Markdown links.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
