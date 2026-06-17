# Contributing

## Architecture

Layered modules — **Features → Domain / Data → bundled JSON**. Domain never imports SwiftUI.

| Layer | Path | Responsibility |
|-------|------|----------------|
| App | `App/` | `@main`, DI bootstrap, root navigation |
| Features | `Features/` | SwiftUI + ViewModels per flow |
| Domain | `Domain/` | Pure types, rule engines, use cases |
| Data | `Data/` | Repository protocols + JSON implementations |
| DesignSystem | `DesignSystem/` | Tokens, reusable components |
| Support | `Support/` | Release surface, flags, AppLinks, logging |
| Resources | `Resources/` | Assets, localized strings, rules JSON |

## Rules for Agents & Contributors

1. **Spec-first:** No user-visible behavior without an authoritative spec in `specs/`.
2. **Test-first for domain:** Pure logic and ViewModels get unit tests before UI polish.
3. **Regenerate Xcode project:** Run `xcodegen generate` after `project.yml` changes. Do not commit `.xcodeproj`.
4. **Release surface:** Gate unfinished UI via `Support/ReleaseSurface.swift` — hide, don't delete.
5. **Accessibility:** VoiceOver labels, 44pt targets, Dynamic Type on all new controls.
6. **Localization:** User-facing strings via `String(localized:)` / `Localizable.xcstrings`.

## Style

- Swift 6, iOS 17 minimum
- SwiftLint enforced in CI scheme pre-build
- Prefer `async` repository APIs; keep ViewModels `@MainActor`

## Tests

```bash
xcodebuild test -scheme TabletomeCI -destination 'platform=iOS Simulator,name=iPhone 17'
```

Place unit tests in `Tests/Unit/`. Name tests for scenarios, not types.

## Schema Migrations

Rules JSON uses a top-level `schemaVersion`. Bump version and document migration in `specs/DataSchemaSpec.md` when breaking fields.
