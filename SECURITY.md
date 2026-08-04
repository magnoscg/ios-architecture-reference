# Security Policy

## Scope

This repository contains an executable iOS reference application, not a hosted service or commercial product. It includes no production credentials, private endpoints, signing keys, or user data.

Security-relevant code is published as reviewable implementation evidence:

- URLSession requests pass through a protocol-backed API client and interceptor chain.
- PokeAPI endpoints use a fixed HTTPS base URL.
- environment values are injected through xcconfig and Info.plist placeholders;
- SSL public-key pinning infrastructure can configure a URLSession delegate;
- a build guard rejects Production release builds while the certificate hash remains the public placeholder;
- the privacy manifest declares no tracking and lists the checked-in required-reason API usage;
- CI requests read-only repository contents and does not persist checkout credentials.

These points are not a production-security certification. Authentication, secret rotation, real certificates, backend authorization, observability, privacy review, incident response, and App Store signing are product responsibilities outside this repository.

## Reporting a vulnerability

Use GitHub Private Vulnerability Reporting when it is enabled for the repository. Otherwise email `soporte@ogamlabs.com` with:

- the affected file and revision;
- a minimal reproduction;
- expected impact;
- any suggested mitigation.

Do not include real credentials, exploit other systems, or place personal data in a public issue. Reports will be acknowledged before any public disclosure is coordinated.

## Supported versions

The latest release tagged on `main` receives security corrections. Version 1 remains preserved for compatibility but is historical; educational forks and copied snippets are outside the support boundary.

## Public configuration boundary

`Arquitectura-Dev` is the only scheme built and tested as runnable in the public workflow. Staging and Production contain intentionally non-secret placeholders. A consumer must replace and validate all environment values, certificate hashes, identities, entitlements, and signing configuration before considering a production build.

Do not report the visible `example.com` values or `REPLACE_WITH_YOUR_PRODUCTION_CERTIFICATE_HASH` marker as leaked secrets; they are deliberate blockers. Do report any real credential, private key, production endpoint, or personal path if one appears in repository history or a proposed change.

## Dependency and third-party boundary

The v2 Xcode project has no third-party Swift package dependency. The sample contacts PokeAPI at runtime; its availability, data, and referenced media are not controlled by this repository. See [Third-party notices](THIRD_PARTY_NOTICES.md).

The MIT licence covers repository source code, not OgamLabs marks or third-party intellectual property. See [Asset provenance](ASSET_PROVENANCE.md).

---

**Document Metadata**

| Field | Value |
| --- | --- |
| Author / Owner | magnoscg / OgamLabs |
| Last Updated / Verified | 2026-08-04 |
| Review Schedule | On security-relevant changes and quarterly |
| Labels | `security`, `ios`, `reporting`, `public-boundary` |
