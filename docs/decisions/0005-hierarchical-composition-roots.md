# ADR-0005: Use hierarchical manual composition roots

- **Status:** Accepted
- **Date:** 2026-08-04
- **Decision owner:** magnoscg / OgamLabs

## Context

The application has dependencies with different lifetimes. `APIClient` and the app router are shared across screens; navigation coordination belongs to the root view/scene; ViewModels, Use Cases, repositories, mappers, and Data Sources are created for a destination.

A single global composition file would know every feature detail. Constructing dependencies inside ViewModels would hide object lifetime, while a DI framework would add runtime registration for a small, statically known graph.

## Decision

**The application will use manual hierarchical composition: `ArquitecturaApp` and `AppDependencies` own app-lifetime objects, `RootNavigationView` owns scene/root coordination, and each feature factory is a screen sub-composition root.**

## Options considered

### Hierarchical factories — chosen

- Makes lifetime and construction call sites explicit.
- Keeps feature graphs close to their UI boundary and easy to replace in tests.
- Repeats small construction helpers across features.

### One global dependency container

- Provides one inventory of every concrete type.
- Grows cross-feature knowledge and can obscure screen-scoped lifetimes.

### Service locator or third-party DI container

- Can reduce constructor wiring for very large graphs.
- Adds hidden runtime lookup or a dependency without a demonstrated need here.

### Construct services inside ViewModels

- Requires less wiring initially.
- Couples business state to concrete infrastructure and weakens focused tests.

## Consequences

- Shared services enter feature factories explicitly.
- Feature ViewModels depend on protocols and do not read a global container.
- A factory may be a composition root even though it is not the app entry point.
- App-wide dependencies should be promoted only when their lifetime is genuinely shared.

## Reversibility and validation

This is easily reversible at low-to-medium cost because all collaborators already use constructor injection. A different container can replace factory internals without changing Domain contracts.

The decision succeeds while every screen graph can be found from its factory, no singleton/service locator is needed, and tests inject doubles through the same protocols.

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Created / Verified | 2026-08-04 |
| Status | Accepted |
| Review Schedule | When dependency lifetimes or graph size change |
| Labels | `adr`, `composition-root`, `dependency-injection`, `factory` |
