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
| Navigation | `NavigationStack`, one `NavigationPath` per window, Codable feature route enums |
| Dependency injection | Constructor injection assembled by app and feature factories |
| Concurrency | Swift 6 language mode, default MainActor isolation, async/await, task groups |
| Networking | URLSession through a shared `APIClient`, endpoint values, and interceptors |
| Persistence | No domain database; route data only uses `@SceneStorage` |
| Dependencies | Apple frameworks only; no third-party Swift packages |

The presentation diagrams live in the README:

- [Layers and dependency direction](README.md#-architecture)
- [Life of a request](README.md#-life-of-a-request)
- [Composition and lifetimes](README.md#-inside-a-feature)

## Hierarchical composition root

Composition is split by lifetime instead of forced into one oversized container.

| Owner | Constructs | Lifetime |
| --- | --- | --- |
| [`ArquitecturaApp`](Arquitectura/ArquitecturaApp.swift) | `AppDependencies`, the launch state, and one `AppRootView` per window | Application |
| [`AppDependencies`](Arquitectura/App/Config/AppDependencies.swift) | Environment configuration and `APIClientImpl` | Application |
| [`AppRootView`](Arquitectura/App/Application/AppRootView.swift) | `AppRouterImpl`, `AppNavigationCoordinator`, splash or root navigation, and `.onOpenURL` | Window |
| [`RootNavigationView`](Arquitectura/App/Navigation/RootNavigationView.swift) | `NavigationStack`, path restoration, and route resolvers | Window |
| Feature factories | Data Source, mapper, Repository, Use Case, Router, ViewModel, View | Screen/navigation destination |

[`PokemonListFactory`](Arquitectura/Features/PokemonList/DI/PokemonListFactory.swift) is the clearest complete example. It receives the shared API client and the window's app router, creates the feature-specific collaborators, and injects the resulting ViewModel into the View. No service locator or DI framework is involved.

The architecture catalogue does not need networking, so [`ArchitectureFactory`](Arquitectura/Features/Architecture/DI/ArchitectureFactory.swift) builds a graph backed by static data. The splash factory creates only its ViewModel and View. Factories remain proportional to the feature they assemble.

See [ADR-0005](docs/decisions/0005-hierarchical-composition-roots.md) for the decision and alternatives.

## Logical layers and dependency direction

The intended collaboration direction is:

```text
App / Feature UI
        ↓
Presentation (ViewModel + presentation mapper + feature Router)
        ↓
Domain (Use Case + domain model + Repository protocol)
        ↓
Data implementation (Repository Impl + mapper + Data Source + error mapping)
        ↓
Core infrastructure (APIClient / URLSession) or bundled data
```

Responsibilities in the current tree:

- **App** owns startup, shared configuration, per-window navigation state, deep-link coordination, and application-lifetime dependencies.
- **Features** owns SwiftUI Views, explicit UI state, ViewModels, presentation decorators/mappers, typed feature routes, and factories.
- **Domain** is organized by domain concept (`Domain/Pokemon` serves both Pokémon screens) and owns models, Use Case protocols/implementations, Repository protocols, and `DomainError`.
- **Data** mirrors those concepts and owns Repository implementations, DTOs, DTO mappers, Data Sources, and the translation of infrastructure errors into `DomainError`.
- **Core** owns networking, security helpers, shared SwiftUI components, error presentation, and design tokens.

This is Clean Architecture-inspired rather than strict Clean Architecture. Domain owns its Repository contracts and knows no networking type, but the layers are folders in one target, so the compiler does not enforce the direction, and `ErrorDecorator` sits in `Core` despite being presentation-facing because every feature shares it. These are documented trade-offs, not hidden claims. See [Known limitations](docs/KNOWN-LIMITATIONS.md).

## Complete runtime paths

### Local architecture catalogue

```text
ArchitectureView
→ ArchitectureViewModel
→ ArchitectureUseCaseImpl
→ ArchitectureRepositoryImpl
→ ArchitectureStaticDataSourceImpl
```

Selecting an entry pushes an `ArchitectureRoute.detail`. The destination factory builds a second graph whose Data Source does no I/O when it is created: it reads and decodes `architecture_details.json` in a `@concurrent` function, off the main actor, when the detail is requested, and a missing or invalid file is thrown instead of being reported as an empty catalogue.

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

The list Repository uses a throwing task group to fetch item details concurrently and sorts successful results by ID. Individual non-cancellation detail failures are logged and omitted, but if every detail fails the first error is thrown, so a failed load never becomes an empty page; cancellation propagates. The detail Repository loads detail and species concurrently, treating species metadata as optional while keeping the primary detail required.

No PokeAPI response is persisted locally. See [Third-party notices](THIRD_PARTY_NOTICES.md) for attribution and scope.

## State, errors, and cancellation

Each screen ViewModel owns an explicit state enum such as `idle`, `loading`, `loaded`, and `error`. SwiftUI Views render that state and send user intents back to the ViewModel; they do not construct repositories or mutate the app path directly.

ViewModels guard duplicate loads. On `CancellationError`, they restore the previous state instead of leaving a loading screen stuck. List pagination tracks its loading and retryable error separately from the already loaded content.

The implemented error path is:

```text
APIError thrown by a Data Source
→ DomainError.catching { ... } inside a Repository
→ DomainError passed through by the Use Case
→ ErrorDecorator.from(...) inside a ViewModel
→ localized SwiftUI error state
```

This prevents raw server payloads from becoming user-facing copy and keeps Domain free of networking types: the translation lives in [`DomainError+Mapping.swift`](Arquitectura/Data/Common/DomainError+Mapping.swift). `DomainError.catching` rethrows `CancellationError`, treats any failure that arrives after the task was cancelled as cancellation, and maps everything else.

## Typed navigation and restoration

Each window's `AppRootView` owns one [`AppRouterImpl`](Arquitectura/App/Navigation/AppRouterImpl.swift) with an observable `NavigationPath`, so iPad windows navigate and restore independently. The `AppRouter` protocol only offers `push`, `pop`, and `popToRoot`; only the App layer reads or replaces the whole path. Each flow defines Codable, Hashable route values and a small feature Router protocol. ViewModels express intent through those protocols; implementations delegate to the app router.

[`RootNavigationView`](Arquitectura/App/Navigation/RootNavigationView.swift) installs feature-specific `navigationDestination` resolvers. [`AppNavigationCoordinator`](Arquitectura/App/Navigation/AppNavigationCoordinator.swift) parses the `arquitectura://` deep-link scheme and encodes the path into `@SceneStorage` after a debounce; a failed encoding writes nothing, keeping the last good state. A valid deep link replaces the stack instead of pushing on top. A link received before restoration, such as the URL that launched the app, is held and applied right after restoring, so the result does not depend on whether `.onOpenURL` or the restoration task runs first.

This keeps route construction out of Views while allowing heterogeneous destinations in one stack. Unit tests cover the launch-ordering cases; multiwindow and cold-launch flows have no UI-test coverage. See [ADR-0006](docs/decisions/0006-typed-feature-routing.md).

## Swift concurrency model

The project uses Swift 6 language mode and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` for the app and test targets.

- SwiftUI Views, ViewModels, routers, coordinators, and factories are MainActor-isolated, explicitly or by target default.
- Async repository and Data Source contracts conform to `Sendable` where they cross task boundaries.
- `APIClientImpl` uses `@unchecked Sendable`; its documented safety argument depends on immutable stored collaborators and a fresh decoder per request.
- The Pokémon list uses `withThrowingTaskGroup`; the detail flow uses `async let`.
- Cancellation is handled separately from domain failure in `APIClientImpl`, the retry interceptor, repositories, and ViewModels. `APIClientImpl` turns `URLError.cancelled` into `CancellationError` only when the task was cancelled, so a rejected pinning challenge stays a network error.
- The retry interceptor only resends idempotent methods or requests that carry an `Idempotency-Key` header. It does not retry errors that describe the device state, such as being offline, honors `Retry-After` up to the policy's `maxDelay`, and stops once the policy's total time budget is spent.
- `APIClientImpl` invalidates only a `URLSession` it created. With pinning enabled, only the API host is pinned, and missing or malformed pins reject API connections instead of silently disabling pinning.

Default MainActor isolation means folder names do not imply background execution. Work that must leave the main actor is marked explicitly: the bundled JSON Data Source decodes in a `@concurrent` function, and DTO mappers are `nonisolated` so they can run inside task-group children.

## Environments and network security

The project contains Development, Staging, and Production xcconfig files with matching shared schemes.

- **Development** is the only public flow built and tested as part of this reference. SSL pinning is disabled and internal API values are placeholders; the PokeAPI example uses its own HTTPS base URL.
- **Staging** is an illustrative template with placeholder endpoint configuration and pinning disabled.
- **Production** is an illustrative template. A build guard rejects release builds while the certificate hash remains the checked-in placeholder.

The presence of `SSLPinningDelegate`, interceptors, Keychain helpers, or a privacy manifest is implementation evidence, not a statement that the sample is production-ready. Product-specific authentication, secrets, certificates, observability, incident response, and privacy review remain outside this public repository.

## Testing strategy

The checked-in `ArquitecturaTests.xctestplan` executes `ArquitecturaTests` only. The 2026-11-03 source snapshot declares 226 Swift Testing cases in 30 suites covering:

- endpoint and interceptor behavior, including retry idempotency and cancellation;
- DTO-to-domain and domain-to-presentation mapping;
- Repository and Data Source outcomes, including the `DomainError` mapping in Data;
- Use Case sorting, pagination, error pass-through, and cancellation;
- ViewModel state transitions and Router delegation;
- navigation encoding, restoration, deep-link parsing, and launch ordering;
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
| Last Updated | 2026-11-03 |
| Last Verified | 2026-11-03 |
| Status | Verified for the v2 source snapshot |
| Review Schedule | Quarterly and on architectural change |
| Labels | `ios`, `swiftui`, `architecture`, `mvvm`, `routing`, `dependency-injection` |
