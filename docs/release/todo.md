# Tabletome — release todo

Status legend: `[ ]` todo · `[x]` done

Metadata: [`status.md`](status.md) · Expanded: [`release_checklist.md`](release_checklist.md)

## 1.0.0 TestFlight scope

- [x] **Release surface defaults** — Spearhead play + Collection + Paints. 40k, Combat Patrol, StarCraft, Lists, and Rules Q&A stay gated (locked 28 Oct 2026)
- [ ] **Tab bar** — Models, Play, Rules, Settings
- [ ] **Core flows** — Spearhead Getting Started and Guided Match; match history; offline smoke
- [ ] **Quality** — VoiceOver; AXXXL; iPhone Pro Max landscape Models stack nav
- [ ] **Settings legal links** — GitHub Pages open (privacy updated 2026-06-29)

## TestFlight upload

- [x] **Bump build** — `CURRENT_PROJECT_VERSION` → 11 in `project.yml`
- [x] **Privacy policy** — [`privacy.html`](../privacy.html) Firebase disclosure
- [x] **App Store listing draft** — analytics + nutrition labels in [`app-store-listing.md`](app-store-listing.md)
- [x] **Push GitHub Pages** — `main` merged from `release/1.0.0` (2026-06-29); allow 1–3 min for deploy
- [ ] **Next TestFlight** — a new build after the UI overhaul tracker ([`../../ongoing/ui-overhaul/README.md`](../../ongoing/ui-overhaul/README.md) §6). Build 11 notes stay in [`testflight-1.0.0-build-11.md`](testflight-1.0.0-build-11.md).
- [ ] **Telemetry smoke** — `app_open` in Firebase after TestFlight install
- [ ] **App Store Connect privacy** — Diagnostics + Usage data (not “Data Not Collected”)
- [ ] **Gated backlog triage** — [`gated-features-testing.md`](gated-features-testing.md) before ungating
