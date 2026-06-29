# TestFlight — 1.0.0 (8)

**Branch:** `release/1.0.0` · **Scope:** Spearhead + 40k 11e + Combat Patrol (10e rules)

## What to test

- **Play** — chooser (40k sub-picker includes CP), resume card, game guides, Guided Match (Spearhead, 11e, Combat Patrol)
- **Rules** — browse + search for all three systems; CP labeled “Combat Patrol (10th Edition rules)”
- **Models** — add army, backlog, collection flow
- **First session** — Play tab **Start** badge until you open a guide
- **Offline** — airplane mode on Play + Rules
- **Settings** — legal links open; replay app tour

## Highlights in this build

- **Firebase Analytics + Crashlytics** (Release/TestFlight only) — allowlisted events, no PII; privacy policy updated
- **Feature adoption telemetry** — user segment properties (Models vs guided-match-only, AoS vs 40k, etc.)
- **Documentation** — agent/contributor doc hub (`AGENTS.md`, code map, playbooks)
- Build fix: developer README files no longer bundled in app

## Known scope limits

No Lists, Paints, StarCraft, or Rules Q&A assistant — gated for post-1.0. No full 10e matched play.

## Internal smoke (after install)

- [ ] Launch → no crash; onboarding or home loads
- [ ] Start one Spearhead guided match → battle tracker opens
- [ ] Visit Models tab once
- [ ] Firebase Realtime or DebugView: `app_open` within ~15 min (Release build only)
