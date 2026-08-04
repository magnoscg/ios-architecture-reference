# Changelog

All notable changes to this project are documented here. The repository uses semantic version tags without a `v` prefix.

## Unreleased

No unreleased changes.

## [2.0.0] - 2026-08-04

### Breaking

- Replaced the four-product Swift Package with the real `Arquitectura.xcodeproj` reference application.
- Removed the current-tree `ArchitectureDomain`, `ArchitectureData`, `ArchitectureFeature`, and `ArchitectureComposition` products. Existing package consumers must stay pinned to [`1.0.0`](https://github.com/magnoscg/ios-architecture-reference/tree/1.0.0).

### Added

- Single-app-target SwiftUI reference organized by logical layers and features.
- Hierarchical app, scene, and screen composition roots using manual factories.
- Typed feature routes, one app router, deep-link handling, and route-state serialization.
- Local architecture catalogue plus live PokeAPI list/detail flows.
- URLSession API client, endpoint types, interceptor chain, environment configuration, SSL-pinning infrastructure, privacy manifest, and design tokens.
- Simulator-based Swift Testing coverage; the imported snapshot verifies 194 cases across 27 suites.
- Bilingual README, architecture, structure, and limitation documentation with current ADRs and preserved v1 history.
- Reproducible source provenance, public allowlist, third-party notices, asset provenance, and accessible presentation assets.

### Changed

- Corrected the architecture catalogue to 19 implemented entries backed by real source paths.
- Removed unsupported SwiftData/background-executor claims and fabricated example paths/snippets.
- Replaced an undocumented Pokéball asset with the system `globe` symbol.
- Raised secondary/status colour contrast and regenerated the authentic light/dark simulator evidence.
- Made SwiftFormat verification non-mutating; `make format` is now the explicit rewriting command.
- Updated CI to build and test the shared Development scheme on a dynamically selected iPhone simulator without code signing.

### Documented limitations

- Folder boundaries are not compile-time modules.
- Development is the only validated environment; Staging and Production remain illustrative templates.
- The test plan contains no UI-test coverage and the app has no domain persistence layer.

## [1.0.0] - 2026-08-04

### Added

- Buildable Swift 6 reference split into Domain, Data, Feature, and Composition package targets.
- Clean Architecture dependency boundaries, MVVM state ownership, and typed Router navigation.
- Remote and deterministic demo repositories with HTTPS endpoint validation.
- Fifteen Swift Testing checks across domain, mapping, networking, and UI state.
- Bilingual recruiter narrative, architecture decision records, security documentation, and first-party OgamLabs presentation assets.

[2.0.0]: https://github.com/magnoscg/ios-architecture-reference/releases/tag/2.0.0
[1.0.0]: https://github.com/magnoscg/ios-architecture-reference/tree/1.0.0

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Last Updated / Verified | 2026-08-04 |
| Review Schedule | Every release |
| Labels | `changelog`, `release`, `semver` |
