# ADR-0006: Route with typed feature contracts

- **Status:** Accepted
- **Date:** 2026-08-04
- **Decision owner:** magnoscg / OgamLabs

## Context

The application uses one `NavigationStack` for architecture and Pokémon flows, supports deep links, and persists Codable navigation state. Views should express navigation intent without owning the global stack or constructing destination graphs.

One giant route enum would centralize every feature case. Direct `NavigationLink` destinations would couple list rows to concrete screens. String routes would weaken compiler checks and restoration.

## Decision

**Each feature will define Hashable/Codable route values and a small MainActor Router protocol. Implementations delegate to one app-level `AppRouter`, while root-installed resolvers map route values to feature factories.**

## Options considered

### Feature route types plus app router — chosen

- Keeps ViewModel navigation intents protocol-based and typed.
- Allows the root stack to resolve heterogeneous destinations.
- Requires cross-feature intent to be placed carefully.

### One monolithic `AppRoute`

- Makes every destination visible in one enum.
- Forces a central type to change for every feature and increases ownership coupling.

### Direct `NavigationLink` destination construction

- Is concise for leaf screens.
- Moves composition into UI and is harder to substitute in ViewModel tests.

### String/URL routing inside features

- Can be flexible at external boundaries.
- Loses typed payloads and pushes parsing concerns into feature code.

## Consequences

- ViewModels navigate through feature Router protocols.
- `AppNavigationCoordinator` owns deep-link parsing and path serialization concerns.
- Route values must remain Codable for restoration or gain an explicit migration strategy.
- The current Architecture-detail-to-Pokémon transition still knows a concrete route from another feature; that exception is documented for structural review.
- Multiwindow router ownership requires further validation before production adoption.

## Reversibility and validation

This choice is partially reversible at medium cost because route types are persisted and appear across routers, resolvers, coordinator tests, and factories. Changing their serialized form can invalidate stored paths.

The decision succeeds while routes are compiler-checked, Views do not construct cross-screen graphs, deep-link/restoration tests pass, and feature Router behavior remains unit-testable with mocks.

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Created / Verified | 2026-08-04 |
| Status | Accepted |
| Review Schedule | On route schema or scene ownership changes |
| Labels | `adr`, `navigation`, `router`, `swiftui` |
