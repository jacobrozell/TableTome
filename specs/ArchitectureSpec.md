# Architecture Spec

## Layers

```
Features (SwiftUI + ViewModels)
    ↓ protocols
Data (Repositories, JSON loaders)
    ↓ types
Domain (Models, UseCases, Engines) — no SwiftUI
```

`App/` composes dependencies at launch. `DesignSystem/` and `Support/` are shared infrastructure.

## Module Map (XcodeGen targets)

| Target | Contents |
|--------|----------|
| Spearhead | App, Features, DesignSystem, Support |
| SpearheadDomain | Domain |
| SpearheadData | Data |
| SpearheadTests | Tests/Unit |

## Dependency Rules

1. Domain imports Foundation only.
2. Data imports Domain; implements repository protocols.
3. Features import Domain + DesignSystem; receive repositories via DI.
4. No feature-to-feature imports; share via Domain or DesignSystem.

## Navigation

- Root: `TabView` — **Learn** (game guides), **Rules** (reference), **Settings**
- `NavigationStack` per tab
- Deep links: `Support/DeepLinkRouter.swift` (stub until Phase 14)

## DI

`AppDependencies` created in `SpearheadApp`, injected via SwiftUI `environment`.

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.1 |
| Last verified | 2026-06-17 |
| Commit | (initial scaffold) |
| Code paths | `App/SpearheadApp.swift`, `App/AppDependencies.swift` |
