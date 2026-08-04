# ADR-0002: Isolate observable presentation state on MainActor

- Status: accepted
- Date: 2026-08-04

## Context

SwiftUI reads observable state synchronously. Moving a ViewModel to a custom actor would force asynchronous property access and work against the rendering model.

## Decision

Keep the ViewModel and Router on `@MainActor`. Let actor-isolated services perform remote work and return immutable `Sendable` values through async protocols.

## Consequences

- UI mutation has one explicit owner.
- Tests touching presentation state declare `@MainActor`.
- CPU-heavy work would need a separate concurrent service rather than running in the ViewModel.

