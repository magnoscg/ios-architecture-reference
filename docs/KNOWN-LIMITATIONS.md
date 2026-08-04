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

### Repository contracts live in Data

Domain Use Cases depend on Repository protocols that are physically declared under `Data/<Feature>/Repositories`.

**Consequence:** the source tree does not express the strict dependency-inversion placement normally expected from Clean Architecture.

**Follow-up question:** move contracts into Domain and leave only implementations in Data if the team chooses strict inward ownership.

### Error mapping crosses outward

`DomainError+Mapping.swift` knows `APIError` from Core networking. `ErrorDecorator` is stored under Core even though it represents user-facing presentation state.

**Consequence:** Domain is not framework/transport-independent, and Core contains a presentation concern.

**Follow-up question:** perform transport-to-domain mapping at the Data boundary and move UI error decoration into Features or a focused presentation-support zone.

## Composition and navigation limitations

### Cross-feature route knowledge

`ArchitectureDetailRouterImpl` directly pushes `PokemonListRoute.list` to demonstrate moving from an architecture entry into the PokeAPI example.

**Consequence:** one feature's navigation implementation knows another feature's concrete route type.

**Follow-up question:** move cross-feature intent to an app-level route/coordinator contract if independent feature ownership becomes important.

### One app router with multiwindow enabled

`ArquitecturaApp` owns one `AppRouterImpl`, while the Info.plist permits multiple scenes. `RootNavigationView` creates a scene-scoped coordinator and persists a path with `@SceneStorage`.

**Consequence:** the sample has not established independent router ownership for multiple active windows. It also has not exhaustively validated ordering between cold-launch restoration and incoming deep links.

**Follow-up question:** make navigation ownership explicitly scene-scoped and add cold-launch/multiwindow scenarios before adopting this shape in a multiwindow product.

### Heterogeneous `NavigationPath`

Feature routes share one type-erased `NavigationPath`. Route values are Codable, but restoration depends on every stored route remaining decodable across versions.

**Consequence:** route renames or payload changes require a compatibility strategy; none is implemented in this reference.

## Data and concurrency limitations

### MainActor is the default isolation

The app target uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. Async function boundaries and folder placement do not automatically move work away from the main actor.

**Consequence:** documentation must not claim that Domain or Data always executes in the background.

### Bundled JSON is decoded synchronously

`ArchitectureDetailJSONDataSourceImpl` reads and decodes the bundled catalogue during feature-graph construction and caches it for that graph.

**Consequence:** the current small file is acceptable for a reference, but the pattern would put larger file I/O and decoding on the caller's isolation context.

**Follow-up question:** introduce an explicitly isolated async loader only if data size or measured launch/navigation work warrants it.

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

**Consequence:** 194 Swift Testing cases are unit/integration-style evidence, not proof of end-to-end UI behavior, accessibility, or screenshot stability.

### External runtime dependency

The Pokémon flow depends on the availability and shape of PokeAPI and its referenced media. The repository does not control that service.

**Consequence:** live screens can fail or change independently of this source snapshot. No third-party Pokémon artwork is embedded in the repository.

### Security code is illustrative

The sample contains SSL-pinning infrastructure, interceptors, Keychain helpers, and a privacy manifest, but no real product authentication, certificate rotation, telemetry, or incident process.

**Consequence:** these files are reviewable implementation examples, not a production security certification.

## Structural review backlog

The separate follow-up task should evaluate, in this order:

1. actor/isolation boundaries and synchronous JSON work;
2. scene-owned navigation, deep-link ordering, and route restoration compatibility;
3. effective xcconfig values and the empty UI-test target;
4. Repository contract placement and transport-to-domain error mapping;
5. cross-feature navigation ownership and duplicate catalogue sources;
6. module boundaries only if measurable ownership or build constraints justify them.

No item above authorizes a refactor by itself. Each change should have tests, migration impact, and an ADR when it alters an architectural contract.

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Created | 2026-08-04 |
| Last Updated | 2026-08-04 |
| Last Verified | 2026-08-04 |
| Status | Accepted limitations for v2 publication |
| Review Schedule | Quarterly and before structural refactors |
| Labels | `ios`, `architecture`, `technical-debt`, `limitations` |
