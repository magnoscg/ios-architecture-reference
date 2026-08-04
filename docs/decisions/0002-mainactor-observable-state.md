# ADR-0002: Isolate observable presentation state on MainActor

- **Status:** Historical — accepted for v1 only
- **Date:** 2026-08-04
- **Applies to:** tag [`1.0.0`](https://github.com/magnoscg/ios-architecture-reference/tree/1.0.0) only

## Context

SwiftUI reads observable state synchronously. Moving a ViewModel to a custom actor would force asynchronous property access and work against the rendering model.

## Decision

The v1 package keeps the ViewModel and Router on `@MainActor`. Actor-isolated remote services return immutable `Sendable` values through async protocols.

## Consequences in v1

- UI mutation has one explicit owner.
- Presentation tests declare `@MainActor`.
- CPU-heavy work requires a separate concurrent service rather than running in the ViewModel.

## v2 status

The presentation principle continues, but the implementation is materially different: the Xcode target uses MainActor as its default isolation, and its API client is an immutable `@unchecked Sendable` class rather than the v1 actor graph. Current concurrency behavior is documented in [Architecture](../../ARCHITECTURE.md#swift-concurrency-model); this record must not be used as evidence for v2 service isolation.

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Last Updated / Verified | 2026-08-04 |
| Status | Historical v1 decision |
| Review Schedule | Immutable historical record |
| Labels | `adr`, `v1`, `mainactor`, `observation` |
