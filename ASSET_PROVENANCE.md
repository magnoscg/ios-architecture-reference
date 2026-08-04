# Asset Provenance

## Verification model

Every documentation image is first-party or an authentic capture of the checked-in application. No ImageGen, generative image model, stock art, Pokémon artwork, or third-party logo was used to create the v2 social preview or app gallery.

Exact file hashes are stored in `scripts/assets.sha256` and verified by `make assets` / `make validate`. Any image change must update this document and the manifest in the same pull request.

## Repository social preview

### Vector source

- **Distributed path:** `docs/images/social-preview.svg`
- **Purpose:** editable source for the 1280×640 GitHub social preview
- **Source:** deterministic, code-native SVG authored specifically for this repository
- **Content:** repository title, accurate single-app-target/MVVM/typed-routing labels, and a simplified hierarchical composition flow
- **Palette:** Studio Paper `#FAF9F6`, ink `#050505`, primary blue `#0066CC`, secondary blue `#005EB8`, pale blue `#E6F2FF`, connector grey `#6E6E73`
- **Author:** Oscar Canton / OgamLabs
- **AI generation:** none
- **Licence:** first-party repository presentation artwork; all rights reserved
- **SHA-256:** `a810920fced01acaec2968ca6ac6bc90687d3ac9711b165f8c430f0dfe9d7883`

### Raster delivery asset

- **Distributed path:** `docs/images/social-preview.png`
- **Dimensions:** 1280×640 RGBA PNG
- **Source:** exact local rasterization of `docs/images/social-preview.svg`
- **Method:** local WKWebView snapshot at the target dimensions
- **Modification:** no content changes after rasterization
- **Author:** Oscar Canton / OgamLabs
- **AI generation:** none
- **Licence:** first-party repository presentation artwork; all rights reserved
- **SHA-256:** `bdcf0d2904a59257703613cd0accbbcabcae13bdeb9e376419052182fe0b7f67`

The preview deliberately excludes the full architecture graph, small code text, brand logos, and Pokémon imagery so its message remains legible at GitHub card sizes.

## Authentic application captures

All four captures come from the checked-in `Arquitectura-Dev` application, not from a mockup. Capture conditions are:

- iPhone 17 Pro simulator running iOS 26.5;
- application locale `en_US`;
- 1206×2622 RGBA PNG output;
- normalized status bar at 09:41 and 100% battery;
- list and “Clean Architecture-inspired Layers” detail screens;
- light and dark appearances captured independently;
- no source change or visual compositing used to create the screen content.

| Distributed path | Appearance / screen | SHA-256 |
| --- | --- | --- |
| `docs/images/architecture-list-light.png` | Light · architecture catalogue | `11d313c9d98b5ccc9d97647863365229dc3ac36a87b522cb26cf905411e35d55` |
| `docs/images/architecture-list-dark.png` | Dark · architecture catalogue | `6ede392d8bbef754831f599067fe4beb613b4178b80184c1d103ecad7de072a3` |
| `docs/images/architecture-detail-light.png` | Light · implementation detail | `d60402672c9eb477a1a92eeb3d0a9055da45188fd528c5084f3fe59257c7e09f` |
| `docs/images/architecture-detail-dark.png` | Dark · implementation detail | `07cc2a1127c05cfb69670a98dbfd70b159fcac6b7946c267a238c8f05710937c` |

The screenshots contain Apple system UI and SF Symbols rendered by the simulator. They are distributed as documentation of this application, not as standalone Apple artwork. They contain no Pokémon character or sprite imagery.

### Accessibility contrast spot-check

The application pairs below were calculated with the WCAG sRGB relative-luminance formula. Ranges cover both the card surface and the surrounding app background where a token can appear.

| Pair | Light | Dark | Required |
| --- | ---: | ---: | ---: |
| Secondary text on surfaces | 5.78–6.45:1 | 7.69–9.50:1 | 4.5:1 |
| Tertiary text or metadata on surfaces | 4.97–5.54:1 | 5.93–7.31:1 | 4.5:1 |
| Success status icon on surfaces | 4.84–5.40:1 | 9.56–11.79:1 | 3:1 |
| Success badge text on its opaque fill | 5.40:1 | 10.59:1 | 4.5:1 |
| White text at the hero-gradient endpoints | 5.57–5.65:1 | 5.06–6.38:1 | 4.5:1 |

## First-party OgamLabs identity assets

These assets are retained from the original public reference and remain documented even though the v2 README and social preview do not embed them.

### Horizontal source logo

- **Distributed path:** `docs/images/brand-source/logo_ogamlabs_horizontal_full-color_light_1600x500.png`
- **Source:** first-party OgamLabs brand kit, version 1.0.0, 2026-08-03
- **Dimensions:** 1600×500 RGBA PNG
- **Author:** Oscar Canton / OgamLabs
- **Modification:** none; exact first-party export
- **AI generation:** none
- **Licence:** OgamLabs brand asset; all rights reserved
- **SHA-256:** `4c42e1beda262f4986d6893708196108e636ba3e6c1c9b97594e6682c4550cf5`

### README signature

- **Distributed path:** `docs/images/ogamlabs-signature.png`
- **Source:** deterministic presentation adaptation of the first-party horizontal logo
- **Dimensions:** 512×160 RGBA PNG
- **Modification:** white rounded panel added for contrast; logo geometry and colours unchanged
- **Author:** Oscar Canton / OgamLabs
- **AI generation:** none
- **Licence:** OgamLabs brand asset; all rights reserved
- **SHA-256:** `7345557ca0b992f49a2c98a1708fd2f3f80e55df897aade93ef5d4929ab28299`

## In-app asset boundary

The undocumented `pokeball.svg` and its asset-catalog entry were removed before publication. The PokeAPI catalogue row now references the Apple system `globe` symbol in code. Remote Pokémon media can be displayed at runtime from URLs returned by PokeAPI, but no such artwork is checked into this repository.

See [Third-party notices](THIRD_PARTY_NOTICES.md) for the service and trademark boundary.

## Licence boundary

The [MIT License](LICENSE.md) covers repository source code and documentation text. It does not grant rights to OgamLabs names/logos, Apple system artwork, or third-party names and media. The first-party presentation and brand assets identified above remain all rights reserved unless Oscar Canton / OgamLabs grants separate permission.

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Created | 2026-08-04 |
| Last Updated | 2026-08-04 |
| Last Verified | 2026-08-04 |
| Status | Verified against `scripts/assets.sha256` |
| Review Schedule | On every asset change |
| Labels | `assets`, `provenance`, `brand`, `screenshots`, `supply-chain` |
