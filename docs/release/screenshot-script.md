# App Store Screenshot Script — 1.0.0

Shot list and capture workflow for **TestFlight / App Store** marketing. Scope matches [status.md](status.md): Spearhead + 40k 11e + Combat Patrol (10e rules), Models / Play / Rules / Settings.

**Deliverable matrix:** 8 frames × 4 variants = **32 captures**

| Variant | Simulator | Appearance |
|---------|-----------|------------|
| iPhone light | iPhone 16 Pro Max | Light |
| iPhone dark | iPhone 16 Pro Max | Dark |
| iPad light | iPad Pro 13-inch (M4) | Light |
| iPad dark | iPad Pro 13-inch (M4) | Dark |

Apple accepts 6.7″ iPhone and 12.9″/13″ iPad sizes; the simulators above map cleanly. Capture at **100% scale** (⌘S in Simulator) — no status-bar clutter from macOS window chrome.

---

## Pre-flight

1. **Release build** (or Run scheme with **no** `-enable_full_product_surface`). Confirm Play shows Spearhead, 40k 11e, and Combat Patrol (via 40k sub-picker or All games).
2. **Fresh-ish state:** delete app from simulator, or Settings → Reset guide progress + clear match history if re-shooting battle frames.
3. **Dynamic Type:** Settings → **Default** (not AXXXL). Screenshots should look like a typical user.
4. **Locale:** English (U.S.) unless localizing separately.
5. **Hide clutter:** no debug banners, no in-progress onboarding overlay, no empty error states.

### Launch arguments (automation / fast reset)

Combine in **Edit Scheme → Run → Arguments Passed On Launch**:

| Argument | Purpose |
|----------|---------|
| `-skip_onboarding` | Land on Play tab immediately |
| `-open_guided_match` | Deep-link to Spearhead Guided Match (default game system) |
| `-apply_starter_matchup` | Fill both starter armies |
| `-open_battle_tracker` | Complete setup + open Battle tab tracker (best for frames 4–5) |
| `UI-Testing-LightTheme` | Force light appearance |
| `UI-Testing-DarkTheme` | Force dark appearance |
| `UI-Testing` | Enables iPad Collection auto-select after sample load |

**Battle tracker shortcut (Spearhead):**

```
-skip_onboarding -open_guided_match -open_battle_tracker UI-Testing-LightTheme
```

Swap `UI-Testing-LightTheme` ↔ `UI-Testing-DarkTheme` per variant.

### Automation safety (no run loops)

All launch arguments above are **one-shot at cold launch** — no timers, no polling, no re-entrant navigation:

| Argument | Runs | Re-triggers? |
|----------|------|--------------|
| `-skip_onboarding` | Disables onboarding gate once | No |
| `-open_guided_match` | `RootTabView` pushes Guided Match once | No — `LearnNavigationCoordinator` consumes pending actions |
| `-apply_starter_matchup` / `-open_battle_tracker` | `GuidedMatchView.task` after catalog load | No — `.task` is not id-bound; view identity is stable after load |
| `UI-Testing-LightTheme` / `UI-Testing-DarkTheme` | `HobbyAppContainer.ensureConfiguration` once | No |
| `UI-Testing` | Collection iPad auto-select only | **Bounded** — max 30 × 100 ms (3 s), then exits; guarded by `selectedArmyId == nil` |

**Do not combine** `-apply_starter_matchup` with Frame 3 on **iPad** if you need the Setup hub tab — iPad split nav auto-opens the battle detail when both armies are filled. For Frame 3, use `-skip_onboarding -open_guided_match` only and tap **Use Starter Matchup** manually.

Reserve `UI-Testing` for **Frame 8 (Models)** only — omit it from battle-tracker launch lines.

The capture workflow’s “for each frame 1…8” loop is **manual photography**, not an in-app or fastlane automation loop.

---

## Shot list

Each frame includes a **caption** (App Store overlay text), **setup**, and **idiom notes**. Capture order below minimizes navigation churn.

---

### Frame 1 — Play home (hero)

**Caption:** *From starter box to first battle*

**Why:** Shows welcome copy, new-player chooser, and both shipped game systems in one glance.

**Setup**

1. Launch with `-skip_onboarding` + theme arg.
2. Play tab → ensure **Welcome** + **New to wargaming?** chooser visible (not a “Continue” card from an in-progress match).
3. Scroll so **All games** lists Spearhead and Warhammer 40,000 with taglines; both rows visible.

**Idiom**

- **iPhone:** Full list; chooser + at least one game row above the fold.
- **iPad:** Same content; wider cards — keep chooser and “All games” header in frame.

**Identifier:** `home.welcome`, `home.chooser.spearhead`, `home.gameSystem.aos-spearhead`

---

### Frame 2 — Spearhead “Start here”

**Caption:** *A guided path for your first wargame*

**Why:** Highlights beginner onboarding — What you need, Preview Turn, Guided Match.

**Setup**

1. Play → **Age of Sigmar Spearhead** → scroll to **First game?** card.
2. Ensure **What you need** checklist and numbered path steps 1–2 are visible.
3. Collapse nothing; glossary chips at bottom of What you need are optional trim.

**Idiom**

- **iPad:** Single-column guide reads well; avoid excessive whitespace above the card.

**Identifier:** `guide.newPlayerStartHere`, `guide.whatYouNeed`

---

### Frame 3 — Guided Match hub (armies)

**Caption:** *Starter matchups built in*

**Why:** Shows both armies picked without list-building — core “pass the phone at the table” promise.

**Setup**

1. From Frame 2 → tap **Guided Match**, or launch with `-skip_onboarding -open_guided_match` (add `-apply_starter_matchup` on **iPhone only** — iPad auto-jumps to battle detail when armies are prefilled).
2. **Armies** hub tab: both players show faction + army names (Skaventide vs Hallowed Knights default).
3. Tap **Use Starter Matchup** if armies empty.
4. Stay on **Setup** hub tab (not Battle). Expand setup steps if collapsed so checklist feels active.

**Idiom**

- **iPhone:** Compact setup list + army summary cards.
- **iPad:** Split layout with sidebar steps — show armies column + at least two setup steps.

**Identifier:** `guidedMatch.screen`

---

### Frame 4 — Battle tracker, Combat tab (hero)

**Caption:** *Phase coaching and combat tools at the table*

**Why:** Strongest differentiator — tabbed tracker, shooting helpers, Spearhead combat resolver.

**Setup**

1. Launch shortcut: `-skip_onboarding -open_guided_match -open_battle_tracker` + theme arg.
2. In tracker → **Combat** tab (`battleTracker.padTwoColumnLayout` on iPad).
3. Advance phase to **Shooting** or **Combat** (phase dock at top) so shooting-eligibility / pile-in content appears.
4. Expand combat resolver section; pick a matchup if needed (attacker vs defender) so hit/wound/save UI is visible — not collapsed “coming soon”.
5. Collapse top chrome if it crowds the resolver (`battleTracker` collapse toggle).

**Manual polish (recommended):**

- Player One active, Round 2+, deployment complete.
- One unit with partial wounds for realism (Army tab → adjust, then return to Combat).

**Idiom**

- **iPhone:** Combat tab with phase header + resolver + one helper card (shooting or pile-in).
- **iPad:** Two-column Combat layout — resolver in primary column; keep section tabs visible.

**Identifier:** `battleTracker.screen`, `battleTracker.padTwoColumnLayout`

---

### Frame 5 — Unit Focus

**Caption:** *Stats, weapons, and wounds — one tap away*

**Why:** Answers playtest feedback (“data cards hard to find”); shows warscroll-adjacent utility.

**Setup**

1. From Frame 4 → **Army** tab → tap a unit with a rich warscroll (e.g. **Rat Ogors** or **Clanrats**).
2. Unit Focus sheet open: health, weapons, wound stepper visible.
3. Do not open full warscroll sub-screen — sheet alone is the shot.

**Idiom**

- **iPhone:** Sheet presentation; title + stats + primary weapon block in frame.
- **iPad:** Same sheet; slightly wider — keep Done button visible.

**Identifier:** `unitFocus.sheet`

---

### Frame 6 — Rules reference (search)

**Caption:** *Look up rules without leaving the game*

**Why:** Rules tab is always available; search + categories sell “table reference” use case.

**Setup**

1. Rules tab → game picker **Age of Sigmar Spearhead** (or active game from Play).
2. Search: **`rend`** or **`pile-in`** — term with glossary-rich results.
3. Show search field + 2–3 results + category picker row.

**Idiom**

- **iPad:** Full-width list is fine; include game picker section header.

**Identifier:** `rules.gameSystemPicker`, rules list content

---

### Frame 7 — Warhammer 40,000 11e guide

**Caption:** *Full 40k — 11th Edition ready*

**Why:** Second shipped system; **New edition** badge if visible in release surface.

**Setup**

1. Play → **Warhammer 40,000** row → **Start here** card.
2. Frame **New to Warhammer 40,000** track (steps 1–3) and **What's New in 11e** link if badge shows.
3. Avoid Combat Patrol as the focal point for this frame — use the 11e guide path. CP has its own guide row via the 40k sub-picker.

**Identifier:** `guide.wh40k.gettingStarted`, `home.gameSystem.wh40k-11e`

---

### Frame 8 — Models collection

**Caption:** *Track miniatures between games*

**Why:** Shows hobby pillar without gated Paints segment.

**Setup**

1. Models tab → **Load sample data** (empty state) or use pre-seeded collection.
2. **Hallowed Knights** army selected (sample data default; iPad auto-selects when `UI-Testing` + sample load).
3. Show army list with paint progress / pipeline stats — not empty state.

**Idiom**

- **iPhone:** Army list with one army expanded or detail pushed.
- **iPad:** Split view — army sidebar + unit list/detail column (`CollectionHomeView` split).

**Identifier:** `loadSampleData`, collection army rows

---

## Optional frames (if expanding beyond 8)

| Frame | Screen | Caption |
|-------|--------|---------|
| A | Onboarding page 1 | *Built for the tabletop* |
| B | Preview Spearhead Turn | *Learn phases before you roll dice* |
| C | Match history | *Pick up where you left off* |
| D | 40k Guided Match (Armageddon) | *Starter armies for 11th Edition* |

Only add if App Store slot count or marketing story needs them.

---

## Capture workflow (automated)

Preferred: simulator capture scripts (same pattern as Dart Buddy):

```bash
# iPhone — 8 frames, dark mode, marketing-screenshots/raw/
./Scripts/capture-marketing-screenshots.sh

# Light mode
APPEARANCE=light ./Scripts/capture-marketing-screenshots.sh

# iPad 13"
./Scripts/capture-ipad-marketing-screenshots.sh
APPEARANCE=light ./Scripts/capture-ipad-marketing-screenshots.sh
```

See [`marketing-screenshots/README.md`](../../marketing-screenshots/README.md) for dimensions, launch args, and optional framing.

### Manual batching (legacy)

Work **one frame at a time across all four variants** (setup once, swap simulator appearance, re-shoot):

```
For each frame 1…8:
  1. Prepare screen state (manual or launch args)
  2. iPhone Light  → capture
  3. iPhone Dark   → Settings appearance or relaunch with UI-Testing-DarkTheme
  4. iPad Light    → switch simulator, repeat setup
  5. iPad Dark     → capture
  6. Name files: {frame}-{slug}-iphone-light.png etc.
```

**Suggested batching by launch args:**

| Batch | Frames | Launch args |
|-------|--------|-------------|
| Home & guides | 1, 2, 7 | `-skip_onboarding` + theme |
| Guided Match | 3 | `-skip_onboarding -open_guided_match` (+ `-apply_starter_matchup` on iPhone only) + theme |
| Battle | 4, 5 | `-skip_onboarding -open_guided_match -open_battle_tracker` + theme |
| Rules & Models | 6, 8 | `-skip_onboarding` + theme; Models: load sample on first capture |

Store outputs under `marketing-screenshots/raw/` and `marketing-screenshots/ipad/raw/` (committed PNGs optional; scripts regenerate locally).

---

## File naming

```
01-play-home-{iphone|ipad}-{light|dark}.png
02-spearhead-start-here-{iphone|ipad}-{light|dark}.png
03-guided-match-armies-{iphone|ipad}-{light|dark}.png
04-battle-combat-{iphone|ipad}-{light|dark}.png
05-unit-focus-{iphone|ipad}-{light|dark}.png
06-rules-search-{iphone|ipad}-{light|dark}.png
07-wh40k-guide-{iphone|ipad}-{light|dark}.png
08-models-collection-{iphone|ipad}-{light|dark}.png
```

---

## App Store Connect notes

- Upload **6.7″** set from iPhone captures; **13″ iPad Pro** set from iPad captures.
- Apple applies device frames in App Store Connect — export **full-screen PNG without manual device bezels**.
- Caption text is added in ASC or in designed marketing assets; keep captions ≤ ~30 characters for on-image overlays.
- Use the **same frame order** on iPhone and iPad for narrative consistency.

---

## QA before upload

- [ ] No gated tabs (Lists, Paints) visible in tab bar
- [ ] No StarCraft row in All games (1.0.0 release surface)
- [ ] Combat Patrol visible only when framing CP assets — not accidental in 11e-only shots
- [ ] No “coming soon” or empty resolver states in Frame 4
- [ ] Dark mode: semantic colors readable (cards, secondary text)
- [ ] iPad Frame 8: split view populated, not empty sidebar
- [ ] Status bar: full signal / Wi‑Fi / battery (Simulator → Features → toggle if needed)
- [ ] Time set to **9:41** (Apple convention): Simulator → Features → Trigger Screenshot → *not required for manual ⌘S*

---

## Related

- [release_checklist.md](release_checklist.md) — smoke paths
- [feature-inventory.md](../feature-inventory.md) — shipped vs gated
- [TestPlanSpec.md](../../specs/TestPlanSpec.md) — launch arguments
- `Support/AppLaunchArguments.swift`, `Data/Hobby/HobbyAppContainer.swift` — theme + deep links
