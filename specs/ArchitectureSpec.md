# Architecture Spec

## Layers

```
Features (SwiftUI + ViewModels)
    ↓ protocols
Data (Repositories, JSON loaders, SwiftData)
    ↓ types
Domain (Models, UseCases, Engines) — no SwiftUI
```

`App/` composes dependencies at launch. `DesignSystem/` and `Support/` are shared infrastructure.

## Module Map (XcodeGen targets)

| Target | Contents |
|--------|----------|
| Tabletome | App, Features, DesignSystem, Support |
| TabletomeDomain | Domain |
| TabletomeData | Data (+ TabletomeHobbyData for SwiftData hobby layer) |
| TabletomeTests | Tests/Unit |

## Dependency Rules

1. Domain imports Foundation only (no SwiftUI, UIKit, SwiftData).
2. Data imports Domain; implements repository protocols.
3. Features import Domain + DesignSystem; receive repositories via DI (`AppDependencies`).
4. No feature-to-feature imports; share via Domain or DesignSystem.
5. Data layer must not import app logging — use callbacks for analytics (see `NearbyMatchSyncService.analyticsHandler`).

## Navigation

- Root: `TabView` in `App/RootTabView.swift`
- **1.0 tabs:** Models (Collection), Play, Rules, Settings
- **Gated tab:** Lists (`Muster`) — `-enable_full_product_surface`
- `AppRouter` (`Support/Navigation/`) owns selected tab and play navigation path
- Deep links: `Support/Hobby/AppDeepLink.swift` → `AppRouter`

## DI

`AppDependencies` created in `TabletomeApp`, injected via SwiftUI `environmentObject` and `AppRouter` environment.

Logger: `AppDependencies.logger` → `DefaultAppLogger` with Console + Firebase sinks (Release).

## Release surface

`Support/ReleaseSurface.swift` controls tab visibility, game systems, and gated play features. Spec: [ReleaseSurfaceSpec.md](ReleaseSurfaceSpec.md).

## Documentation

| Topic | Doc |
|-------|-----|
| Code locations | [docs/development/code-map.md](../docs/development/code-map.md) |
| Feature folders | [Features/README.md](../Features/README.md) |
| Support infra | [Support/README.md](../Support/README.md) |

## Verification

| Field | Value |
|-------|-------|
| Target release | 1.0.0 TestFlight |
| Last verified | 2026-06-29 |
| Commit | (Firebase analytics + doc hub) |
| Code paths | `App/TabletomeApp.swift`, `App/AppDependencies.swift`, `App/RootTabView.swift`, `Support/Navigation/AppRouter.swift` |
