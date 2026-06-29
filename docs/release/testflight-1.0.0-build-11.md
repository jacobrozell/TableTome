# TestFlight — 1.0.0 (11)

**Branch:** `release/1.0.0` · **Scope:** Spearhead + 40k 11e + Combat Patrol (10e) + **Paints inventory**

## What to test

- **Play** — chooser, Guided Match, match history save (or alert on failure)
- **Rules** — browse + search for all three systems
- **Models** — Collection + **Paints** sidebar; add paint with catalog autocomplete; refresh colours in Settings → Models & Data
- **Settings → Suggest something** — category picker, Mail draft, copy fallback banner
- **Offline** — Play + Rules error states use warning triangle (not Wi‑Fi icon)
- **Accessibility** — VoiceOver on feedback form and paint catalog rows

## Highlights in this build

### Paints (now shipped)

- **Paints tab** in Models — inventory, swatches, link to collection by source
- **Paint & basing catalogs** — 280+ paint swatches + 75+ basing materials (JSON-backed)
- **Catalog autocomplete** when adding or editing a paint name
- **Match paint colour** + custom swatch picker
- **Refresh paint colours** — Settings → Models & Data → Paints (bulk re-apply catalog)

### Feedback

- **Settings → Suggest something** — structured email for paint/basing/army/rules/bug/improvement requests
- Pre-filled device + app version in the email body

### Polish (from build 10)

- Muster/Lists fully gated; match-history save failure alert
- Accessibility: VoiceOver, Reduce Motion, 44pt targets
- Deep links `tabletome://`; backup `tabletome-backup-*.json`

## Developer tooling

- `Scripts/feedback-catalog-suggestions.py` — paste feedback email → draft catalog JSON row

## Known scope limits

No Lists/Muster, StarCraft, or Rules Q&A assistant — still gated. No full 10e matched play.

## Internal smoke (after install)

- [ ] Models → Paints → Add → type "Kantor" → pick catalog row → correct swatch
- [ ] Settings → Suggest something → Send feedback → Mail draft looks right
- [ ] Settings → Models & Data → Refresh paint colours
- [ ] Firebase: `app_open` within ~15 min (Release build only)
