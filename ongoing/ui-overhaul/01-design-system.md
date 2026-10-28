# 01: Design system foundation ("Tome & Table")

Back to [index](README.md). **Every screen WP depends on this file.** Finish DS-01 through DS-10 before touching screens.

New code lives in **two new folders**:

```
DesignSystem/Theme/        ← tokens: TTColor, TTFont, TTMotion, TTHaptics, TTIcon, (DesignTokens stays where it is)
DesignSystem/Components/   ← new reusable views: TTBadge, TTRow, TTCounter, …
```

XcodeGen picks up new folders automatically if `project.yml` lists `DesignSystem` as a source path (it does: the `Tabletome` target sources include `DesignSystem`). Run `xcodegen generate` after adding files anyway.

Naming: every new public token or component is prefixed **`TT`** (Tabletome) so it is easy to grep and never collides with SwiftUI names.

---

## DS-01: Theme colors (`TTColor`)

**Goal:** One semantic color API with hand-tuned light and dark values, all text tokens ≥ 4.5:1 contrast on canvas, surface, and raised.
**Depends on:** none
**Files:** new `DesignSystem/Theme/TTColor.swift`; edit `Resources/Assets.xcassets/AccentColor.colorset/Contents.json`, `Resources/Assets.xcassets/AccentOnSurface.colorset/Contents.json`; edit `.gitignore`.

### 1.1 Palette (verified contrast ratios)

Ratios were computed with the WCAG relative-luminance formula. "≥" columns are the **lowest** ratio against canvas / surface / raised.

| Token | Role | Light | Dark | Min text contrast (L / D) |
|-------|------|-------|------|---------------------------|
| `canvas` | Page background | `#F6F1E7` | `#0E131D` | — |
| `surface` | Cards, list rows | `#FFFDF8` | `#161D2B` | — |
| `raised` | Interactive tiles, sheets, popovers | `#FFFFFF` | `#1E2738` | — |
| `sunken` | Wells: input fields, progress tracks, segmented background | `#ECE5D6` | `#0A0E15` | non-text only |
| `stroke` | Hairlines, dividers (0.5–1 pt) | `#DDD3C1` | `#2A3346` | — |
| `strokeStrong` | Focus rings, selected outlines | `#BFB29A` | `#3D4862` | — |
| `inkPrimary` | Titles, body | `#1C1A16` | `#F2ECE0` | 15.4 / 12.7 |
| `inkSecondary` | Subtitles, captions | `#5A554B` | `#B9B2A4` | 6.6 / 7.1 |
| `inkTertiary` | Metadata, placeholders, disabled | `#69645A` | `#9A9486` | 5.2 / 5.0 |
| `brand` | Copper text / icons / links | `#9E4B18` | `#E8935A` | 5.4 / 6.2 |
| `brandFill` | Primary button fill, selected phase, active tab tint | `#B85C24` | `#E8935A` | — |
| `inkOnBrand` | Text on `brandFill` | `#FFFFFF` | `#1A0E06` | 4.6 / 7.9 |
| `brandSoft` | Tinted background behind brand content | `#B85C24` @ 10% | `#E8935A` @ 16% | — |
| `parchment` | Decorative only (crest glow, hero gradients) | `#F3E6C9` | `#F3E6C9` | — |
| `playerOne` | Player 1 identity (Azure) | `#1E62A8` | `#62AEF5` | 5.5 / 6.3 |
| `playerOneSoft` | Player 1 tinted background | `#1E62A8` @ 10% | `#62AEF5` @ 16% | — |
| `playerTwo` | Player 2 identity (Gold) | `#7D5F00` | `#F2C14E` | 5.3 / 8.9 |
| `playerTwoSoft` | Player 2 tinted background | `#7D5F00` @ 10% | `#F2C14E` @ 16% | — |
| `inkOnPlayer` | Text on a solid player fill | `#FFFFFF` | `#0E131D` | 5.9+ / 7.8+ |
| `success` | Complete, healthy | `#176B42` | `#4CC38A` | 5.8 / 6.8 |
| `warning` | Abandoned, caution | `#A35200` | `#F59E42` | 5.0 / 7.0 |
| `danger` | Destroyed, destructive | `#B42318` | `#F06A5F` | 5.8 / 4.9 |
| `successSoft` / `warningSoft` / `dangerSoft` | Tinted backgrounds | base @ 10% | base @ 16% | — |
| `scrim` | Behind interstitials | `#000000` @ 35% | `#000000` @ 55% | — |

Rules:
- Text never sits on `sunken` except `inkPrimary` / `inkSecondary`.
- Never put `inkOnBrand` on anything except `brandFill`.
- Player colors are **identity**, not status. Never use `playerOne` to mean "info" or `playerTwo` to mean "warning".

### 1.2 Implementation

Create `DesignSystem/Theme/TTColor.swift`:

```swift
import SwiftUI
import UIKit

/// Semantic color tokens for the "Tome & Table" theme.
/// Light/dark values are tuned for ≥ 4.5:1 text contrast. See ongoing/ui-overhaul/01-design-system.md §DS-01.
public enum TTColor {
    // MARK: Surfaces
    public static let canvas = dynamic(light: 0xF6F1E7, dark: 0x0E131D)
    public static let surface = dynamic(light: 0xFFFDF8, dark: 0x161D2B)
    public static let raised = dynamic(light: 0xFFFFFF, dark: 0x1E2738)
    public static let sunken = dynamic(light: 0xECE5D6, dark: 0x0A0E15)
    public static let stroke = dynamic(light: 0xDDD3C1, dark: 0x2A3346, highContrastLight: 0xA89C86, highContrastDark: 0x56617C)
    public static let strokeStrong = dynamic(light: 0xBFB29A, dark: 0x3D4862)
    public static let scrim = dynamic(light: 0x000000, dark: 0x000000, lightAlpha: 0.35, darkAlpha: 0.55)

    // MARK: Ink
    public static let inkPrimary = dynamic(light: 0x1C1A16, dark: 0xF2ECE0)
    public static let inkSecondary = dynamic(light: 0x5A554B, dark: 0xB9B2A4, highContrastLight: 0x3F3B34, highContrastDark: 0xD6D0C3)
    public static let inkTertiary = dynamic(light: 0x69645A, dark: 0x9A9486)

    // MARK: Brand
    public static let brand = dynamic(light: 0x9E4B18, dark: 0xE8935A)
    public static let brandFill = dynamic(light: 0xB85C24, dark: 0xE8935A)
    public static let inkOnBrand = dynamic(light: 0xFFFFFF, dark: 0x1A0E06)
    public static let brandSoft = dynamic(light: 0xB85C24, dark: 0xE8935A, lightAlpha: 0.10, darkAlpha: 0.16)
    public static let parchment = dynamic(light: 0xF3E6C9, dark: 0xF3E6C9)

    // MARK: Players
    public static let playerOne = dynamic(light: 0x1E62A8, dark: 0x62AEF5)
    public static let playerOneSoft = dynamic(light: 0x1E62A8, dark: 0x62AEF5, lightAlpha: 0.10, darkAlpha: 0.16)
    public static let playerTwo = dynamic(light: 0x7D5F00, dark: 0xF2C14E)
    public static let playerTwoSoft = dynamic(light: 0x7D5F00, dark: 0xF2C14E, lightAlpha: 0.10, darkAlpha: 0.16)
    public static let inkOnPlayer = dynamic(light: 0xFFFFFF, dark: 0x0E131D)

    // MARK: Status
    public static let success = dynamic(light: 0x176B42, dark: 0x4CC38A)
    public static let warning = dynamic(light: 0xA35200, dark: 0xF59E42)
    public static let danger = dynamic(light: 0xB42318, dark: 0xF06A5F)
    public static let successSoft = dynamic(light: 0x176B42, dark: 0x4CC38A, lightAlpha: 0.10, darkAlpha: 0.16)
    public static let warningSoft = dynamic(light: 0xA35200, dark: 0xF59E42, lightAlpha: 0.10, darkAlpha: 0.16)
    public static let dangerSoft = dynamic(light: 0xB42318, dark: 0xF06A5F, lightAlpha: 0.10, darkAlpha: 0.16)

    /// Player identity color. `isPlayerOne == true` → Azure, else Gold.
    public static func player(_ isPlayerOne: Bool) -> Color { isPlayerOne ? playerOne : playerTwo }
    public static func playerSoft(_ isPlayerOne: Bool) -> Color { isPlayerOne ? playerOneSoft : playerTwoSoft }

    // MARK: Helpers
    private static func dynamic(
        light: UInt32,
        dark: UInt32,
        lightAlpha: CGFloat = 1,
        darkAlpha: CGFloat = 1,
        highContrastLight: UInt32? = nil,
        highContrastDark: UInt32? = nil
    ) -> Color {
        Color(UIColor { traits in
            let isDark = traits.userInterfaceStyle == .dark
            let isHighContrast = traits.accessibilityContrast == .high
            let hex: UInt32
            if isDark {
                hex = (isHighContrast ? highContrastDark : nil) ?? dark
            } else {
                hex = (isHighContrast ? highContrastLight : nil) ?? light
            }
            return UIColor(ttHex: hex, alpha: isDark ? darkAlpha : lightAlpha)
        })
    }
}

extension UIColor {
    convenience init(ttHex hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
```

> Note: `DesignSystem/Hobby/Color+Hex.swift` already defines `Color(hex:)` for strings. Do **not** reuse or rename it here. `UIColor(ttHex:)` is deliberately distinct.

### 1.3 Asset catalog accent

System controls (Toggle, links, `.tint`) read `AccentColor`. Update them to match `brandFill`:

- `AccentColor.colorset/Contents.json`: universal (light) `red 0.722 green 0.361 blue 0.141` (= `#B85C24`); dark appearance `red 0.910 green 0.576 blue 0.353` (= `#E8935A`).
- `AccentOnSurface.colorset/Contents.json`: light `#9E4B18` (`0.620, 0.294, 0.094`); dark `#E8935A`.

Edit only the `components` numbers. Keep the JSON structure identical.

### 1.4 Bridge the old API

`Color.accentOnSurface` (in `DesignSystem/BrandColors.swift`) is used about 200 times. **Do not mass-replace now.** Re-point it:

```swift
extension Color {
    /// Legacy alias. Prefer `TTColor.brand` in new code.
    static var accentOnSurface: Color { TTColor.brand }
}
```

### 1.5 `.gitignore`

Add the line `marketing-screenshots/overhaul/`.

### Acceptance (DS-01)
- [x] `TTColor.swift` compiles. Gallery preview of every token is DS-08 (`TTColorGallery`), still open.
- [ ] Accent assets updated. A system `Toggle` in Settings shows copper in both modes. (Assets updated to `brandFill`; not screenshotted.)
- [x] No existing call site changed except `accentOnSurface`'s implementation.

---

## DS-02: Typography (`TTFont`)

**Goal:** A small named scale, all built on Dynamic Type text styles so they scale.
**Depends on:** DS-01
**File:** new `DesignSystem/Theme/TTFont.swift`

| Token | Definition | Use |
|-------|-----------|-----|
| `display` | `.system(.largeTitle, design: .serif).weight(.bold)` | Hero titles (onboarding, victory, empty states) |
| `title` | `.system(.title2, design: .serif).weight(.semibold)` | Card hero titles, sheet titles, screen section heroes |
| `titleSmall` | `.system(.title3, design: .serif).weight(.semibold)` | Unit names on warscroll header, step titles |
| `headline` | `.headline` | Row titles, card titles |
| `body` | `.body` | Paragraphs |
| `bodyEmphasis` | `.body.weight(.semibold)` | Inline emphasis |
| `callout` | `.callout` | Secondary paragraphs, instructions |
| `subheadline` | `.subheadline` | Row subtitles |
| `footnote` | `.footnote` | Help text under controls |
| `caption` | `.caption` | Metadata |
| `eyebrow` | `.caption.weight(.semibold)` + `.textCase(.uppercase)` + `.tracking(0.8)` | Section labels above cards ("THIS PHASE", "PLAYER 1") |
| `numericHero` | `.system(.largeTitle, design: .rounded).weight(.bold).monospacedDigit()` | Scoreboard VP, victory scores |
| `numericLarge` | `.system(.title, design: .rounded).weight(.bold).monospacedDigit()` | Wounds counter, dice totals |
| `numericMedium` | `.system(.title3, design: .rounded).weight(.semibold).monospacedDigit()` | Stat tiles (Move/Save…) |
| `numericSmall` | `.system(.subheadline, design: .rounded).weight(.semibold).monospacedDigit()` | Inline counts, badges |
| `button` | `.headline` | Primary/secondary buttons |
| `buttonSmall` | `.subheadline.weight(.semibold)` | Compact buttons, chips |

```swift
import SwiftUI

public enum TTFont {
    public static let display = Font.system(.largeTitle, design: .serif).weight(.bold)
    public static let title = Font.system(.title2, design: .serif).weight(.semibold)
    public static let titleSmall = Font.system(.title3, design: .serif).weight(.semibold)
    public static let headline = Font.headline
    public static let body = Font.body
    public static let bodyEmphasis = Font.body.weight(.semibold)
    public static let callout = Font.callout
    public static let subheadline = Font.subheadline
    public static let footnote = Font.footnote
    public static let caption = Font.caption
    public static let numericHero = Font.system(.largeTitle, design: .rounded).weight(.bold).monospacedDigit()
    public static let numericLarge = Font.system(.title, design: .rounded).weight(.bold).monospacedDigit()
    public static let numericMedium = Font.system(.title3, design: .rounded).weight(.semibold).monospacedDigit()
    public static let numericSmall = Font.system(.subheadline, design: .rounded).weight(.semibold).monospacedDigit()
    public static let button = Font.headline
    public static let buttonSmall = Font.subheadline.weight(.semibold)
}

public extension View {
    /// Small uppercase label above a card or group ("THIS PHASE").
    func ttEyebrow(_ color: Color = TTColor.inkSecondary) -> some View {
        font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .tracking(0.8)
            .foregroundStyle(color)
    }
}
```

Rules:
- Serif is for **titles only**, never body or buttons.
- Paragraph line length: wrap prose in `.readableContentWidth()` (exists) on iPad.
- Multi-line body text gets `.lineSpacing(2)` in rules detail and guide steps only (RR-02, GG-02).

### Acceptance (DS-02)
- [x] `TTFont.swift` compiles. `TTTypeGallery` preview (DS-08) is still open.

---

## DS-03: Spacing, radius, elevation

**Goal:** Extend the existing `DesignTokens` (do **not** rename it; it's used everywhere).
**Depends on:** DS-01
**File:** edit `DesignSystem/DesignTokens.swift`; new `DesignSystem/Theme/TTElevation.swift`

Add to `DesignTokens.Spacing`: `xxs = 2`, `xxl = 48`. Keep `xs 4, sm 8, md 16, lg 24, xl 32` unchanged.
Add a new `DesignTokens.Spacing.cardInner = 14`, padding inside dense cards such as ability rows. It is the only sanctioned non-4pt value.
Add to `DesignTokens.Radius`: `xs = 6` (badges, stat tiles), `xl = 24` (hero cards, sheets), `pill = 999`.
Add `DesignTokens.Size`: `iconTile = 36`, `iconTileLarge = 48`, `playerToken = 28`, `actionBarHeight = 64`, `scoreboardHeight = 64`, `phaseRailHeight = 44`.

`TTElevation.swift`:

```swift
import SwiftUI

public enum TTElevation {
    case flat      // canvas
    case card      // surface
    case raised    // raised tiles, sheets, action bar

    var shadowColor: Color { .black.opacity(self == .flat ? 0 : (self == .card ? 0.05 : 0.10)) }
    var shadowRadius: CGFloat { self == .flat ? 0 : (self == .card ? 6 : 14) }
    var shadowY: CGFloat { self == .flat ? 0 : (self == .card ? 2 : 6) }
}

public extension View {
    /// Light mode gets a soft shadow; dark mode relies on surface tone + stroke (shadows are invisible on navy).
    func ttElevation(_ level: TTElevation) -> some View {
        modifier(TTElevationModifier(level: level))
    }
}

private struct TTElevationModifier: ViewModifier {
    let level: TTElevation
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.shadow(
            color: colorScheme == .dark ? .clear : level.shadowColor,
            radius: level.shadowRadius,
            y: level.shadowY
        )
    }
}
```

### Acceptance (DS-03)
- [ ] New tokens compile. No existing token value changed.

---

## DS-04: Re-skin the existing surface modifiers (biggest visual win, lowest risk)

**Goal:** About 90 call sites of `surfaceCard()` / `accentHighlightCard()` / `onboardingPickerRow()` / `ProgressBadge` / `SectionHeader` / `IntroCallout` / `TipsCard` / `DamageSummaryCard` / `ReferenceLinkRow` restyle automatically by changing their **implementations only**.
**Depends on:** DS-01, DS-02, DS-03
**File:** edit `DesignSystem/SurfaceCard.swift` (and `DesignSystem/ReadableContentWidth.swift` for `barChromeBackground`)

### Steps

1. `SurfaceCardModifier.body`: fill → `TTColor.surface`; stroke → `TTColor.stroke` at `lineWidth: 1` (was 0.5 @ 50%); add `.ttElevation(.card)` **outside** the `clipShape` (shadows are clipped otherwise). The order must be: `.padding → .frame → .background { fill; stroke } → .clipShape → .ttElevation`.
2. `accentHighlightCard`: fill → `TTColor.brandSoft`; stroke → `TTColor.brand.opacity(0.35)` at 1 pt; no shadow. **Also** add an optional parameter `tone: TTTone = .brand` (enum defined in DS-07 `TTBadge.swift`, so stub it here and move it later, or define `TTTone` in `DesignSystem/Theme/TTTone.swift` now: `brand, playerOne, playerTwo, success, warning, danger, neutral`, with `foreground`, `fill`, `soft` computed colors). Prefer creating `TTTone.swift` now.
3. `onboardingPickerRow`: fill → `TTColor.raised`; stroke → `TTColor.stroke`; `.ttElevation(.card)`.
4. `ProgressBadge`: complete → `TTColor.successSoft` bg + `TTColor.success` text; incomplete → `TTColor.sunken` bg + `TTColor.inkSecondary`.
5. `SectionHeader`: becomes the eyebrow style: `Text(title).ttEyebrow()` with optional icon in `TTColor.inkTertiary`. Keep the `.isHeader` trait.
6. `IntroCallout`: `TTColor.inkSecondary` text, icon `TTColor.brand`.
7. `TipsCard`: replace yellow with `TTTone.warning.soft` fill and `TTColor.warning` icon. Title via `SectionHeader`.
8. `DamageSummaryCard`: orange → `TTColor.danger` (bolt) / `TTColor.success` (shield). Damage number uses `TTFont.numericLarge`.
9. `ReferenceLinkRow`: chevron `TTColor.inkTertiary`, title `TTColor.inkPrimary`, icon `TTColor.brand`.
10. `MatchupVersusBadge`: `TTColor.sunken` capsule, text `TTColor.inkSecondary`, `TTFont.eyebrow` style.
11. `barChromeBackground(...)` in `ReadableContentWidth.swift`: if it uses `.bar`, keep `.bar` on iOS 26 (glass). On iOS < 26 use `TTColor.surface.opacity(0.92)` + bottom 1 pt `TTColor.stroke` divider. Wrap in `if #available(iOS 26.0, *)`.

### Acceptance (DS-04)
- [ ] Before/after screenshots of Play home, Spearhead guide, battle tracker Turn tab, Rules section detail show the new surfaces with no layout shift > 2 pt.
- [ ] `hardcoded_colors` count drops (yellow/orange/green in this file removed).

---

## DS-05: Buttons

**Goal:** Four button styles that replace `.borderedProminent` / `.bordered` across the app, fixing the dark-mode contrast failure (finding A15).
**Depends on:** DS-01..03
**Files:** new `DesignSystem/Components/TTButtonStyles.swift`; edit `DesignSystem/PrimaryButton.swift`, `DesignSystem/BrandColors.swift`

| Style | Look | Use |
|-------|------|-----|
| `.ttPrimary` | `brandFill` capsule-ish (radius `md` 12), `inkOnBrand` label, `TTFont.button`, min height 52 (50 at compact height), full width by default | The one action that moves the user forward |
| `.ttSecondary` | `raised` fill, 1 pt `strokeStrong` border, `inkPrimary` label | Alternative actions ("Use Starter Matchup", "Adjust score") |
| `.ttTertiary` | No fill, `brand` label, `TTFont.buttonSmall` | Inline links ("Read full step", "Rules") |
| `.ttDestructive` | `dangerSoft` fill, `danger` label | Reset, delete (always followed by a confirmation dialog) |
| `.ttPlayer(isPlayerOne:)` | `TTColor.player(_)` fill, `inkOnPlayer` label | Player-specific choices ("Azure goes first") |

Behaviors for all styles:
- Pressed: scale `0.97` + opacity `0.9` via `TTMotion.press` (DS-06). No scale if Reduce Motion.
- Disabled: `opacity(0.4)`, no shadow.
- Minimum touch target 44 pt (heights above exceed it).
- `controlSize(.small)` → height 36, `TTFont.buttonSmall`, still ≥ 44 pt hit area via `.contentShape` + padding.

Reference implementation:

```swift
import SwiftUI

public struct TTPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.controlSize) private var controlSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var fullWidth: Bool = true

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(controlSize == .small ? TTFont.buttonSmall : TTFont.button)
            .foregroundStyle(TTColor.inkOnBrand)
            .symbolRenderingMode(.monochrome)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(minHeight: height)
            .background(TTColor.brandFill, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
            .opacity(isEnabled ? (configuration.isPressed ? 0.9 : 1) : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(TTMotion.press(reduceMotion: reduceMotion), value: configuration.isPressed)
            .contentShape(Rectangle())
    }

    private var height: CGFloat {
        if controlSize == .small { return 36 }
        return verticalSizeClass == .compact ? 50 : 52
    }
}

public extension ButtonStyle where Self == TTPrimaryButtonStyle {
    static var ttPrimary: TTPrimaryButtonStyle { TTPrimaryButtonStyle() }
    static var ttPrimaryInline: TTPrimaryButtonStyle { TTPrimaryButtonStyle(fullWidth: false) }
}
// Repeat the pattern for TTSecondaryButtonStyle, TTTertiaryButtonStyle, TTDestructiveButtonStyle, TTPlayerButtonStyle.
```

### Steps
1. Create the five styles in `TTButtonStyles.swift` with static accessors `.ttPrimary`, `.ttPrimaryInline`, `.ttSecondary`, `.ttTertiary`, `.ttDestructive`, `.ttPlayer(isPlayerOne:)`.
2. `PrimaryButton.swift`: replace `.buttonStyle(.borderedProminent)` with `.buttonStyle(.ttPrimary)`. Remove the inner `.frame(maxWidth: .infinity, minHeight:)` (the style handles it).
3. `BrandColors.swift` `prominentButtonLabelStyle()`: change `.foregroundStyle(.white)` → `.foregroundStyle(TTColor.inkOnBrand)` so any remaining `.borderedProminent` usage is at least readable.
4. **Do not** mass-replace the 46 `.borderedProminent` usages in this WP. Each screen WP replaces the ones in its files. QA-03 catches leftovers.

### Acceptance (DS-05)
- [ ] Gallery shows all styles: normal, pressed, disabled, small, light/dark, AX3.
- [ ] Dark mode primary button label contrast ≥ 4.5:1 (it's 7.9:1 by construction).

---

## DS-06: Motion and haptics

**Files:** new `DesignSystem/Theme/TTMotion.swift`, `DesignSystem/Theme/TTHaptics.swift`

```swift
import SwiftUI

public enum TTMotion {
    /// Standard UI state change (expand, select).
    public static func standard(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .snappy(duration: 0.25)
    }
    /// Button press feedback.
    public static func press(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .easeOut(duration: 0.12)
    }
    /// Big moments: phase change, round start, victory.
    public static func emphasis(reduceMotion: Bool) -> Animation? {
        reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.45, dampingFraction: 0.82)
    }
    /// Numeric changes (VP, wounds). Pair with `.contentTransition(.numericText(value:))`.
    public static let numeric: Animation = .snappy(duration: 0.2)
}
```

`TTHaptics` wraps `.sensoryFeedback` triggers so call sites stay declarative:

| Event | Feedback |
|-------|----------|
| Phase advanced | `.selection` |
| VP +/− | `.increase` / `.decrease` |
| Wound applied | `.impact(weight: .light)` |
| Unit destroyed | `.impact(weight: .heavy)` |
| Turn handoff / round start | `.success` |
| Destructive confirm | `.warning` |
| Victory | `.success` |

```swift
import SwiftUI

public enum TTHapticEvent: Equatable {
    case phaseAdvanced, scoreUp, scoreDown, wound, unitDestroyed, handoff, warning, victory

    var feedback: SensoryFeedback {
        switch self {
        case .phaseAdvanced: .selection
        case .scoreUp: .increase
        case .scoreDown: .decrease
        case .wound: .impact(weight: .light)
        case .unitDestroyed: .impact(weight: .heavy)
        case .handoff, .victory: .success
        case .warning: .warning
        }
    }
}

public extension View {
    /// Fires `event` each time `trigger` changes.
    func ttHaptic<T: Equatable>(_ event: TTHapticEvent, trigger: T) -> some View {
        sensoryFeedback(event.feedback, trigger: trigger)
    }
}
```

### Acceptance (DS-06)
- [ ] Files compile. Used first in DS-07 `TTCounter`.

---

## DS-07: Core components

**Depends on:** DS-04, DS-05, DS-06
**Folder:** `DesignSystem/Components/` (one file per component unless noted)

Each component below lists: **API**, **Look**, **Accessibility**, **Replaces**. Build them exactly to the API so screen WPs can rely on it. Every component gets a `#Preview` using `TTPreviewMatrix` (DS-08).

### 7.1 `TTTone` (`DesignSystem/Theme/TTTone.swift`, may already exist from DS-04)

```swift
public enum TTTone: Equatable, Sendable {
    case neutral, brand, playerOne, playerTwo, success, warning, danger
    public var foreground: Color { … }   // neutral → inkSecondary, brand → brand, playerOne → playerOne, …
    public var soft: Color { … }         // neutral → sunken, brand → brandSoft, …
    public var solid: Color { … }        // neutral → inkTertiary, brand → brandFill, playerOne → playerOne, …
    public var onSolid: Color { … }      // brand → inkOnBrand, player* → inkOnPlayer, others → .white (light) / canvas (dark) via TTColor.inkOnPlayer
    public static func player(_ isPlayerOne: Bool) -> TTTone { isPlayerOne ? .playerOne : .playerTwo }
}
```

### 7.2 `TTBadge`

- **API:** `TTBadge(_ text: String, tone: TTTone = .neutral, style: .soft | .solid | .outline = .soft, systemImage: String? = nil)`
- **Look:** capsule, horizontal padding 8, vertical 3, `TTFont.caption.weight(.semibold)`; `.soft` = `tone.soft` bg + `tone.foreground` text; `.solid` = `tone.solid` bg + `tone.onSolid`; `.outline` = 1 pt `tone.foreground` stroke.
- **A11y:** `.accessibilityElement(children: .combine)`; label = text.
- **Replaces:** inline capsules for "Active", "Destroyed", "Suggested", "Attacker", "Winner", "Abandoned", "Draw", "custom pipeline", `ProgressBadge` (keeps its own type but uses `TTBadge` internally), `GuideBadge` (re-implement `GuideBadge.body` with `TTBadge`), `NewEditionBadge`.
- Canonical mappings (use these exact tones everywhere):

| Meaning | Text | Tone / style |
|---------|------|--------------|
| Active player | "Active" | `.player(isOne)` / `.solid` |
| Attacker / Defender | "Attacker" / "Defender" | `.neutral` / `.outline` |
| Destroyed | "Destroyed" | `.danger` / `.soft` |
| Suggested | "Suggested" | `.brand` / `.soft` |
| Winner | "Winner" | `.brand` / `.solid` with `crown.fill` |
| Draw | "Draw" | `.neutral` / `.soft` |
| Abandoned | "Abandoned" | `.warning` / `.soft` |
| Once per battle | "Once per battle" | `.neutral` / `.outline` |
| Used | "Used" | `.neutral` / `.soft` with `checkmark` |
| Underdog | "Underdog" | `.warning` / `.soft` with `arrow.down.circle.fill` |

### 7.3 `TTSectionHeader`

- **API:** `TTSectionHeader(_ title: String, systemImage: String? = nil, trailing: (() -> some View)? = nil)`
- **Look:** eyebrow text (DS-02), optional trailing accessory (e.g. "See all" `.ttTertiary` button). Padding: top 8, bottom 4.
- **Use in `List`:** pass as the `header:` of a `Section`, combined with `.textCase(nil)` on the section so SwiftUI doesn't double-uppercase.
- Existing `SectionHeader` becomes a thin wrapper (DS-04 step 5).

### 7.4 `TTIconTile`

- **API:** `TTIconTile(systemImage: String, tone: TTTone = .brand, size: CGFloat = DesignTokens.Size.iconTile)`
- **Look:** rounded square (radius `sm` 8), `tone.soft` fill, symbol in `tone.foreground` at `size * 0.5`, `.symbolRenderingMode(.hierarchical)`. `@ScaledMetric` for size.
- **A11y:** hidden (decorative).
- **Replaces:** the bare 44 pt SF Symbol glyphs in Home rows, `BoxProductThumbnail`, Settings rows, guide rows.

### 7.5 `TTRow` (list row content)

- **API:**
  ```swift
  TTRow(
      title: String,
      subtitle: String? = nil,
      systemImage: String? = nil,          // shown as TTIconTile
      tone: TTTone = .brand,
      badge: TTBadge? = nil,               // shown after title
      accessory: TTRowAccessory = .chevron // .chevron | .none | .check(Bool) | .value(String) | .external
  )
  ```
- **Look:** HStack(spacing 12): icon tile, VStack(title `TTFont.headline` inkPrimary, subtitle `TTFont.subheadline` inkSecondary, max 2 lines), Spacer, accessory. Min height 56. At `needsLayoutAdaptation`, the icon tile moves above the text.
- **Note:** `NavigationLink` adds its own chevron inside `List`. When a `TTRow` is a `NavigationLink` label inside a `List`, use `accessory: .none` **or** hide the system indicator with `.navigationLinkIndicatorVisibility(.hidden)` (already used in `RulesReferenceView` and `CollectionHomeView`, so copy that call exactly). Pick the latter so chevrons are consistent.
- **Replaces:** `gameSystemRow` in `HomeView`, `guideRow` in `GameSystemDetailView`, Settings rows, `ReferenceLinkRow` (keep the type; make it call `TTRow`).

### 7.6 `TTCard` container (optional sugar)

- **API:** `TTCard(tone: TTTone? = nil, padding: CGFloat = DesignTokens.Spacing.md) { content }`. `nil` tone = `surfaceCard()`, non-nil = `accentHighlightCard(tone:)`.
- **Also:** `TTHeroCard(title:subtitle:systemImage:tone:) { actions }` for Play home and guide hubs: radius `xl` 24, `surface` fill, 1 pt stroke, top-trailing decorative crest line-art (`BrandCrest` at 15% opacity, 120 pt, `.accessibilityHidden(true)`), title in `TTFont.title`.

### 7.7 `TTCounter` (the table-friendly stepper)

- **API:**
  ```swift
  TTCounter(
      value: Binding<Int>,
      range: ClosedRange<Int>,
      label: String,                 // VoiceOver label, e.g. "Azure victory points"
      tone: TTTone = .brand,
      size: .regular | .large = .regular,
      valueFormatter: (Int) -> String = { "\($0)" },
      onStep: ((Int) -> Void)? = nil // delta callback (+1 / -1) for analytics & haptics
  )
  ```
- **Look:** `[ − ]  7  [ + ]`. Buttons are 44 pt (`.regular`) or 56 pt (`.large`) circles with `tone.soft` fill and `tone.foreground` glyph (`minus` / `plus`, weight semibold). Value in `TTFont.numericLarge` (`.regular`) or `TTFont.numericHero` (`.large`), `.contentTransition(.numericText(value:))`, animated with `TTMotion.numeric`. Minus is disabled at `range.lowerBound`, plus at `range.upperBound`.
- **Gestures:** long-press on +/− repeats every 0.15 s after 0.4 s hold (use a `Timer` in a `@State` task, cancelled on release).
- **Haptics:** `.ttHaptic(.scoreUp/.scoreDown)` on change.
- **A11y:** the whole control is one element with `.accessibilityRepresentation { Stepper(label, value: value, in: range) }` so VoiceOver swipe up/down adjusts it. `accessibilityValue` = formatted value. Identifier passed by caller via `.accessibilityIdentifier` on the counter. Keep the existing ids (e.g. `battleTracker.vp.playerOne`).
- **Replaces:** `Stepper` in `VictoryPointsCard`, `UnitWoundTrackerRow`, `ArmyTrackerCard`, `UnitFocusSheet.woundsSection`, `BattleTrackerPinnedWarscrollPanel`.

### 7.8 `TTStatStrip` (warscroll characteristics)

- **API:** `TTStatStrip(stats: [TTStat])` where `struct TTStat { let label: String; let value: String; var isModified: Bool = false }`.
- **Look:** row of equal-width tiles (radius `xs` 6, `sunken` fill), value `TTFont.numericMedium` inkPrimary (brand color + small `*` if modified), label `TTFont.caption` inkSecondary uppercase. Max 4 per row; wraps to 2×2 at `needsLayoutAdaptation`.
- **A11y:** each tile `.accessibilityElement(children: .combine)` label "Move 5 inches" etc. (callers pass a11y-friendly label text if needed).
- **Used by:** UF-01, GG-04 for Move / Save / Health / Control. The source fields are `SpearheadUnit.move`, `.save`, `.health`, `.control`.

### 7.9 `TTWeaponTable`

- **API:** `TTWeaponTable(weapons: [SpearheadWeapon], highlightedWeaponId: String? = nil, onResolve: ((SpearheadWeapon) -> Void)? = nil)`
- **Look:** a `Grid` (iOS 16+) with header row eyebrow labels **Rng · Atk · Hit · Wnd · Rnd · Dmg**. Weapon name spans the full row above its stats (name `TTFont.headline`; weapon ability text below in `TTFont.footnote` inkSecondary). Melee weapons (`rangeInches == nil || rangeInches == 0`) show Rng "—" and a small `TTBadge("Melee")`. Hit/Wound show `"\(n)+"`. Rend 0 shows "—". Highlighted row gets `brandSoft` background. If `onResolve` is non-nil, a trailing `.ttTertiary` "Resolve" button with `dice.fill` per weapon (min 44 pt).
- **Data:** use `SpearheadWeapon` fields from JSON: `name`, `rangeInches`, `attacks`, `hit`, `wound`, `rend`, `damage`, `ability` (check exact property names with `rg "struct SpearheadWeapon" -A30 Domain`).
- **At AX sizes:** switch from grid to a stacked card per weapon with `LabeledContent` rows.
- **A11y:** each weapon is one element: "Distended Maw, melee, 3 attacks, hit 4 plus, wound 3 plus, rend 1, damage 2".
- **Replaces:** `WarscrollStatSummary.weaponCombatProfile` text lines in `UnitFocusSheet.weaponRow`, `UnitWarscrollCard.weaponsSection`, `WarscrollSheetView`.

### 7.10 `TTProgressBar`

- **API:** `TTProgressBar(fraction: Double, tone: TTTone, height: CGFloat = 6)`. Track `sunken`, fill `tone.solid`; when `fraction <= 0.35 && fraction > 0` the fill becomes `danger` (caller can opt out with `criticalThreshold: nil`). Animated with `TTMotion.standard`.
- **Replaces:** `ArmyHealthProgressBar`. Keep the type name and re-implement it via `TTProgressBar` so call sites don't change.

### 7.11 `TTNotice` (inline) + `TTToast` (transient)

- **`TTNotice` API:** `TTNotice(title: String, message: String? = nil, systemImage: String, tone: TTTone = .brand, action: (title: String, run: () -> Void)? = nil, onDismiss: (() -> Void)? = nil)`. Look: `accentHighlightCard(tone:)`, icon left, title `TTFont.headline`, message `TTFont.callout` inkSecondary (≤ 2 lines, `lineLimit(3)`), optional `.ttTertiary` action, optional `xmark` dismiss (44 pt). Use this for **every** coach/banner type (see BT-11 and SH-04).
- **`TTToast`:** see SH-04 (host + queue). Look: capsule `raised` with `ttElevation(.raised)`, icon + one line + optional "Undo" `.ttTertiary`. Auto-dismiss 4 s (8 s if it has an action; never auto-dismiss while VoiceOver is running; instead announce via `AccessibilityNotification.Announcement`).

### 7.12 `TTEmptyState`

- **API:** `TTEmptyState(title: String, message: String, systemImage: String, primary: (String, () -> Void)? = nil, secondary: (String, () -> Void)? = nil)`
- **Look:** centered, icon in a 72 pt `TTIconTile` (`.brand`), title `TTFont.title`, message `TTFont.callout` inkSecondary, buttons `.ttPrimaryInline` + `.ttTertiary`. Max width 420.
- **Replaces:** `EmptyStateView` (re-implement its body with `TTEmptyState`, keep the type) and ad hoc `ContentUnavailableView` usages in 1.0 screens (Collection, Match history).

### 7.13 `TTPlayerToken`

- **API:** `TTPlayerToken(isPlayerOne: Bool, size: CGFloat = DesignTokens.Size.playerToken, isActive: Bool = false)`
- **Look:** circle filled `TTColor.player(_)` with "1" or "2" in `inkOnPlayer` `TTFont.numericSmall`. Active: 2 pt outer ring of the same color at 40% with a subtle pulse (opacity 0.4↔1, 1.6 s, disabled for Reduce Motion).
- **A11y:** "Player 1" / "Player 2", plus ", active" if active.
- **Used by:** scoreboard, health panel headers, unit focus header, victory, match history rows.

### 7.14 `TTSegmentedControl` (custom, replaces `.pickerStyle(.segmented)` in 1.0 screens)

- **API:** `TTSegmentedControl(selection: Binding<T>, options: [T], title: (T) -> String, systemImage: ((T) -> String)? = nil, isDisabled: (T) -> Bool = { _ in false })` where `T: Hashable & Identifiable`.
- **Look:** `sunken` track radius `md`, selected pill `raised` + `ttElevation(.card)`, `matchedGeometryEffect` slide (no slide on Reduce Motion), label `TTFont.buttonSmall`. Height 36 (min hit 44 via padding). At `needsLayoutAdaptation` becomes a horizontally scrolling row of capsules (pattern already in `GuidedMatchHubTabBar.hubTabButton`).
- **A11y:** each segment is a button with `.isSelected` trait.
- **Replaces:** `BattleTrackerSectionTabBar.segmentedTabBar` (for non-Spearhead paths that keep tabs), `GuidedMatchHubTabBar`, Models segmented pickers, Match history filter.

### 7.15 `TTKeyValueRow`

- **API:** `TTKeyValueRow(_ key: String, value: String, systemImage: String? = nil)`. A `LabeledContent` with key `TTFont.subheadline` inkSecondary and value `TTFont.bodyEmphasis` inkPrimary. Used in army details, match detail, settings app info.

### 7.16 `TTSheetHeader`

- **API:** `TTSheetHeader(title: String, subtitle: String? = nil, tone: TTTone? = nil, onClose: () -> Void)`. Large serif title left, circular `xmark` close button right (44 pt, `sunken` fill), optional tone stripe (4 pt top border in tone color for player-owned sheets). Use for custom sheets that don't use a `NavigationStack` toolbar.

### Acceptance (DS-07)
- [ ] All components compile and appear in the gallery (DS-08).
- [ ] Each component has a VoiceOver label check in preview notes.
- [ ] `TTCounter` repeat-press works, haptics fire, VoiceOver adjustable works.

---

## DS-08: Preview matrix + component gallery

**Files:** new `DesignSystem/Theme/TTPreviewMatrix.swift`, new `DesignSystem/Components/TTComponentGallery.swift`

1. `TTPreviewMatrix<Content: View>` renders `content` three times in a `ScrollView`: light, dark (`.environment(\.colorScheme, .dark)` + `TTColor.canvas` background), and AX3 (`.environment(\.dynamicTypeSize, .accessibility3)`).
2. `TTComponentGallery`: a `List` with one section per component, showing every variant. **Debug-only:** wrap the whole file in `#if DEBUG`.
3. Add a hidden entry point: in `Features/Settings/SettingsView.swift`, under `#if DEBUG`, a row "Design System Gallery" (`settings.debug.gallery`) that pushes `TTComponentGallery`. It must not appear in Release builds.

### Acceptance (DS-08)
- [ ] Gallery reachable in Debug, absent in Release (`#if DEBUG`).
- [ ] Screenshots of the gallery in light/dark attached to the PR. These become the visual reference for all later WPs.

---

## DS-09: `hardcoded_colors` ratchet metric

**File:** `Scripts/check_architecture_debt.sh`

Add after the existing metrics:

```bash
# UI overhaul: theme tokens only (ongoing/ui-overhaul/README.md rule G1).
run_metric "hardcoded_colors"      91  "hard-coded SwiftUI/UIKit colors outside DesignSystem/Theme" \
  'Color\.(red|orange|green|blue|yellow|purple|pink|gray|mint|teal)\b|foregroundStyle\(\.(red|orange|green|blue|yellow|purple|pink|gray)\)|Color\(\.(secondarySystemBackground|tertiarySystemFill|systemBackground|secondarySystemGroupedBackground|systemGroupedBackground|secondarySystemFill|tertiarySystemBackground|quaternarySystemFill)\)' \
  "Features DesignSystem Support App" \
  '^(Features/(Bench|Muster)|DesignSystem/(Hobby|Theme))/'
```

Baseline measured 2026-10-28: **91** (excludes `Features/Bench`, `Features/Muster`, `DesignSystem/Hobby`, which are covered by DS-10 / MD-*). Every screen WP lowers this budget to the new count in the same commit. Target ≤ 10 by QA-03.

> The `exclude` argument is matched with `grep -vE` against `path:line:` output. The `^(...)/` regex excludes whole folders. Check it locally with `Scripts/check_architecture_debt.sh --report`.

### Acceptance (DS-09)
- [ ] `--report` prints `hardcoded_colors 91 / 91` (or the current count if DS-04 landed first. Then set the budget to that count).

---

## DS-10: Merge Hobby palette into the theme

**Goal:** Models (Collection) stops looking like a separate app.
**Files:** `DesignSystem/Hobby/Tokens.swift`, `DesignSystem/Hobby/Components.swift`, `DesignSystem/Hobby/StateChip.swift`

1. Keep `Tokens.Palette` (Bench code reads `palette.gold`, `palette.ink`, etc.) but change its **values** so they equal the new theme:

| Palette field | New dark | New light | Maps to |
|---------------|----------|-----------|---------|
| `bg` | `#0e131d` | `#f6f1e7` | `canvas` |
| `bg2` | `#0a0e15` | `#ece5d6` | `sunken` |
| `surface` | `#161d2b` | `#fffdf8` | `surface` |
| `surface2` | `#1e2738` | `#ffffff` | `raised` |
| `line` | `#2a3346` | `#ddd3c1` | `stroke` |
| `ink` | `#f2ece0` | `#1c1a16` | `inkPrimary` |
| `inkDim` | `#b9b2a4` | `#5a554b` | `inkSecondary` |
| `inkFaint` | `#9a9486` | `#69645a` | `inkTertiary` |
| `gold` | `#e8935a` | `#9e4b18` | `brand` |
| `goldBright` | `#f0a878` | `#b85c24` | `brandFill` (bright variant) |
| `blood` | `#f06a5f` | `#b42318` | `danger` |
| `crestText` | `#1a0e06` | `#ffffff` | `inkOnBrand` |
| `chipOnText` | `#1a0e06` | `#ffffff` | `inkOnBrand` |
| `err` | `#f06a5f` | `#b42318` | `danger` |

2. Update the comment at the top of `Tokens.swift` to say the palette mirrors `TTColor` and must be kept in sync.
3. **Pipeline stage colors** (`Domain/Hobby/Pipeline.swift` hex per stage, e.g. unbuilt/built/primed/painted) are **data**, not theme. Leave them, but verify each stage hex has ≥ 3:1 contrast against both `surface` values (non-text UI contrast). Adjust any stage color that fails and list it in the PR.
4. `StatTile` (in `Hobby/Components.swift`) uses serif numbers. Switch values to `TTFont.numericMedium` for consistency with the battle UI.

### Acceptance (DS-10)
- [ ] Models tab screenshots (light/dark) show the same navy/parchment/copper as Play.
- [ ] `CollectionFlowUITests` still pass.

---

## 8. Copy and tone guide

Apply in every WP that touches strings.

| Do | Don't |
|----|-------|
| "Start Movement Phase" | "Next: Movement Phase →" |
| "Draw your battle tactic cards" | "BATTLE TACTIC DECK — each player uses the deck…" (caps-lock paragraphs) |
| "Azure scores 2" (with player name) | "Player one +2 VP" |
| "Pass to Gold" | "Hand off the device to the other player when you are done" |
| One sentence, then an ⓘ for more | Three-sentence explanations inline |
| "You roll real dice. We keep score." | "Tabletome tracks phases, score, and rules." |
| Name the physical thing: "your realm battlefield pack" | Abstract: "the content from your set" |

- **Player names:** default names are "Player 1" / "Player 2" (existing). Under every name, show the army (`army.name`) in secondary ink. Color names ("Azure"/"Gold") are **never** shown as text; they're visual only.
- **Numbers:** always numerals ("4 rounds", not "four rounds").
- **Long rules text** (`BattleRoundChecklistStep.detail`, `newPlayerSummary`) stays in Domain but is shown behind an ⓘ ("How this works") disclosure, not inline by default.
