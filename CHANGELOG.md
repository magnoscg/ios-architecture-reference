# Changelog

All notable changes to this project are documented here. The repository uses semantic version tags without a `v` prefix.

## Unreleased

### Changed

- Re-imported the reference app from source commit `c046aee55f3fd25ff8508014660a06fe44b0fb41`, then applied the networking changes from `51c05fe810f8d842d25e93701c456501bdac4066`; see [Source provenance](docs/SOURCE-PROVENANCE.md).
- Moved Repository protocols to `Domain/<Concept>/Repositories`; `Data` now holds only their implementations.
- Moved `APIError` → `DomainError` mapping to `Data/Common`. Repositories wrap their work in `DomainError.catching`, which keeps cancellation as `CancellationError`, and Use Cases no longer map errors.
- Organized `Domain` and `Data` by concept: the Pokémon list and detail screens share `Domain/Pokemon` and `Data/Pokemon`, and the list model is now `PokemonSummaryModel`.
- Gave each window its own `AppRouterImpl` and `AppNavigationCoordinator` through a new `AppRootView`. The `AppRouter` protocol now offers only `push`, `pop`, and `popToRoot`.
- Made deep links replace the stack, and held a link received before restoration until the saved path is restored. A failed encoding no longer overwrites the saved path.
- Made the bundled JSON Data Source do no I/O in its initializer and decode in a `@concurrent` function; a missing or invalid file is now an error instead of an empty catalogue.
- Updated the catalogue entries, READMEs, architecture, structure, and limitation documents, and amended ADR-0004, ADR-0005, and ADR-0006 to match.

### Fixed

- `APIClientImpl` turns `URLError.cancelled` into `CancellationError` only when the task was cancelled, so a rejected pinning challenge stays a network error, and the retry backoff rethrows its `CancellationError`.
- `RetryInterceptor` checks cancellation before retrying and only resends idempotent methods or requests with a non-empty `Idempotency-Key`.
- The Pokémon list fails when every detail request fails instead of showing an empty page.
- SSL pinning compares the SHA-256 of the certificate's SubjectPublicKeyInfo, the value the `openssl` command in `Production.xcconfig` computes; it used to hash the raw key, so a correct pin never matched. Any certificate in the chain can match, only the API host is pinned, and missing or malformed pins reject API connections.
- `APIClientImpl` invalidates only a `URLSession` it created.
- `RetryInterceptor` no longer retries errors that describe the device state, honors `Retry-After` up to `maxDelay`, and stops once `RetryPolicy.maxElapsedTime` is spent. The session waits for connectivity and no longer blocks Low Data Mode.

### Added

- Tests for the retry interceptor, Data-side error mapping, `ErrorDecorator` mapping, the detail repository, the list Use Case, and deep-link launch ordering, session ownership, SSL pinning and `URLSessionFactory`: 253 Swift Testing cases across 33 suites.

## [2.0.1] - 2026-10-31

### Changed

- Rewrote the English and Spanish READMEs as a visual architecture overview: highlights, layer, request and composition diagrams, real code excerpts, design trade-offs, project history and author links.
- Pointed the architecture documents at the new README diagram sections.
- Adapted five Swift files to the SwiftFormat 0.64.3 and SwiftLint 0.65.1 rules now used by CI (`redundantReturn`, `repeatedGuard`, `legacy_swiftui_aspect_ratio`). Behaviour and rendering are unchanged.

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

[2.0.1]: https://github.com/magnoscg/ios-architecture-reference/releases/tag/2.0.1
[2.0.0]: https://github.com/magnoscg/ios-architecture-reference/releases/tag/2.0.0
[1.0.0]: https://github.com/magnoscg/ios-architecture-reference/tree/1.0.0

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Last Updated / Verified | 2026-10-31 |
| Review Schedule | Every release |
| Labels | `changelog`, `release`, `semver` |
