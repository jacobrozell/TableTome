# Tabletome — release todo

Status legend: `[ ]` todo · `[x]` done

Metadata: [`status.md`](status.md) · Expanded: [`release_checklist.md`](release_checklist.md)

## 1.0.0 TestFlight scope

- [ ] **Release surface defaults** — Spearhead + 40k 11e + Combat Patrol (10e); no Lists/Paints/StarCraft/Q&A
- [ ] **Tab bar** — Models (Collection), Play, Rules, Settings
- [ ] **Core flows** — Getting Started all three systems; Guided Match; match history; offline smoke
- [ ] **Quality** — VoiceOver; AXXXL; iPhone Pro Max landscape Models stack nav
- [ ] **Settings legal links** — GitHub Pages open (privacy updated 2026-06-29)

## TestFlight upload (build 8)

- [x] **Bump build** — `CURRENT_PROJECT_VERSION` → 8 in `project.yml`
- [x] **Privacy policy** — [`privacy.html`](../privacy.html) Firebase disclosure
- [x] **App Store listing draft** — analytics + nutrition labels in [`app-store-listing.md`](app-store-listing.md)
- [x] **Push GitHub Pages** — `main` merged from `release/1.0.0` (2026-06-29); allow 1–3 min for deploy
- [ ] **Archive + upload** — Release notes: [`testflight-1.0.0-build-8.md`](testflight-1.0.0-build-8.md)
- [ ] **Telemetry smoke** — `app_open` in Firebase after TestFlight install
- [ ] **App Store Connect privacy** — Diagnostics + Usage data (not “Data Not Collected”)
- [ ] **Gated backlog triage** — [`gated-features-testing.md`](gated-features-testing.md) before ungating
