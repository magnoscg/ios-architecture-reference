# Contributing

This repository publishes a real iOS reference application. Contributions must keep its code, architecture claims, screenshots, and public boundary aligned.

## Branch and release flow

The repository uses Gitflow:

- branch features from `develop` as `feature/*`;
- merge completed features into `develop`;
- prepare versions on `release/*`;
- merge releases into both `main` and `develop`;
- tag `main` with semantic versions such as `2.0.0`.

Use Conventional Commit subjects. Do not add `Co-Authored-By` lines for Codex or other coding agents.

## Local verification

The project uses Xcode 26.2 format metadata and is locally verified with Xcode 26.6. You also need an iOS 18+ simulator, SwiftFormat, and SwiftLint. Run the full read-only verification before proposing a change:

```bash
make ci
```

Focused commands are available when iterating:

```bash
make build
make test
make lint
make validate
```

`make lint` must not change files. `make format` is the only project command intended to rewrite Swift formatting; review its diff before committing.

## Change rules

- Add or update focused Swift Testing coverage for behavior changes.
- Keep English and Spanish documentation pairs synchronized.
- Update an ADR when a change alters target strategy, composition lifetime, or navigation contracts.
- Use real repository paths in catalogue details and documentation; do not add pseudocode presented as implementation.
- Update `ASSET_PROVENANCE.md` and the SHA-256 manifest for every file under `docs/images/`.
- Do not add private product code, private repository metadata, credentials, signing keys, production endpoints, local paths, or user-specific Xcode state.
- Do not embed third-party artwork without a documented redistribution basis and explicit review.
- Keep Staging/Production described as illustrative until their effective settings and secrets are genuinely configured and validated.

## Pull-request checklist

- [ ] `make ci` passes from a clean checkout.
- [ ] New logic has tests and the shared test plan executes them.
- [ ] Verification leaves `git diff --exit-code` clean.
- [ ] Architecture claims link to real code.
- [ ] `README.md` and `README.es.md` remain equivalent; the same applies to architecture, structure, and limitations.
- [ ] Documentation freshness dates are updated where behavior changed.
- [ ] New assets include origin, author, modification, licence boundary, and SHA-256 evidence.
- [ ] No private or user-local material enters the diff.

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Last Updated / Verified | 2026-08-04 |
| Review Schedule | On workflow changes |
| Labels | `contributing`, `gitflow`, `testing`, `documentation` |
