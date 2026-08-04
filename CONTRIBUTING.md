# Contributing

This reference uses Gitflow:

- branch features from `develop` as `feature/*`;
- merge completed features into `develop`;
- prepare versions on `release/*`;
- merge releases into both `main` and `develop`;
- tag `main` with semantic versions such as `1.0.0`.

Before proposing a change:

```bash
swift test
swift build -c release
./scripts/validate-public-content.sh
```

Keep changes small, use Conventional Commits and add tests for new behavior. Do not add commercial product code, credentials, private endpoints or generated AI content without explicit provenance and review.

