# Architecture

**[Español](ARCHITECTURE.es.md)** · **[README](README.md)** · **[Project structure](docs/PROJECT-STRUCTURE.md)** · **[Known limitations](docs/KNOWN-LIMITATIONS.md)**

## Purpose and exact classification

This repository is a real SwiftUI reference application. Its architecture is best described as:

> A single-application-target, layered and feature-oriented architecture inspired by Clean Architecture, using MVVM, typed feature routers, and manual hierarchical factory-based dependency injection.

The wording is deliberate. `Domain`, `Data`, `Features`, `Core`, and `App` are source folders in one application target, not independently compiled modules. The organization improves discoverability and reviewability, but Xcode does not enforce the dependency direction.

The target is an educational reference, not a claim that every iOS product needs this amount of structure. It shows concrete trade-offs and leaves known deviations visible.

## Architecture profile

| Concern | Actual implementation |
| --- | --- |
| UI | SwiftUI, iOS 18+ |
| Presentation | `@Observable` ViewModels with explicit state enums |
| Domain operations | Protocol-backed Use Cases and value models |
| Data access | Static data, bundled JSON, and remote PokeAPI Data Sources |
| Navigation | `NavigationStack`, one `NavigationPath`, Codable feature route enums |
| Dependency injection | Constructor injection assembled by app and feature factories |
| Concurrency | Swift 6 language mode, default MainActor isolation, async/await, task groups |
| Networking | URLSession through a shared `APIClient`, endpoint values, and interceptors |
| Persistence | No domain database; route data only uses `@SceneStorage` |
| Dependencies | Apple frameworks only; no third-party Swift packages |

The two presentation diagrams and their text fallbacks live in the README:

- [Composition and lifetimes](README.md#composition-and-lifetimes)
- [Runtime flow](README.md#runtime-flow)

## Hierarchical composition root

Composition is split by lifetime instead of forced into one oversized container.

| Owner | Constructs | Lifetime |
| --- | --- | --- |
| [`ArquitecturaApp`](Arquitectura/ArquitecturaApp.swift) | `AppDependencies`, `AppRouterImpl`, splash and root view | Application |
| [`AppDependencies`](Arquitectura/App/Config/AppDependencies.swift) | Environment configuration and `APIClientImpl` | Application |
| [`RootNavigationView`](Arquitectura/App/Navigation/RootNavigationView.swift) | `AppNavigationCoordinator` and route resolvers | Scene/root view |
| Feature factories | Data Source, mapper, Repository, Use Case, Router, ViewModel, View | Screen/navigation destination |

[`PokemonListFactory`](Arquitectura/Features/PokemonList/DI/PokemonListFactory.swift) is the clearest complete example. It receives the shared API client and app router, creates the feature-specific collaborators, and injects the resulting ViewModel into the View. No service locator or DI framework is involved.

The architecture catalogue does not need networking, so [`ArchitectureFactory`](Arquitectura/Features/Architecture/DI/ArchitectureFactory.swift) builds a graph backed by static data. The splash factory creates only its ViewModel and View. Factories remain proportional to the feature they assemble.

See [ADR-0005](docs/decisions/0005-hierarchical-composition-roots.md) for the decision and alternatives.

## Logical layers and dependency direction

The intended collaboration direction is:

```text
App / Feature UI
        ↓
Presentation (ViewModel + presentation mapper + feature Router)
        ↓
Domain (Use Case + domain model)
        ↓
Data contract and implementation (Repository + mapper + Data Source)
        ↓
Core infrastructure (APIClient / URLSession) or bundled data
```

Responsibilities in the current tree:

- **App** owns startup, shared configuration, navigation state, deep-link coordination, and application-lifetime dependencies.
- **Features** owns SwiftUI Views, explicit UI state, ViewModels, presentation decorators/mappers, typed feature routes, and factories.
- **Domain** owns feature models and Use Case protocols/implementations.
- **Data** owns repository protocols and implementations, DTOs, DTO mappers, and Data Sources.
- **Core** owns networking, security helpers, shared SwiftUI components, error presentation, and design tokens.

This is Clean Architecture-inspired rather than strict Clean Architecture. Repository protocols are currently physically located in `Data`; `DomainError.map` knows the networking `APIError`; and `ErrorDecorator` sits in `Core` despite being presentation-facing. These are documented debts, not hidden claims. See [Known limitations](docs/KNOWN-LIMITATIONS.md).

## Complete runtime paths

### Local architecture catalogue

```text
ArchitectureView
→ ArchitectureViewModel
→ ArchitectureUseCaseImpl
→ ArchitectureRepositoryImpl
→ ArchitectureStaticDataSourceImpl
```

Selecting an entry pushes an `ArchitectureRoute.detail`. The destination factory builds a second graph that reads `architecture_details.json` once during Data Source initialization and caches the decoded DTOs for that screen graph.

The catalogue is documentation embedded in the app. Its 19 current entries are backed by implementation in this repository; unsupported SwiftData and background-executor claims were removed from the published snapshot.

### PokeAPI list and detail

```text
PokemonListView
→ PokemonListViewModel
→ PokemonListUseCaseImpl
→ PokemonListRepositoryImpl
→ PokemonListRemoteDataSourceImpl
→ APIClientImpl
→ PokeAPIEndpoint
```

The list Repository uses a throwing task group to fetch item details concurrently and sorts successful results by ID. Individual non-cancellation detail failures are logged and omitted; cancellation propagates. The detail Repository loads detail and species concurrently, treating species metadata as optional while keeping the primary detail required.

No PokeAPI response is persisted locally. See [Third-party notices](THIRD_PARTY_NOTICES.md) for attribution and scope.

## State, errors, and cancellation

Each screen ViewModel owns an explicit state enum such as `idle`, `loading`, `loaded`, and `error`. SwiftUI Views render that state and send user intents back to the ViewModel; they do not construct repositories or mutate the app path directly.

ViewModels guard duplicate loads. On `CancellationError`, they restore the previous state instead of leaving a loading screen stuck. List pagination tracks its loading and retryable error separately from the already loaded content.

The implemented error path is:

```text
APIError
→ DomainError.map(...) inside a Use Case
→ ErrorDecorator.from(...) inside a ViewModel
→ localized SwiftUI error state
```

This prevents raw server payloads from becoming user-facing copy. It also creates a known outward dependency from Domain error mapping to networking, which is recorded for later structural review.

## Typed navigation and restoration

[`AppRouterImpl`](Arquitectura/App/Navigation/AppRouterImpl.swift) owns one observable `NavigationPath`. Each flow defines Codable, Hashable route values and a small feature Router protocol. ViewModels express intent through those protocols; implementations delegate to the app router.

[`RootNavigationView`](Arquitectura/App/Navigation/RootNavigationView.swift) installs feature-specific `navigationDestination` resolvers. [`AppNavigationCoordinator`](Arquitectura/App/Navigation/AppNavigationCoordinator.swift) parses the `arquitectura://` deep-link scheme and encodes the path into `@SceneStorage` after a debounce.

This keeps route construction out of Views while allowing heterogeneous destinations in one stack. It does not yet prove robust multiwindow ownership or every cold-launch deep-link ordering scenario. See [ADR-0006](docs/decisions/0006-typed-feature-routing.md).

## Swift concurrency model

The project uses Swift 6 language mode and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` for the app and test targets.

- SwiftUI Views, ViewModels, routers, coordinators, and factories are MainActor-isolated, explicitly or by target default.
- Async repository and Data Source contracts conform to `Sendable` where they cross task boundaries.
- `APIClientImpl` uses `@unchecked Sendable`; its documented safety argument depends on immutable stored collaborators and a fresh decoder per request.
- The Pokémon list uses `withThrowingTaskGroup`; the detail flow uses `async let`.
- Cancellation is handled separately from domain failure in Use Cases, repositories, and ViewModels.

Default MainActor isolation means folder names do not imply background execution. The bundled JSON Data Source performs synchronous file read/decoding during feature construction. Moving CPU- or disk-heavy work behind an explicitly nonisolated service is follow-up work if this sample grows.

## Environments and network security

The project contains Development, Staging, and Production xcconfig files with matching shared schemes.

- **Development** is the only public flow built and tested as part of this reference. SSL pinning is disabled and internal API values are placeholders; the PokeAPI example uses its own HTTPS base URL.
- **Staging** is an illustrative template with placeholder endpoint configuration and pinning disabled.
- **Production** is an illustrative template. A build guard rejects release builds while the certificate hash remains the checked-in placeholder.

The presence of `SSLPinningDelegate`, interceptors, Keychain helpers, or a privacy manifest is implementation evidence, not a statement that the sample is production-ready. Product-specific authentication, secrets, certificates, observability, incident response, and privacy review remain outside this public repository.

## Testing strategy

The checked-in `ArquitecturaTests.xctestplan` executes `ArquitecturaTests` only. The 2026-08-04 source snapshot ran 194 Swift Testing cases in 27 suites covering:

- endpoint and interceptor behavior;
- DTO-to-domain and domain-to-presentation mapping;
- Repository and Data Source outcomes;
- Use Case sorting, pagination, error mapping, and cancellation;
- ViewModel state transitions and Router delegation;
- navigation encoding, restoration, and deep-link parsing;
- splash state behavior.

The Xcode project contains a nominal `ArquitecturaUITests` target, but there are no UI test sources and the target is absent from the test plan. The documentation therefore makes no UI-test claim.

Run the same public checks with `make ci`. The pipeline uses a dynamically selected iPhone simulator, disables code signing, lints without rewriting source, validates the public boundary, and fails if verification changes tracked files.

## Decision index

- Historical v1: [ADR-0001](docs/decisions/0001-protect-dependency-direction.md), [ADR-0002](docs/decisions/0002-mainactor-observable-state.md), [ADR-0003](docs/decisions/0003-explicit-composition-root.md)
- Current v2: [ADR-0004](docs/decisions/0004-single-app-target-logical-boundaries.md), [ADR-0005](docs/decisions/0005-hierarchical-composition-roots.md), [ADR-0006](docs/decisions/0006-typed-feature-routing.md)

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Created | 2026-08-04 |
| Last Updated | 2026-08-04 |
| Last Verified | 2026-08-04 |
| Status | Verified for the v2 source snapshot |
| Review Schedule | Quarterly and on architectural change |
| Labels | `ios`, `swiftui`, `architecture`, `mvvm`, `routing`, `dependency-injection` |
