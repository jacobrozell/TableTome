# Contributing

Thanks for contributing to Tabletome. Start with [`AGENTS.md`](AGENTS.md) (agents) or [`docs/development/setup.md`](docs/development/setup.md) (humans).

**Last updated:** 2026-06-29

---

## Architecture

Layered modules — **Features → Domain / Data → bundled JSON**. Domain never imports SwiftUI.

| Layer | Path | Responsibility |
|-------|------|----------------|
| App | `App/` | `@main`, DI bootstrap, root navigation |
| Features | `Features/` | SwiftUI + ViewModels per flow — see [Features/README.md](Features/README.md) |
| Domain | `Domain/` | Pure types, rule engines, use cases |
| Data | `Data/` | Repository protocols + JSON / SwiftData implementations |
| DesignSystem | `DesignSystem/` | Tokens, reusable components — [DesignSystem/README.md](DesignSystem/README.md) |
| Support | `Support/` | Release surface, logging, navigation — [Support/README.md](Support/README.md) |
| Resources | `Resources/` | Assets, localized strings, rules JSON |

Full code map: [`docs/development/code-map.md`](docs/development/code-map.md)

---

## Rules for agents & contributors

1. **Spec-first:** No user-visible behavior without an authoritative spec in `specs/`.
2. **Test-first for domain:** Pure logic and ViewModels get unit tests before UI polish.
3. **Regenerate Xcode project:** Run `xcodegen generate` after `project.yml` changes. Do not commit `.xcodeproj`.
4. **Release surface:** Gate unfinished UI via `Support/ReleaseSurface.swift` — hide, don't delete. Current target: **1.0.0 TestFlight** ([docs/release/status.md](docs/release/status.md)).
5. **Accessibility:** VoiceOver labels, 44pt targets, Dynamic Type on all new controls.
6. **Localization:** User-facing strings via `String(localized:)` / `Localizable.xcstrings`.
7. **Analytics:** No PII in logs. Follow [`docs/development/playbooks/add-analytics-event.md`](docs/development/playbooks/add-analytics-event.md).

---

## First PR checklist

- [ ] Behavior matches an updated spec **Verification** block
- [ ] [`docs/feature-inventory.md`](docs/feature-inventory.md) updated if scope changed
- [ ] [`ongoing/README.md`](ongoing/README.md) updated if completing active work
- [ ] Unit tests for domain / ViewModel changes
- [ ] `xcodegen generate` run if `project.yml` changed
- [ ] Accessibility identifiers on new interactive controls
- [ ] No secrets (`GoogleService-Info.plist`, credentials)
- [ ] SwiftLint clean (`TabletomeCI` scheme)

---

## Adding a feature (pipeline)

1. **Idea** → `FutureIdeas/` or `docs/brainstorm.md` (non-authoritative)
2. **Spec** → `specs/<Feature>Spec.md` with Verification block
3. **Implement** → Domain → Data → ViewModel → SwiftUI
4. **Inventory** → `docs/feature-inventory.md` status row
5. **Release** → gate in `ReleaseSurface` until QA signed off ([playbook](docs/development/playbooks/ungate-feature.md))

Governance: [`specs/README.md`](specs/README.md)

---

## Style

- Swift 6, iOS 17 minimum
- SwiftLint enforced in CI scheme pre-build
- Prefer `async` repository APIs; keep ViewModels `@MainActor`
- Split large types: `+Analytics.swift`, `+PadLayout.swift`, etc.

---

## Tests

See [`docs/development/testing.md`](docs/development/testing.md).

```bash
xcodegen generate
xcodebuild test -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=Tabletome' \
  -quiet
```

Place unit tests in `Tests/Unit/`. Name tests for scenarios, not types.

---

## Schema migrations

Rules JSON uses a top-level `schemaVersion`. Bump version and document migration in `specs/DataSchemaSpec.md` when breaking fields.

SwiftData hobby schema: `Data/Hobby/HobbySchemaMigrationPlan.swift`.

---

## Documentation index

[`docs/README.md`](docs/README.md)
