# Version 1 Swift Package Reference

## Preserved reference

Version 1.0.0 remains available at the preserved Git tag [`1.0.0`](https://github.com/magnoscg/ios-architecture-reference/tree/1.0.0). A GitHub Release was not created for that version, so documentation links to the real tag instead of a nonexistent release page.

The v1 tag contains a focused Swift Package with four library products:

- `ArchitectureDomain`
- `ArchitectureData`
- `ArchitectureFeature`
- `ArchitectureComposition`

Its target graph enforces Domain/Data/Feature/Composition dependencies at compile time and its 15 Swift Testing checks run on the package host.

## What changed in version 2

Version 2 is not an in-place package upgrade. It replaces the current branch with the real Xcode reference application used to demonstrate:

- a single application target with logical layer/feature folders;
- hierarchical app and screen composition roots;
- multiple real feature flows;
- typed NavigationStack routing, deep links, and route restoration;
- environment configuration, URLSession infrastructure, and simulator-based tests.

The trade-off is explicit: v2 provides broader application evidence, while v1 remains the smaller example with compile-time SPM boundaries.

## Existing v1 consumers

Consumers that need the package API should remain pinned to `1.0.0`:

```swift
dependencies: [
    .package(
        url: "https://github.com/magnoscg/ios-architecture-reference.git",
        exact: "1.0.0"
    )
]
```

Continue selecting the required v1 product, for example `ArchitectureComposition`, in the consuming target. Do not update to a v2 range expecting those products: v2 removes `Package.swift` and the `Architecture*` library products from the active tree.

## Choosing between the references

- Use the **v1 tag** when reviewing a small Swift Package with explicit module boundaries or maintaining an existing package consumer.
- Use the **v2 branch/tag** when reviewing the real SwiftUI application architecture, Xcode configuration, screen composition, navigation, and simulator test suite.

No automated source migration exists because the two versions intentionally demonstrate different public interfaces.

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Created | 2026-08-04 |
| Last Updated | 2026-08-04 |
| Last Verified | 2026-08-04 |
| Status | Historical compatibility note |
| Review Schedule | On release/versioning changes |
| Labels | `swift-package`, `migration`, `v1`, `compatibility` |
