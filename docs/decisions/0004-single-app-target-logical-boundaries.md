# ADR-0004: Use one application target with logical layer boundaries

- **Status:** Accepted
- **Date:** 2026-08-04
- **Decision owner:** magnoscg / OgamLabs

## Context

Version 2 publishes the real reference application. Its production code already lives in one Xcode application target organized as `App`, `Core`, `Domain`, `Data`, and `Features`, with feature subdivisions inside the latter three zones.

Turning the publication into multiple Swift packages would make the diagram stricter, but it would no longer be the architecture being presented. Keeping one flat folder would preserve runtime behavior while hiding the intended responsibilities.

## Decision

**Version 2 will keep one application target and document its layer/feature folders as logical, review-enforced boundaries.** Test targets remain separate for verification, not as production modules.

## Options considered

### One app target with logical folders — chosen

- Preserves the real source and straightforward Xcode workflow.
- Keeps feature navigation and shared UI composition simple.
- Does not prevent invalid cross-layer references at compile time.

### Convert the app to local Swift packages

- Could enforce dependencies and improve independent ownership.
- Would be a structural refactor rather than truthful publication, with extra public APIs and build wiring.

### Keep the v1 package as the current reference

- Retains a very clear module graph and fast host tests.
- Does not show the real application architecture, configuration, navigation, or screen composition.

## Consequences

- Documentation must say “single application target,” not “modular architecture.”
- Folder placement, review, tests, and optional static checks protect the intended direction.
- Repository protocol placement and cross-layer references remain visible technical decisions/debt.
- Future modularization requires evidence from ownership, reuse, or build performance rather than aesthetics.

## Reversibility and validation

The decision is reversible with medium cost because creating modules requires access-level changes, dependency extraction, resource ownership, and updated test hosts. No data migration is involved.

The decision succeeds while a reviewer can trace complete flows, public CI builds/tests the app from a clean checkout, and documentation makes no compile-time enforcement claim.

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Created / Verified | 2026-08-04 |
| Status | Accepted |
| Review Schedule | When ownership or build constraints change |
| Labels | `adr`, `xcode`, `single-target`, `architecture` |
