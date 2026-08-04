# ADR-0003: Compose concrete dependencies at one edge

- Status: accepted
- Date: 2026-08-04

## Context

Constructing concrete clients inside features hides configuration, couples tests to implementation details and encourages global mutable state.

## Decision

Create object graphs in `ArchitectureComposition`. Expose deterministic demo and HTTPS live graphs, both satisfying the same domain contracts.

## Consequences

- Feature code is independent from environment configuration.
- Previews and tests can use deterministic dependencies.
- A larger application may eventually split composition by scene or feature, but concrete construction remains at an outer boundary.

