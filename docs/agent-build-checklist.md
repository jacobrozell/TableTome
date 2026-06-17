# Agent Build Checklist — Spearhead Guide

Living checklist for iOS app delivery. See the full prompt library in the original spec document.

**App:** Table Tome · **Bundle ID:** `com.tabletome.app` · **MVP:** AoS Spearhead offline guide

## Progress log

| Phase | Completed | Commit | Notes |
|-------|-----------|--------|-------|
| 0 | 2026-06-17 | (pending) | XcodeGen, folders, MCP, SwiftLint, pre-commit |
| 1 | 2026-06-17 | (pending) | Specs, brainstorm, feature inventory, JSON schema |
| 2 | 2026-06-17 | (partial) | Design tokens + core components |
| 3 | 2026-06-17 | (partial) | Domain models, CombatRollEngine, tests |
| 4 | 2026-06-17 | (partial) | BundledRulesRepository |
| 5 | 2026-06-17 | (partial) | App shell, tabs, ReleaseSurface |
| 6 | 2026-06-17 | (partial) | Getting Started vertical slice |
| 7–18 | | | Not started |

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

## Phase 1 — Spec system

- [x] **1.1** `docs/brainstorm.md`
- [x] **1.2** System specs in `specs/`
- [x] **1.3** Promotion pipeline documented
- [x] **1.4** Verification blocks on feature specs
- [x] **1.5** `specs/README.md` + `docs/feature-inventory.md`
- [x] **1.6** Multi-game catalog in JSON + release gates

## Phase 6 — First vertical slice (in progress)

- [x] **6.1** Home + game system entry
- [x] **6.2** Getting Started step list
- [x] **6.3** Step detail with a11y identifiers
- [x] **6.4** Domain via ViewModels
- [x] **6.5** Guide progress in UserDefaults
- [ ] **6.6** Integration test + relaunch restore
- [x] **6.7** UI test identifiers on critical controls

## Quick reference

| Question | Where |
|----------|-------|
| Product behavior | `specs/*Spec.md` |
| What ships | `docs/feature-inventory.md` |
| Build/test | `README.md` |
| Ideas backlog | `docs/brainstorm.md`, `FutureIdeas/` |
