# Localization Spec

## v1 Policy

- **Source locale:** English (`en`)
- Strings: `Resources/Localizable.xcstrings`
- Code: `String(localized:)` — no hard-coded user-facing strings in Features

## Future

When adding locales, all keys must land simultaneously; parity test in `Tests/Unit/LocalizationParityTests.swift`.

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.1 |
| Last verified | 2026-06-17 |
| Commit | (initial scaffold) |
| Code paths | `Resources/Localizable.xcstrings` |
