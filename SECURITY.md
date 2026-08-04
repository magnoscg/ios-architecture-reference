# Security policy

## Scope

This repository is a reference Swift Package. It does not host a service, process personal data, include production credentials or ship a commercial application.

Security-relevant code is still treated as executable guidance:

- the live endpoint rejects clear-text HTTP before a request is created;
- transport and decoding errors are normalized before reaching presentation;
- CI receives read-only repository permissions;
- no third-party package executes during build or test;
- product source code and operational configuration are outside the repository boundary.

## Reporting

Please use GitHub private vulnerability reporting when it is available for this repository. Otherwise contact `soporte@ogamlabs.com` with:

- the affected file and revision;
- a minimal reproduction;
- expected impact;
- any suggested mitigation.

Do not include real credentials or personal data in a public issue.

## Supported versions

The latest tagged release on `main` receives security corrections. Educational forks and copied snippets are outside the support boundary.

## Non-goals

The HTTPS scheme check is a guardrail, not certificate pinning or a complete network-security policy. A production app must define its own authentication, trust, privacy, logging and incident-response requirements.

