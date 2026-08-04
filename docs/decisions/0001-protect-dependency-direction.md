# ADR-0001: Protect dependency direction with Swift Package targets

- **Status:** Superseded for v2 by [ADR-0004](0004-single-app-target-logical-boundaries.md)
- **Date:** 2026-08-04
- **Applies to:** tag [`1.0.0`](https://github.com/magnoscg/ios-architecture-reference/tree/1.0.0) only

## Context

The v1 reference was a small Swift Package. Folders alone would not stop a data type from importing UI code or a ViewModel from constructing a concrete network client.

## Decision

The v1 package uses separate Domain, Data, Feature, and Composition targets. Domain owns the repository abstraction; Data implements it; Feature consumes the Domain Use Case; Composition selects concrete implementations.

## Consequences in v1

- Invalid imports fail at compile time.
- Tests target boundaries independently.
- Public target wiring adds ceremony but makes the dependency graph explicit.

## Why v2 supersedes it

Version 2 publishes a real Xcode application rather than adapting that application to the smaller package design. It uses one application target with logical folders, so this compile-time guarantee no longer applies. The v1 decision remains valid for consumers pinned to `1.0.0`.

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Last Updated / Verified | 2026-08-04 |
| Status | Historical, superseded for v2 |
| Review Schedule | Immutable historical record |
| Labels | `adr`, `v1`, `spm`, `dependency-direction` |
