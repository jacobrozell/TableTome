#!/usr/bin/env bash
# Capture App Store marketing screenshots from the iOS Simulator.
#
# Usage:
#   ./Scripts/capture-marketing-screenshots.sh              # dark, iPhone 17 Pro Max, portrait
#   APPEARANCE=light ./Scripts/capture-marketing-screenshots.sh
#   SIM_NAME="iPhone 17 Pro" ./Scripts/capture-marketing-screenshots.sh
#   ORIENTATIONS="portrait landscape" ./Scripts/capture-marketing-screenshots.sh
#
# Output: marketing-screenshots/raw/*.png
# Then run: ./Scripts/frame-marketing-screenshots.sh (optional bezels for web/social)
#
# App Store 6.5"/6.7" slot (default): 1284×2778 portrait after capture.
# Native iPhone 17 Pro Max (1320×2868) is rejected unless you upload to the 6.9" slot only.
# For 6.9" native: APP_STORE_RESIZE=0 SIM_NAME="iPhone 17 Pro Max"

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=app-store-screenshot-size.sh
source "$SCRIPT_DIR/app-store-screenshot-size.sh"
# shellcheck source=simulator-orientation.sh
source "$SCRIPT_DIR/simulator-orientation.sh"

SIM_NAME="${SIM_NAME:-iPhone 17 Pro Max}"
APPEARANCE="${APPEARANCE:-dark}"
ORIENTATIONS="${ORIENTATIONS:-portrait}"
OUT_DIR="${OUT_DIR:-$ROOT/marketing-screenshots/raw}"
BUNDLE_ID="com.jacobrozell.tabletome"
SCHEME="Tabletome"
PROJECT="$ROOT/Tabletome.xcodeproj"
DERIVED_DATA="${DERIVED_DATA:-$ROOT/.derivedData/marketing-screenshots}"
LAUNCH_DELAY="${LAUNCH_DELAY:-8}"
ORIENTATION_SETTLE_SEC="${ORIENTATION_SETTLE_SEC:-1.5}"
APP_STORE_RESIZE="${APP_STORE_RESIZE:-1}"

COMMON_ARGS=(-skip_onboarding -reset_user_defaults)

slugify() {
  echo "$1" | tr ' ' '-' | tr -d '()' | tr '[:upper:]' '[:lower:]'
}

theme_arg() {
  if [[ "$APPEARANCE" == "light" ]]; then
    echo "UI-Testing-LightTheme"
  else
    echo "UI-Testing-DarkTheme"
  fi
}

echo "→ Project: $ROOT"
echo "→ Simulator: $SIM_NAME ($APPEARANCE)"
echo "→ Orientations: $ORIENTATIONS"
echo "→ Output: $OUT_DIR"

if [[ ! -d "$PROJECT" ]]; then
  echo "→ Generating Xcode project…"
  (cd "$ROOT" && xcodegen generate)
fi

mkdir -p "$OUT_DIR"
CAPTURE_TMP="${TMPDIR:-/tmp}/tabletome-marketing-capture-$$"
mkdir -p "$CAPTURE_TMP"
trap 'rm -rf "$CAPTURE_TMP"' EXIT

SIM_UDID="$(xcrun simctl list devices available -j | python3 -c "
import json, sys
name = sys.argv[1]
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    if 'iOS' not in runtime:
        continue
    for d in devices:
        if d.get('name') == name and d.get('isAvailable', True):
            print(d['udid'])
            sys.exit(0)
sys.exit(1)
" "$SIM_NAME")"
export SIM_UDID

echo "→ Booting $SIM_NAME ($SIM_UDID)…"
xcrun simctl boot "$SIM_UDID" 2>/dev/null || true
xcrun simctl bootstatus "$SIM_UDID" -b
open -a Simulator --args -CurrentDeviceUDID "$SIM_UDID"
xcrun simctl ui "$SIM_UDID" appearance "$APPEARANCE"
xcrun simctl ui "$SIM_UDID" content_size large

echo "→ Building app…"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$SIM_UDID" \
  -derivedDataPath "$DERIVED_DATA" \
  build \
  | xcbeautify --quieter 2>/dev/null || xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$SIM_UDID" \
  -derivedDataPath "$DERIVED_DATA" \
  build

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/Tabletome.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Build succeeded but app not found at $APP_PATH" >&2
  exit 1
fi

echo "→ Installing app…"
xcrun simctl install "$SIM_UDID" "$APP_PATH"

app_store_resize_png_for_orientation() {
  local path="$1"
  local orientation="$2"
  local width="$APP_STORE_WIDTH"
  local height="$APP_STORE_HEIGHT"

  if [[ "$orientation" == "landscape" ]]; then
    width="$APP_STORE_HEIGHT"
    height="$APP_STORE_WIDTH"
  fi

  verify_screenshot_orientation "$path" "$orientation"

  local w h
  w="$(magick identify -format "%w" "$path")"
  h="$(magick identify -format "%h" "$path")"
  if [[ "$w" == "$width" && "$h" == "$height" ]]; then
    return 0
  fi
  magick "$path" -filter Lanczos -resize "${width}x${height}!" "$path"
}

capture() {
  local slug="$1"
  shift
  local -a args=("$@")

  for orientation in $ORIENTATIONS; do
    local suffix=""
    if [[ "$orientation" == "landscape" ]]; then
      suffix="-landscape"
    fi

    local filename="${DEVICE_SLUG}-${slug}-${APPEARANCE}${suffix}.png"
    capture_frame "$filename" "$orientation" "${args[@]}"
  done
}

capture_frame() {
  local filename="$1"
  local orientation="$2"
  shift 2
  local -a args=("$@")

  echo "→ Capturing ${filename} (${orientation})..."
  xcrun simctl terminate "$SIM_UDID" "$BUNDLE_ID" 2>/dev/null || true
  sleep 0.5
  xcrun simctl launch "$SIM_UDID" "$BUNDLE_ID" \
    "${args[@]}" >/dev/null
  sleep "$LAUNCH_DELAY"
  sleep "$ORIENTATION_SETTLE_SEC"
  local capture_path="$CAPTURE_TMP/$filename"
  xcrun simctl io "$SIM_UDID" screenshot "$capture_path"
  cp "$capture_path" "$OUT_DIR/$filename"
  normalize_screenshot_for_orientation "$OUT_DIR/$filename" "$orientation"
  verify_screenshot_orientation "$OUT_DIR/$filename" "$orientation"
  if [[ "$APP_STORE_RESIZE" == 1 ]]; then
    app_store_resize_png_for_orientation "$OUT_DIR/$filename" "$orientation"
  fi
}

DEVICE_SLUG="$(slugify "$SIM_NAME")"
THEME="$(theme_arg)"

# App Store priority order — see marketing-screenshots/README.md and docs/release/screenshot-script.md
capture "01-play-home" \
  "${COMMON_ARGS[@]}" -snapshot_play_home -snapshot_tab play "$(theme_arg)"

capture "02-spearhead-start-here" \
  "${COMMON_ARGS[@]}" -open_game_guide aos-spearhead -snapshot_tab play "$(theme_arg)"

capture "03-guided-match-armies" \
  "${COMMON_ARGS[@]}" -open_guided_match -snapshot_guided_match_armies -snapshot_tab play "$(theme_arg)"

capture "04-battle-combat" \
  "${COMMON_ARGS[@]}" -open_guided_match -open_battle_tracker -snapshot_battle_combat -snapshot_tab play "$(theme_arg)"

LAUNCH_DELAY="${UNIT_FOCUS_LAUNCH_DELAY:-12}" capture "05-unit-focus" \
  "${COMMON_ARGS[@]}" -open_guided_match -open_battle_tracker -snapshot_battle_combat -open_unit_focus -snapshot_tab play "$(theme_arg)"

capture "06-rules-search" \
  "${COMMON_ARGS[@]}" -open_rules_search rend -snapshot_tab rules "$(theme_arg)"

capture "07-wh40k-guide" \
  "${COMMON_ARGS[@]}" -open_game_guide wh40k-11e -snapshot_tab play "$(theme_arg)"

capture "08-models-collection" \
  "${COMMON_ARGS[@]}" -snapshot_models_collection -load_sample_collection -snapshot_tab models \
  -onboarding_choice aos-spearhead UI-Testing-Persistent "$(theme_arg)" \
  $([[ "$SIM_NAME" == *iPad* ]] && echo UI-Testing)

echo ""
first_png="$(ls -1 "$OUT_DIR"/*.png | head -1)"
echo "Done. Raw screenshots ($(magick identify -format '%wx%h' "$first_png")):"
ls -1 "$OUT_DIR"/*.png
if [[ "$APP_STORE_RESIZE" == 1 ]]; then
  echo "App Store export (portrait): ${APP_STORE_WIDTH}×${APP_STORE_HEIGHT}"
  echo "App Store export (landscape): ${APP_STORE_HEIGHT}×${APP_STORE_WIDTH}"
fi
echo ""
echo "Next (optional): ./Scripts/frame-marketing-screenshots.sh"
