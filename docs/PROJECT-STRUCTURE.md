# Project Structure

**[Español](PROJECT-STRUCTURE.es.md)** · **[Architecture](../ARCHITECTURE.md)** · **[Known limitations](KNOWN-LIMITATIONS.md)**

## Organization model

The repository contains one iOS application target organized through logical source folders. At the top level, `App`, `Core`, `Domain`, `Data`, and `Features` express layers. Within `Domain`, `Data`, and `Features`, folders are divided by feature.

This makes the structure **layered globally and feature-oriented locally**. Presentation is the most vertically grouped area: each feature keeps its UI, ViewModel, presentation mappers, navigation, and composition factory together. It is not a set of independent feature modules.

See [ADR-0004](decisions/0004-single-app-target-logical-boundaries.md) for why the reference keeps one application target.

## Repository tree

```text
ios-architecture-reference/
├── Arquitectura.xcodeproj/
│   └── xcshareddata/xcschemes/
│       ├── Arquitectura-Dev.xcscheme
│       ├── Arquitectura-Stg.xcscheme
│       └── Arquitectura-Production.xcscheme
├── Arquitectura/
│   ├── ArquitecturaApp.swift
│   ├── Info.plist
│   ├── PrivacyInfo.xcprivacy
│   ├── App/
│   │   ├── Application/SplashScreen/
│   │   ├── Config/
│   │   │   └── Xcconfig/
│   │   └── Navigation/
│   ├── Core/
│   │   ├── Common/
│   │   ├── DesignSystem/
│   │   ├── Networking/
│   │   │   ├── PokeAPI/
│   │   │   └── Security/
│   │   └── Security/
│   ├── Domain/
│   │   ├── Architecture/
│   │   ├── ArchitectureDetail/
│   │   ├── PokemonList/
│   │   ├── PokemonDetail/
│   │   └── Common/
│   ├── Data/
│   │   ├── Architecture/
│   │   ├── ArchitectureDetail/
│   │   ├── PokemonList/
│   │   └── PokemonDetail/
│   ├── Features/
│   │   ├── Architecture/
│   │   ├── ArchitectureDetail/
│   │   ├── PokemonList/
│   │   └── PokemonDetail/
│   └── Resources/
│       ├── Assets.xcassets/
│       ├── Data/architecture_details.json
│       └── Strings/Localizable.xcstrings
├── ArquitecturaTests/
│   ├── ArquitecturaTests.xctestplan
│   ├── App/
│   ├── Core/
│   ├── Domain/
│   ├── Data/
│   ├── Features/
│   └── Mocks/
├── docs/
│   ├── decisions/
│   └── images/
├── scripts/
├── .swiftformat
├── .swiftlint.yml
└── Makefile
```

The tree intentionally does not show an `ArquitecturaUITests/` directory: the Xcode project has a nominal UI-test target, but no UI-test sources are checked in.

## What each zone owns

| Zone | Responsibility | Examples |
| --- | --- | --- |
| `App` | Startup, shared configuration, navigation root and app-lifetime wiring | `AppDependencies`, `RootNavigationView` |
| `Core` | Cross-feature UI primitives, design tokens, networking and security helpers | `APIClientImpl`, `AppColors` |
| `Domain` | Feature models and Use Case contracts/implementations | `PokemonListUseCaseImpl` |
| `Data` | Repository contracts/implementations, DTOs, mappers and Data Sources | `PokemonListRepositoryImpl` |
| `Features` | SwiftUI screens, screen state, ViewModels, decorators, routers and factories | `PokemonListFactory` |
| `Resources` | First-party asset catalog, local catalogue detail data and localizations | `architecture_details.json` |
| `ArquitecturaTests` | Swift Testing suites and protocol-based test doubles | `MockPokemonListUseCase` |

The folder placement records the current implementation. It should not be read as a claim that Repository protocols belong in `Data` in strict Clean Architecture; that deviation is tracked in [Known limitations](KNOWN-LIMITATIONS.md).

## Inside a feature

Presentation features use this real shape:

```text
Features/<Feature>/
├── DI/
│   └── <Feature>Factory.swift
├── Navigation/
│   ├── <Feature>Router.swift
│   └── <Feature>RouteResolver.swift     # when the feature owns destinations
├── Presentation/
│   ├── Mappers/
│   └── ViewModels/
└── UI/
    ├── Components/
    ├── <Feature>Decorator.swift
    ├── <Feature>State.swift
    └── <Feature>View.swift
```

Not every feature needs every file. For example, the Pokémon detail flow has no destinations of its own, while the list owns list/detail route cases and a resolver. Avoid empty layers created only for visual symmetry.

The matching data and domain areas are:

```text
Domain/<Feature>/
├── Models/
└── UseCases/

Data/<Feature>/
├── DataSources/
├── DTO/
├── Mappers/
└── Repositories/
```

## Where a new file goes

| New responsibility | Current location |
| --- | --- |
| SwiftUI screen or reusable feature component | `Features/<Feature>/UI/` |
| Screen state enum | `Features/<Feature>/UI/<Feature>State.swift` |
| ViewModel | `Features/<Feature>/Presentation/ViewModels/` |
| Domain-to-UI decorator mapping | `Features/<Feature>/Presentation/Mappers/` |
| Feature route or Router protocol | `Features/<Feature>/Navigation/` |
| Screen object-graph construction | `Features/<Feature>/DI/<Feature>Factory.swift` |
| Domain model | `Domain/<Feature>/Models/` |
| Use Case protocol and implementation | `Domain/<Feature>/UseCases/` |
| Repository protocol and implementation | `Data/<Feature>/Repositories/` under the current convention |
| Remote or bundled Data Source | `Data/<Feature>/DataSources/` |
| Transport DTO or DTO-to-domain mapper | `Data/<Feature>/DTO/` or `Data/<Feature>/Mappers/` |
| Cross-feature HTTP capability | `Core/Networking/` |
| App-lifetime dependency | `App/Config/AppDependencies.swift` and the relevant feature factory |
| Root-level route coordination | `App/Navigation/` |
| Test double | `ArquitecturaTests/Mocks/` |
| Focused test | Mirror the production layer under `ArquitecturaTests/` |

If a new dependency is screen-scoped, construct it in that feature's factory. Promote it to `AppDependencies` only when multiple screens need to share the same instance or lifetime.

## Targets, schemes, and configurations

The Xcode project defines three nominal targets:

- `Arquitectura`: the single application target containing all production source.
- `ArquitecturaTests`: the unit/integration-style Swift Testing target in the shared test plan.
- `ArquitecturaUITests`: an empty nominal target, not included in the test plan.

Shared schemes map to paired Debug/Release configurations:

| Scheme | Configurations | Public status |
| --- | --- | --- |
| `Arquitectura-Dev` | `Debug-Development`, `Release-Development` | Built and tested |
| `Arquitectura-Stg` | `Debug-Staging`, `Release-Staging` | Illustrative template |
| `Arquitectura-Production` | `Debug-Production`, `Release-Production` | Illustrative; release guard rejects placeholder certificate hash |

All application configurations use Swift 6 language mode and an iOS 18 deployment target. The project records Xcode 26.2 format metadata, the source snapshot is verified locally with Xcode 26.6 and Swift compiler 6.3.3, and CI uses the default Xcode selected by GitHub's `macos-26` image.

Some target-level bundle/product settings currently override values declared in xcconfig. Do not infer that the three schemes are distribution-ready identities. That configuration hardening belongs to the structural follow-up.

## Build phases and dependencies

- SwiftLint checks source style.
- SwiftFormat runs in lint-only mode during verification; only `make format` rewrites source.
- A release guard prevents Production release builds while the certificate hash is the published placeholder.
- There is no code generator and no checked-in generated source.
- There is no `Package.swift` in v2 and no third-party package dependency.

Run `make build`, `make test`, `make lint`, `make validate`, or the complete `make ci` workflow from the repository root.

## Test layout

The test tree mirrors the app's logical zones rather than separate compiled feature modules. Suites cover App navigation/splash behavior, Core networking, Domain Use Cases, Data repositories/mappers/Data Sources, feature ViewModels/mappers, and shared mocks.

The test plan executes only `ArquitecturaTests`. Adding genuine UI coverage requires creating an `ArquitecturaUITests/` source tree and adding that target to the plan; the empty target alone is not evidence of coverage.

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Created | 2026-08-04 |
| Last Updated | 2026-08-04 |
| Last Verified | 2026-08-04 |
| Status | Verified for the v2 source snapshot |
| Review Schedule | On structural change and quarterly |
| Labels | `ios`, `swift`, `project-structure`, `xcode` |
