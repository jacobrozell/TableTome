# Agent Build Checklist — Tabletome

Living checklist for iOS app delivery. See the full prompt library in the original spec document.

**App:** Tabletome · **Bundle ID:** `com.jacobrozell.tabletome` · **MVP:** AoS Spearhead offline guide

## Progress log

| Phase | Completed | Commit | Notes |
|-------|-----------|--------|-------|
| 0 | 2026-06-17 | (pending) | XcodeGen, folders, MCP, SwiftLint, pre-commit |
| 1 | 2026-06-17 | (pending) | Specs, brainstorm, feature inventory, JSON schema |
| 2 | 2026-06-17 | (partial) | Design tokens + core components |
| 3 | 2026-06-17 | (partial) | Domain models, CombatRollEngine, tests |
| 4 | 2026-06-17 | (partial) | BundledRulesRepository |
| 5 | 2026-06-17 | (partial) | App shell, tabs, ReleaseSurface |
| 6 | 2026-06-17 | (pending) | Getting Started vertical slice |
| 7 | 2026-06-17 | (pending) | Rules reference browser + cross-links |
| 8 | 2026-06-17 | (pending) | Settings polish + GitHub Pages docs |
| 9–18 | | | Not started |

## Phase 0 — Repo & agent infrastructure

- [x] **0.1** README.md
- [x] **0.2** XcodeGen `project.yml`
- [x] **0.3** Layered folders
- [x] **0.4** Pinned deployment target, bundle ID, Swift version
- [x] **0.5** `.gitignore`
- [x] **0.6** Pre-commit secret scan (`Scripts/pre-commit`)
- [x] **0.7** `.cursor/mcp.json`
- [x] **0.8** Cursor rules
- [x] **0.9** SwiftLint
- [x] **0.10** CONTRIBUTING.md
- [x] **0.11** Verify xcodegen + xcodebuild
- [x] **0.12** Dedicated `Tabletome` simulator + MCP profile (`Scripts/setup-tabletome-simulator.sh`)

## Phase 1 — Spec system

- [x] **1.1** `docs/brainstorm.md`
- [x] **1.2** System specs in `specs/`
- [x] **1.3** Promotion pipeline documented
- [x] **1.4** Verification blocks on feature specs
- [x] **1.5** `specs/README.md` + `docs/feature-inventory.md`
- [x] **1.6** Multi-game catalog in JSON + release gates

## Phase 6 — First vertical slice

- [x] **6.1** Home + game system entry
- [x] **6.2** Getting Started step list
- [x] **6.3** Step detail with a11y identifiers
- [x] **6.4** Domain via ViewModels
- [x] **6.5** Guide progress in UserDefaults
- [x] **6.6** Integration test + relaunch restore (`GuideProgressStoreTests`)
- [x] **6.7** UI test identifiers on critical controls

## Phase 7 — Rules reference

- [x] **7.1** Category filter + search (`RulesReferenceViewModel`)
- [x] **7.2** Section list + detail with related navigation links
- [x] **7.3** Guide step → related rule section cross-link
- [x] **7.4** v0.1 JSON scope tests (7 sections)
- [x] **7.5** Loading + error states on Rules tab

## Phase 8 — Settings & GitHub Pages

- [x] **8.1** Polished Settings (about, legal links, reset confirmation, version/build)
- [x] **8.2** GitHub Pages site in `docs/` (index, privacy, support, accessibility, styles)
- [x] **8.3** `AppLinks` → `jacobrozell.github.io/Tabletome` + [Buy Me a Coffee](https://buymeacoffee.com/jacobrozelq)
- [x] **8.4** `AppLinksTests`

## Quick reference

| Question | Where |
|----------|-------|
| Product behavior | `specs/*Spec.md` |
| What ships | `docs/feature-inventory.md` |
| Build/test | `README.md` |
| Ideas backlog | `docs/brainstorm.md`, `FutureIdeas/` |
