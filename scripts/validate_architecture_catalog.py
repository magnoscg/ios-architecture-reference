#!/usr/bin/env python3
"""Validate that the public in-app architecture catalogue cites real evidence."""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path


EXPECTED_ENTRY_COUNT = 19
FORBIDDEN_LEGACY_IDS = {"swiftdata", "background-executor"}
EVIDENCE_ROOTS = (
    "Arquitectura",
    "ArquitecturaTests",
    "Arquitectura.xcodeproj",
)


@dataclass(frozen=True)
class CatalogueSummary:
    identifier: str
    name: str
    category: str
    is_implemented: bool


def fail(message: str) -> None:
    raise ValueError(message)


def load_detail_catalog(path: Path) -> tuple[list[CatalogueSummary], list[str]]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        fail(f"cannot read architecture detail catalogue: {error}")

    features = payload.get("features") if isinstance(payload, dict) else None
    if not isinstance(features, list):
        fail("architecture_details.json must contain a features array")

    summaries: list[CatalogueSummary] = []
    evidence_references: list[str] = []
    for index, feature in enumerate(features):
        if not isinstance(feature, dict):
            fail(f"catalogue entry {index} must be an object")

        try:
            summary = CatalogueSummary(
                identifier=feature["id"],
                name=feature["name"],
                category=feature["category"],
                is_implemented=feature["isImplemented"],
            )
        except KeyError as error:
            fail(f"catalogue entry {index} is missing {error.args[0]}")

        if not all(isinstance(value, str) and value for value in (
            summary.identifier,
            summary.name,
            summary.category,
        )):
            fail(f"catalogue entry {index} has an invalid id, name, or category")
        if not isinstance(summary.is_implemented, bool):
            fail(f"catalogue entry {summary.identifier} has a non-boolean isImplemented")

        files = feature.get("filesInvolved")
        if not isinstance(files, list) or not files:
            fail(f"catalogue entry {summary.identifier} must cite at least one source path")
        for file_entry in files:
            if not isinstance(file_entry, dict) or not isinstance(file_entry.get("name"), str):
                fail(f"catalogue entry {summary.identifier} has an invalid filesInvolved item")
            evidence_references.append(file_entry["name"])

        summaries.append(summary)

    return summaries, evidence_references


def load_swift_catalog(path: Path, constructor: str) -> list[CatalogueSummary]:
    try:
        source = path.read_text(encoding="utf-8")
    except OSError as error:
        fail(f"cannot read {path}: {error}")

    pattern = re.compile(
        rf'{re.escape(constructor)}\(id:\s*"(?P<id>[^"]+)",\s*'
        r'name:\s*"(?P<name>[^"]+)",\s*'
        r'description:\s*"[^"]+",\s*'
        r'category:\s*(?:\.(?P<dot_category>\w+)|"(?P<string_category>[^"]+)"),\s*'
        r'isImplemented:\s*(?P<implemented>true|false)',
        re.MULTILINE,
    )

    summaries = []
    for match in pattern.finditer(source):
        summaries.append(CatalogueSummary(
            identifier=match.group("id"),
            name=match.group("name"),
            category=match.group("dot_category") or match.group("string_category"),
            is_implemented=match.group("implemented") == "true",
        ))

    if not summaries:
        fail(f"no {constructor} catalogue entries were parsed from {path}")
    return summaries


def evidence_matches(repository_root: Path, reference: str) -> list[Path]:
    reference_path = Path(reference)
    if reference_path.is_absolute() or ".." in reference_path.parts:
        fail(f"unsafe catalogue evidence reference: {reference}")

    matches: list[Path] = []
    for root_name in EVIDENCE_ROOTS:
        evidence_root = repository_root / root_name
        if not evidence_root.exists():
            continue
        for candidate in evidence_root.rglob("*"):
            if reference_path.parent == Path("."):
                is_match = candidate.name == reference
            else:
                try:
                    relative_candidate = candidate.relative_to(repository_root).as_posix()
                except ValueError:
                    continue
                is_match = (
                    relative_candidate == reference_path.as_posix()
                    or relative_candidate.endswith(f"/{reference_path.as_posix()}")
                )
            if is_match:
                matches.append(candidate)
    return matches


def validate_detail_summaries(details: list[CatalogueSummary]) -> None:
    if len(details) != EXPECTED_ENTRY_COUNT:
        fail(f"expected {EXPECTED_ENTRY_COUNT} detail entries, found {len(details)}")

    identifiers = [entry.identifier for entry in details]
    if len(set(identifiers)) != len(identifiers):
        fail("architecture detail catalogue contains duplicate IDs")
    if FORBIDDEN_LEGACY_IDS.intersection(identifiers):
        fail("architecture detail catalogue contains a removed roadmap-only ID")
    if not all(entry.is_implemented for entry in details):
        fail("the current architecture catalogue may contain only implemented entries")


def validate(repository_root: Path) -> None:
    detail_path = repository_root / "Arquitectura/Resources/Data/architecture_details.json"
    static_path = repository_root / (
        "Arquitectura/Data/Architecture/DataSources/ArchitectureStaticDataSourceImpl.swift"
    )
    remote_path = repository_root / (
        "Arquitectura/Data/Architecture/DataSources/ArchitectureRemoteDataSourceImpl.swift"
    )

    details, evidence_references = load_detail_catalog(detail_path)
    static = load_swift_catalog(static_path, "ArchitectureModel")
    remote = load_swift_catalog(remote_path, "ArchitectureDTO")

    validate_detail_summaries(details)

    if details != static:
        fail("bundled detail catalogue and ArchitectureStaticDataSourceImpl are out of sync")
    if static != remote:
        fail("static and alternate remote architecture catalogues are out of sync")

    for reference in evidence_references:
        if not evidence_matches(repository_root, reference):
            fail(f"catalogue evidence does not resolve to a real path: {reference}")

    raw_details = detail_path.read_text(encoding="utf-8")
    if "Article" in raw_details:
        fail("architecture detail catalogue contains a removed Article placeholder")


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parent.parent,
        help="repository root (defaults to the parent of scripts)",
    )
    return parser.parse_args()


def main() -> int:
    try:
        validate(parse_arguments().root.resolve())
    except ValueError as error:
        print(f"Architecture catalogue validation failed: {error}", file=sys.stderr)
        return 1

    print(
        "Validated 19 implemented architecture entries, mirrored catalogue metadata, "
        "and every referenced file or directory."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
