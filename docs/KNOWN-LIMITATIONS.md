# Known Limitations

**[Español](KNOWN-LIMITATIONS.es.md)** · **[Architecture](../ARCHITECTURE.md)** · **[Project structure](PROJECT-STRUCTURE.md)**

## Why this page exists

This repository is evidence of a real architecture, including its compromises. The items below separate what the sample demonstrates today from what a stricter or production-specific architecture could require.

They are not disguised as roadmap features, and their presence does not mean every item must be “fixed.” Any structural change should first prove that its additional boundary or abstraction protects a real product need.

## Boundary and dependency limitations

### One application target

All production source is compiled into `Arquitectura`. `App`, `Core`, `Domain`, `Data`, and `Features` are logical folders, so an invalid cross-layer reference does not fail merely because of target dependencies.

**Consequence:** architecture review, tests, and linting carry responsibility that separate modules could enforce at compile time.

**Follow-up question:** modularize only after build ownership, reuse, or team boundaries justify the cost. See [ADR-0004](decisions/0004-single-app-target-logical-boundaries.md).

### Presentation error type lives in Core

Repository protocols live in Domain and transport-to-domain mapping happens in Data ([`DomainError+Mapping.swift`](../Arquitectura/Data/Common/DomainError+Mapping.swift)), so Domain no longer knows `APIError`. `ErrorDecorator`, however, is stored under Core even though it represents user-facing presentation state, because every feature shares it.

**Consequence:** Core contains a presentation concern.

**Follow-up question:** move UI error decoration into a focused presentation-support zone if Core is ever extracted into its own module.

## Composition and navigation limitations

### Cross-feature route knowledge

`ArchitectureDetailRouterImpl` directly pushes `PokemonListRoute.list` to demonstrate moving from an architecture entry into the PokeAPI example.

**Consequence:** one feature's navigation implementation knows another feature's concrete route type.

**Follow-up question:** move cross-feature intent to an app-level route/coordinator contract if independent feature ownership becomes important.

### Multiwindow and cold-launch navigation are unit-tested only

Each window's `AppRootView` owns its `AppRouterImpl` and `AppNavigationCoordinator`, and the coordinator holds a deep link received before restoration until the saved path has been restored. Unit tests cover those ordering cases on the coordinator.

**Consequence:** no UI test exercises several active windows or a cold launch from a deep link on a simulator.

**Follow-up question:** add those scenarios once a UI-test suite exists.

### Heterogeneous `NavigationPath`

Feature routes share one type-erased `NavigationPath`. Route values are Codable, but restoration depends on every stored route remaining decodable across versions.

**Consequence:** route renames or payload changes require a compatibility strategy; none is implemented in this reference.

## Data and concurrency limitations

### MainActor is the default isolation

The app target uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. Async function boundaries and folder placement do not automatically move work away from the main actor.

**Consequence:** documentation must not claim that Domain or Data always executes in the background.

### Bundled JSON is decoded on every request

`ArchitectureDetailJSONDataSourceImpl` does no I/O when it is created and decodes the bundled catalogue in a `@concurrent` function, off the main actor, each time a detail is requested. It keeps no cache.

**Consequence:** every detail screen reads and decodes the whole file. That is negligible for 19 entries but would grow with the catalogue.

**Follow-up question:** cache decoded DTOs in an explicitly isolated store only if measurements show the cost matters.

### Duplicate catalogue paths

The architecture list uses a static Data Source, detail uses bundled JSON, and an `ArchitectureRemoteDataSource` remains disconnected from the production graph.

**Consequence:** catalogue facts can drift across representations, and the unused remote path adds noise.

**Follow-up question:** choose one authoritative catalogue representation and remove the unused path during the structural review.

### No domain persistence or offline cache

PokeAPI responses are fetched at runtime and are not stored. `@SceneStorage` preserves navigation data only; it is not a domain persistence layer.

**Consequence:** the PokeAPI flow does not provide offline content and can show network errors when the service is unavailable.

## Delivery and verification limitations

### Only Development is validated

Staging and Production xcconfig files and schemes are illustrative. Their endpoints are placeholders, Production keeps a placeholder certificate hash, and target build settings override some bundle/product values declared in xcconfig.

**Consequence:** the configuration demonstrates the mechanism but is not a set of distribution-ready environments. A release guard intentionally blocks a Production release with the placeholder hash.

### No UI-test coverage

The project contains a nominal `ArquitecturaUITests` target, but no UI-test source directory is checked in and the shared test plan executes only `ArquitecturaTests`.

**Consequence:** 253 Swift Testing cases are unit/integration-style evidence, not proof of end-to-end UI behavior, accessibility, or screenshot stability.

### External runtime dependency

The Pokémon flow depends on the availability and shape of PokeAPI and its referenced media. The repository does not control that service.

**Consequence:** live screens can fail or change independently of this source snapshot. No third-party Pokémon artwork is embedded in the repository.

### Security code is illustrative

The sample contains SSL-pinning infrastructure, interceptors, Keychain helpers, and a privacy manifest, but no real product authentication, certificate rotation, telemetry, or incident process.

**Consequence:** these files are reviewable implementation examples, not a production security certification.

## Structural review backlog

The 2026-11-03 snapshot resolved the earlier items on Repository contract placement, transport-to-domain error mapping, scene-owned navigation with ordered deep links, and synchronous JSON work; see the [changelog](../CHANGELOG.md). The separate follow-up task should evaluate, in this order:

1. effective xcconfig values and the empty UI-test target;
2. route restoration compatibility and UI coverage for multiwindow and cold-launch deep links;
3. cross-feature navigation ownership and duplicate catalogue sources;
4. the presentation error type in Core;
5. module boundaries only if measurable ownership or build constraints justify them.

No item above authorizes a refactor by itself. Each change should have tests, migration impact, and an ADR when it alters an architectural contract.

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Created | 2026-08-04 |
| Last Updated | 2026-11-03 |
| Last Verified | 2026-11-03 |
| Status | Accepted limitations for v2 publication |
| Review Schedule | Quarterly and before structural refactors |
| Labels | `ios`, `architecture`, `technical-debt`, `limitations` |
