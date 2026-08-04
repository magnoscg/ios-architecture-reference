# ADR-0003: Compose concrete dependencies at one edge

- **Status:** Superseded for v2 by [ADR-0005](0005-hierarchical-composition-roots.md)
- **Date:** 2026-08-04
- **Applies to:** tag [`1.0.0`](https://github.com/magnoscg/ios-architecture-reference/tree/1.0.0) only

## Context

Constructing concrete clients inside feature logic hides configuration, couples tests to implementation details, and encourages mutable global state.

## Decision

The v1 package creates its demo and live object graphs in one `ArchitectureComposition` target.

## Consequences in v1

- Feature code remains independent from environment configuration.
- Previews and tests can use deterministic dependencies.
- One small composition edge is sufficient for the package's single slice.

## Why v2 supersedes it

The real application has app-, scene-, and screen-lifetime objects. Version 2 therefore composes shared services at `ArquitecturaApp`/`AppDependencies` and individual graphs in feature factories. Concrete construction remains explicit, but it is intentionally hierarchical rather than centralized in one file.

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Last Updated / Verified | 2026-08-04 |
| Status | Historical, superseded for v2 |
| Review Schedule | Immutable historical record |
| Labels | `adr`, `v1`, `composition-root`, `dependency-injection` |
