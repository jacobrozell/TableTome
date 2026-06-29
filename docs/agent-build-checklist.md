# Agent Build Checklist — Tabletome

Living checklist for iOS app delivery.

**App:** Tabletome · **Bundle ID:** `com.jacobrozell.tabletome` · **Version:** 1.0.0 · **Phase:** TestFlight ([status](release/status.md))

**Agent entry:** [`AGENTS.md`](../AGENTS.md) · **Doc hub:** [`docs/README.md`](README.md)

---

## Quick reference

| Question | Where |
|----------|-------|
| What ships in 1.0? | [`feature-inventory.md`](feature-inventory.md), [`release/status.md`](release/status.md) |
| Where is the code? | [`development/code-map.md`](development/code-map.md) |
| Product behavior | `specs/*Spec.md` |
| Build / test / CI | [`development/setup.md`](development/setup.md), [`development/testing.md`](development/testing.md), [`development/ci.md`](development/ci.md) |
| Add analytics event | [`development/playbooks/add-analytics-event.md`](development/playbooks/add-analytics-event.md) |
| Ungate a feature | [`development/playbooks/ungate-feature.md`](development/playbooks/ungate-feature.md) |
| Firebase / segmentation | [`release/firebase-analytics.md`](release/firebase-analytics.md) |
| Active implementation | [`../ongoing/README.md`](../ongoing/README.md) |
| Ideas backlog | [`../FutureIdeas/`](../FutureIdeas/), [`brainstorm.md`](brainstorm.md) |

---

## Progress log

| Phase | Completed | Notes |
|-------|-----------|-------|
| 0 | 2026-06-17 | XcodeGen, folders, MCP, SwiftLint, pre-commit |
| 1 | 2026-06-17 | Specs, brainstorm, feature inventory, JSON schema |
| 2–5 | 2026-06-17+ | Design system, domain, data, app shell |
| 6–8 | 2026-06-22+ | Getting Started, rules browser, settings + GitHub Pages |
| 9 | 2026-06-28+ | Guided Match polish, battle tracker, match history |
| 10 | 2026-06-29 | Firebase Analytics + Crashlytics, feature adoption |
| 11 | 2026-06-29 | Documentation hub (AGENTS.md, code map, playbooks) |

---

## Phase 0 — Repo & agent infrastructure

- [x] **0.1** README.md
- [x] **0.2** XcodeGen `project.yml`
- [x] **0.3** Layered folders
- [x] **0.4** Pinned deployment target, bundle ID, Swift version
- [x] **0.5** `.gitignore`
- [x] **0.6** Pre-commit secret scan (`Scripts/pre-commit`)
- [x] **0.7** `.cursor/mcp.json`
- [x] **0.8** Cursor rules + [`AGENTS.md`](../AGENTS.md)
- [x] **0.9** SwiftLint
- [x] **0.10** CONTRIBUTING.md
- [x] **0.11** Verify xcodegen + xcodebuild
- [x] **0.12** Dedicated `Tabletome` simulator + MCP profile
- [x] **0.13** Doc hub [`docs/README.md`](README.md), [`development/code-map.md`](development/code-map.md)

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
- [x] **6.6** Integration test + relaunch restore
- [x] **6.7** UI test identifiers on critical controls

## Phase 7 — Rules reference

- [x] **7.1** Category filter + search
- [x] **7.2** Section list + detail with related navigation links
- [x] **7.3** Guide step → related rule section cross-link
- [x] **7.4** JSON scope tests
- [x] **7.5** Loading + error states on Rules tab

## Phase 8 — Settings & GitHub Pages

- [x] **8.1** Polished Settings
- [x] **8.2** GitHub Pages site in `docs/`
- [x] **8.3** `AppLinks` → hosted URLs
- [x] **8.4** `AppLinksTests`

## Phase 10 — Telemetry

- [x] **10.1** Firebase SPM + bootstrap (`App/Bootstrap/`)
- [x] **10.2** Sink-based logging + allowlisted GA4 events
- [x] **10.3** Crashlytics breadcrumbs + non-fatals
- [x] **10.4** Feature adoption user properties (`user_segment`, game sections)
- [x] **10.5** [`release/firebase-analytics.md`](release/firebase-analytics.md)
- [x] **10.6** Unit tests (mapping, bootstrap, adoption store)
- [ ] **10.7** GA4 custom dimensions registered in Firebase Console (ops)

## Phase 11 — Contributor & agent docs

- [x] **11.1** [`AGENTS.md`](../AGENTS.md)
- [x] **11.2** [`docs/README.md`](README.md) hub
- [x] **11.3** [`development/code-map.md`](development/code-map.md)
- [x] **11.4** [`development/setup.md`](development/setup.md), [`testing.md`](development/testing.md), [`ci.md`](development/ci.md)
- [x] **11.5** [`development/playbooks/`](development/playbooks/)
- [x] **11.6** [`Features/README.md`](../Features/README.md), [`Support/README.md`](../Support/README.md), [`DesignSystem/README.md`](../DesignSystem/README.md)
- [x] **11.7** [`release/README.md`](release/README.md)
- [ ] **11.8** CI documentation drift report (future — see Dart Buddy `documentation-summary.sh`)

---

## Playbooks

| Task | Doc |
|------|-----|
| Analytics event | [`development/playbooks/add-analytics-event.md`](development/playbooks/add-analytics-event.md) |
| Game system | [`development/playbooks/add-game-system.md`](development/playbooks/add-game-system.md) |
| Ungate feature | [`development/playbooks/ungate-feature.md`](development/playbooks/ungate-feature.md) |
| Guided match step | [`development/playbooks/add-guided-match-step.md`](development/playbooks/add-guided-match-step.md) |
