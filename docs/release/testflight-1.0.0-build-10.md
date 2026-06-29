# TestFlight — 1.0.0 (10)

> **Superseded by** [`testflight-1.0.0-build-11.md`](testflight-1.0.0-build-11.md) — Paints tab + feedback form.

**Branch:** `release/1.0.0` · **Scope:** Spearhead + 40k 11e + Combat Patrol (10e rules)

## What to test

- **Play** — chooser, resume card, Guided Match (Spearhead, 11e, Combat Patrol), finish/abandon match → confirm History saves (or alert if save fails)
- **Rules** — browse + search for all three systems
- **Models** — add army, pipeline swipe, Data settings → Privacy/Accessibility open in Safari
- **Onboarding / app tour** — Rules tab labeled browse-only (not “Rules Search”); Models naming consistent
- **Accessibility** — VoiceOver on setup checklists; Reduce Motion on battle tracker chrome collapse
- **Offline** — airplane mode on Play + Rules (error icon is warning triangle, not Wi‑Fi)
- **Settings** — legal links; About copy says “model tracking” not Lists

## Highlights in this build

- **Release polish** — Muster/Lists fully gated (no dead-end from army detail or deep links); match-history save failure alert
- **App category** — binary `LSApplicationCategoryType` → Reference (matches App Store listing)
- **Accessibility** — checklist/step completion VoiceOver; Reduce Motion on battle/hub animations; 44pt dismiss targets on battle banners; match history row summaries; phase dock disabled hints; Settings tab VoiceOver label
- **Guided Match** — setup steps footer when armies not chosen
- **Release gating** — Paints CSV import/export hidden when Paints tab is gated
- **Copy** — Models vs Collection naming aligned; hosted Privacy/Accessibility in Models data settings
- **Deep links / backup** — scheme `tabletome://`; backup filename `tabletome-backup-*.json`

## Known scope limits

No Lists, Paints, StarCraft, or Rules Q&A assistant — gated for post-1.0. No full 10e matched play.

## Internal smoke (after install)

- [ ] Launch → no crash; onboarding or home loads
- [ ] Start one Spearhead guided match → battle tracker opens
- [ ] Finish or abandon match → History entry or “Match not saved” alert
- [ ] Visit Models tab once
- [ ] Firebase: `app_open` within ~15 min (Release build only)
