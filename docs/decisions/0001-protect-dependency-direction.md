# ADR-0001: Protect dependency direction with Swift Package targets

- Status: accepted
- Date: 2026-08-04

## Context

Folders communicate intent but do not stop a data type from importing UI code or a ViewModel from constructing a concrete network client.

## Decision

Use separate Domain, Data, Feature and Composition targets. Domain owns the repository abstraction; Data implements it; Feature consumes only the domain use case; Composition selects concrete implementations.

## Consequences

- Invalid imports fail at compile time.
- Unit tests can target boundaries independently.
- Public types and target wiring add ceremony, so the split should remain limited to meaningful ownership boundaries.

