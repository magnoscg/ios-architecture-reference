# Source Provenance and Public Boundary

**[README](../README.md)** · **[Architecture](../ARCHITECTURE.md)** · **[Asset provenance](../ASSET_PROVENANCE.md)**

## Provenance record

Version 2 is derived from fixed, first-party snapshots of the private architecture workspace owned by Oscar Canton. Only the reference application's `Example` subtree was exported; the source repository itself, its history, and unrelated tooling remain private.

| Field | Verified value |
| --- | --- |
| Source commit | `51c05fe810f8d842d25e93701c456501bdac4066` |
| Source subtree OID | `4e44e99f8eb398653a97bf600822afb4bb7c13b3` |
| Source subtree | `Example` |
| Tracked source files before sanitization | 220 |
| Snapshot verified | 2026-11-03 |
| Previous imports | `c046aee55f3fd25ff8508014660a06fe44b0fb41` (subtree `81a6fdeb88d4e7fe90dc43813bf4b2576680ddc9`, 217 files, 2026-11-03); `81f37c52f7a385247999ad30cc0d5a913f57192b` (subtree `e8f1f27bd38de15e1279ce58c96726c2595d6869`, 210 files, 2026-08-04) |
| Public owner | magnoscg / OgamLabs |

Commit and tree identifiers are reproducibility metadata, not credentials. This document intentionally omits the private remote URL and every local filesystem path.

## Reproducible export model

The import is based on the immutable source commit, not on a potentially dirty working directory. Its equivalent Git operation is:

```bash
git archive 51c05fe810f8d842d25e93701c456501bdac4066:Example
```

The exported subtree is promoted to the root of this public repository so `Arquitectura.xcodeproj`, `Arquitectura`, and `ArquitecturaTests` preserve their working relative paths. The private repository history is not merged, rewritten, or copied.

## Source allowlist

Only these zones from the fixed source commit are eligible for publication:

```text
Example/.swiftformat
Example/.swiftlint.yml
Example/Arquitectura.xcodeproj/
Example/Arquitectura/
Example/ArquitecturaTests/
```

After export, the `Example/` prefix is removed and those five entries become public repository roots.

Public-only material is maintained separately in this repository:

```text
.github/
docs/
scripts/
README*.md
ARCHITECTURE*.md
CHANGELOG.md
CONTRIBUTING.md
SECURITY.md
LICENSE.md
ASSET_PROVENANCE.md
THIRD_PARTY_NOTICES.md
Makefile
```

Any future source re-import must start from a new fixed commit and update this record in the same pull request.

## Explicit exclusions

The public snapshot excludes:

- the private repository's Git history and remote configuration;
- CLI/scaffolding source, templates, models, AI packs, plans, and internal documentation outside `Example`;
- user-specific Xcode data, workspace state, DerivedData, logs, caches, and `.DS_Store` files;
- credentials, signing material, production endpoints, real certificate hashes, and local paths;
- source from private products that consume this architecture.

The application therefore demonstrates the architecture without exposing the other projects that use it.

## Publication sanitization

The following review-only changes distinguish the public v2 tree from the source subtree:

- promoted the reference project from the `Example` subtree to repository root;
- removed user-local and untracked development artifacts;
- corrected the in-app catalogue from 21 mixed/contradictory claims to 19 implemented entries backed by real paths;
- removed unsupported SwiftData and background-executor claims and fabricated `Article*` snippets;
- replaced the undocumented Pokéball asset with the neutral system `globe` symbol;
- clarified catalogue and preview wording to distinguish the single application target from the separate test targets;
- raised secondary/status colour contrast in the documented screens and recaptured their light/dark simulator evidence;
- cleared personal Apple development-team identifiers from every Xcode configuration so consumers choose their own signing team locally;
- made only mechanical SwiftFormat/SwiftLint corrections, changed verification to non-mutating mode, and kept explicit formatting as a separate command;
- added public CI, boundary validation, bilingual documentation, decision records, and first-party presentation assets;
- preserved Development as the only validated runtime scheme while keeping Staging/Production visibly illustrative.

These changes do not introduce new architecture modules, persistence, UI tests, product code, or production configuration.

### Re-import of 2026-11-03

The second import applied the source diff between the previous and the current commit to the public tree instead of exporting the subtree again, so the sanitization above stays in place. In addition, it:

- kept the curated catalogue and updated the entries whose facts changed (layers, routing, composition, organization, typed errors, error mapping, and the PokeAPI example) together with their mirrored short descriptions;
- kept the public test that checks the 19 bundled catalogue entries, adapted to the new asynchronous Data Source;
- applied the public `nonisolated private` modifier order to new code;
- made mechanical SwiftFormat corrections required by the public 120-column configuration: realigned arguments after the `PokemonSummaryModel` rename, hoisted one `try`, and wrapped or split long test lines.

### Networking update of 2026-11-03

The networking changes between `c046aee55f3fd25ff8508014660a06fe44b0fb41` and `51c05fe810f8d842d25e93701c456501bdac4066` were applied the same way, as a source diff, to 12 files under `Arquitectura/Core/Networking`, `ArquitecturaTests/Core/Networking` and `Production.xcconfig`, which keeps its placeholder pin. In addition, the import:

- applied the public `nonisolated private` modifier order to three new declarations;
- reapplied the existing public wrapping to the `makeResponse` test helper, which gained a `headerFields` parameter, and wrapped its return type the way SwiftFormat already wraps `RetryInterceptor.intercept`;
- moved one long test pin into a local constant to stay within 120 columns;
- split the elliptic-curve algorithm table in `SSLPinningDelegate` into one named constant per curve, so SwiftFormat's collection wrapping holds within 120 columns; the encoded bytes are unchanged;
- updated the typed-error and SSL-pinning catalogue entries, the architecture documents, and the stated test totals.

Every other exported file under the allowlist is identical to the source commit or differs only by the sanitization listed above.

## Verification rules

`make validate` is responsible for checking the current public tree, including:

- allowed roots and forbidden private/local markers;
- documentation pairs and relative links;
- catalogue size, unique IDs, implementation flags, mirrored metadata, and every referenced file or directory;
- asset provenance and the `scripts/assets.sha256` manifest;
- absence of secrets and user-specific Xcode state;
- a test count derived from source/test output rather than a manually fixed total.

`make ci` additionally builds and tests the Development scheme, runs non-mutating lint, and ends with a clean-diff check.

## Licence boundary

Oscar Canton publishes the source present in this public repository under its [MIT License](../LICENSE.md). That licence does not transfer ownership of excluded private code, OgamLabs marks, or third-party names and media. See [Asset provenance](../ASSET_PROVENANCE.md) and [Third-party notices](../THIRD_PARTY_NOTICES.md).

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Created | 2026-08-04 |
| Last Updated | 2026-11-03 |
| Last Verified | 2026-11-03 |
| Status | Verified source-boundary record |
| Review Schedule | On every source re-import |
| Labels | `provenance`, `supply-chain`, `ios`, `public-boundary` |
