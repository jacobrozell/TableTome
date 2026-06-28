# Marketing Screenshots

Professional App Store and marketing assets for **Tabletome**.

## Quick start

```bash
# iPhone (6.9" slot — iPhone 17 Pro Max, native 1320×2868)
./Scripts/capture-marketing-screenshots.sh

# Light mode
APPEARANCE=light ./Scripts/capture-marketing-screenshots.sh

# iPad 13" (2064×2752 portrait, auto-resized for App Store)
./Scripts/capture-ipad-marketing-screenshots.sh

# Optional: device bezels for web/social (not for App Store upload)
brew install imagemagick   # once
./Scripts/frame-marketing-screenshots.sh
```

## Output folders

| Folder | Use |
|--------|-----|
| `raw/` | iPhone → **App Store Connect** (no bezels) |
| `ipad/raw/` | iPad 13" → **App Store Connect** |
| `framed/` | Website, social, press kit (with bezels) |

## App Store Connect dimensions

Upload **`raw/`** and **`ipad/raw/`** only (no device frames).

**iPhone 6.9" Display** (default simulator: iPhone 17 Pro Max):

- Native **1320 × 2868** — `APP_STORE_RESIZE=0` (default)

**iPhone 6.5" Display** (alternate):

```bash
SIM_NAME="iPhone 17 Pro" APP_STORE_RESIZE=1 ./Scripts/capture-marketing-screenshots.sh
```

Resizes to **1284 × 2778** after capture.

**iPad 13" Display:**

- **2064 × 2752** portrait (default after `./Scripts/capture-ipad-marketing-screenshots.sh`)

Fix existing PNGs without re-capturing:

```bash
./Scripts/app-store-screenshot-size.sh resize marketing-screenshots/raw/*.png
```

## Screens captured (1.0.0)

Shot list and captions: [`docs/release/screenshot-script.md`](../docs/release/screenshot-script.md).

1. **Play home** — chooser + all games (`-snapshot_play_home`)
2. **Spearhead Start here** — (`-open_game_guide aos-spearhead`)
3. **Guided Match setup** — starter armies (`-snapshot_guided_match_armies`)
4. **Battle tracker, Combat tab** — (`-snapshot_battle_combat`)
5. **Unit Focus** — (`-open_unit_focus`)
6. **Rules search** — (`-open_rules_search rend`)
7. **Warhammer 40,000 11e guide** — (`-open_game_guide wh40k-11e`)
8. **Models collection** — sample data (`-snapshot_models_collection`)

Each capture runs in **dark** or **light** mode via `APPEARANCE=light|dark` (maps to `UI-Testing-LightTheme` / `UI-Testing-DarkTheme`).

## Launch arguments reference

| Screen | Arguments |
|--------|-----------|
| Reset + skip onboarding | `-reset_user_defaults -skip_onboarding` |
| Play home hero | `-snapshot_play_home` |
| Game guide | `-open_game_guide aos-spearhead` / `wh40k-11e` |
| Guided Match armies | `-open_guided_match -snapshot_guided_match_armies` |
| Battle tracker | `-open_guided_match -open_battle_tracker -snapshot_battle_combat` |
| Unit Focus sheet | add `-open_unit_focus` |
| Rules search | `-open_rules_search rend` |
| Models tab | `-snapshot_models_collection -load_sample_collection UI-Testing-Persistent` |
| Theme | `UI-Testing-LightTheme` or `UI-Testing-DarkTheme` |
| iPad collection auto-select | `UI-Testing` (capture script adds on iPad) |

## Framing tips

- **App Store:** use files from `raw/` only — Apple rejects device frames in upload slots.
- **Marketing:** use `framed/` for a polished look; prefer dark mode to match the app chrome.
- **Captions:** add short benefit text in Figma/Keynote above framed exports if desired.

## Manual capture (Xcode)

1. Edit scheme → Run → Arguments (see table above)
2. Run on **iPhone 17 Pro Max** or **iPad Pro 13-inch** simulator
3. Simulator → **File → Save Screen** (⌘S)
