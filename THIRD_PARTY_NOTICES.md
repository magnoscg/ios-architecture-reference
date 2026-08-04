# Third-Party Notices

## PokeAPI service

The reference application's Pokémon list and detail screens make runtime HTTPS requests to [PokeAPI](https://pokeapi.co/) through `https://pokeapi.co/api/v2`.

The public PokeAPI server implementation is maintained at [PokeAPI/pokeapi](https://github.com/PokeAPI/pokeapi) and identifies its source-code licence as BSD 3-Clause. This repository does not include, modify, or redistribute that server code.

Runtime responses can contain Pokémon names, descriptions, statistics, and URLs for media maintained outside this repository. PokeAPI's separate [sprites repository](https://github.com/PokeAPI/sprites) describes a mixture of official, community, and custom sprite sources. Its existence must not be interpreted as a blanket licence from this project to redistribute Pokémon artwork.

This repository therefore:

- does not check Pokémon sprite or character artwork into source control;
- does not include the removed undocumented Pokéball SVG;
- uses a neutral Apple system `globe` symbol for the PokeAPI catalogue entry;
- may display remote images supplied by PokeAPI URLs while the sample is running;
- does not cache or redistribute those remote images as repository assets.

Pokémon and related names, characters, and artwork belong to their respective rights holders. This educational architecture reference is not affiliated with, endorsed by, or sponsored by those rights holders or by PokeAPI.

## Apple platform resources

The SwiftUI interface uses Apple frameworks and system-provided SF Symbols. System symbols are referenced by name and rendered by the operating system; they are not distributed here as standalone image files.

## OgamLabs assets

The OgamLabs logo, signature, and repository presentation artwork are first-party identity assets by Oscar Canton / OgamLabs. They are documented in [Asset provenance](ASSET_PROVENANCE.md) and are not third-party dependencies.

## Source-code dependencies

Version 2 has no third-party Swift package dependency. The repository source licence is [MIT](LICENSE.md); that licence does not grant rights to third-party services, data, names, marks, or remotely loaded media described above.

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Created | 2026-08-04 |
| Last Updated | 2026-08-04 |
| Last Verified | 2026-08-04 |
| Status | Verified third-party boundary |
| Review Schedule | On dependency, service, or asset changes |
| Labels | `third-party`, `attribution`, `pokeapi`, `licence` |
