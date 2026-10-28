# 02: App shell

Back to [index](README.md). Global chrome: navigation bars, tab bar, backgrounds, lists, toasts, launch and loading.

---

## SH-01: Global appearance bootstrap

**Goal:** Navigation titles use the serif display face, the tab bar is tinted copper, and every window has the canvas background.
**Depends on:** DS-01, DS-02
**Files:** new `DesignSystem/Theme/TTAppearance.swift`; edit `App/TabletomeApp.swift`

### Steps

1. Create `TTAppearance.swift`:
   ```swift
   import SwiftUI
   import UIKit

   @MainActor
   enum TTAppearance {
       /// Call once at launch, before the first scene renders.
       static func apply() {
           let serifLarge = UIFontDescriptor
               .preferredFontDescriptor(withTextStyle: .largeTitle)
               .withDesign(.serif)?
               .withSymbolicTraits(.traitBold)
           let serifInline = UIFontDescriptor
               .preferredFontDescriptor(withTextStyle: .headline)
               .withDesign(.serif)

           let nav = UINavigationBar.appearance()
           var large = nav.largeTitleTextAttributes ?? [:]
           if let serifLarge { large[.font] = UIFont(descriptor: serifLarge, size: 0) }
           large[.foregroundColor] = UIColor(TTColor.inkPrimary)
           nav.largeTitleTextAttributes = large

           var inline = nav.titleTextAttributes ?? [:]
           if let serifInline { inline[.font] = UIFont(descriptor: serifInline, size: 0) }
           inline[.foregroundColor] = UIColor(TTColor.inkPrimary)
           nav.titleTextAttributes = inline

           if #unavailable(iOS 26.0) {
               // Pre-glass: opaque canvas-tinted bars so content doesn't look "stock".
               let bar = UINavigationBarAppearance()
               bar.configureWithDefaultBackground()
               bar.backgroundColor = UIColor(TTColor.canvas).withAlphaComponent(0.92)
               bar.shadowColor = UIColor(TTColor.stroke)
               bar.largeTitleTextAttributes = large
               bar.titleTextAttributes = inline
               nav.standardAppearance = bar
               nav.scrollEdgeAppearance = {
                   let edge = UINavigationBarAppearance()
                   edge.configureWithTransparentBackground()
                   edge.largeTitleTextAttributes = large
                   edge.titleTextAttributes = inline
                   return edge
               }()
               nav.compactAppearance = bar

               let tab = UITabBarAppearance()
               tab.configureWithDefaultBackground()
               tab.backgroundColor = UIColor(TTColor.surface).withAlphaComponent(0.94)
               tab.shadowColor = UIColor(TTColor.stroke)
               UITabBar.appearance().standardAppearance = tab
               UITabBar.appearance().scrollEdgeAppearance = tab
           }
           UITabBar.appearance().tintColor = UIColor(TTColor.brandFill)
           UITabBar.appearance().unselectedItemTintColor = UIColor(TTColor.inkTertiary)
       }
   }
   ```
2. In `TabletomeApp`, add `init() { TTAppearance.apply() }`. `TabletomeApp` already has stored properties with initial values, so an explicit `init()` is allowed. Keep `@StateObject`/`@State` initializers as they are.
3. In the `WindowGroup`, add `.tint(TTColor.brandFill)` and `.background(TTColor.canvas.ignoresSafeArea())` on `RootTabView()`.
4. **iOS 26 check:** on iOS 26 the system glass bars ignore `backgroundColor`, which is intended. Only fonts and tint apply there.

### Acceptance
- [ ] Large titles (Play, Rules, Collection, Settings) render in New York serif bold.
- [ ] Tab bar selected item is copper, unselected uses tertiary ink, in both modes.
- [ ] No regression in `BattleTrackerScreenChrome` toolbar items.

---

## SH-02: Tab order and icons

**Goal (D2):** Play · Rules · Models · Settings, with intentional icons.
**Depends on:** SH-01
**Files:** `App/RootTabView.swift`, `Support/TabBarAccessibilityBridge.swift`, `Features/Onboarding/OnboardingContent.swift` (tab tour order), `Tests/Unit/AppRouterNavigationTests.swift` (if it asserts order)

| Tab | Title | SF Symbol (unselected → selected uses `.fill` automatically via `.symbolVariant` in TabView) | `accessibilityIdentifier` (unchanged) |
|-----|-------|------|------|
| Play | "Play" | `flag.checkered` | `tab.play` |
| Rules | "Rules" | `book.closed` | `tab.rules` |
| Models | "Models" | `shield.lefthalf.filled` | `tab.bench` |
| Settings | "Settings" | `gearshape` | `tab.settings` |

### Steps

1. In `RootTabView.body`, reorder the `TabView` children to: `playTab`, `rulesTab`, `BenchTab()` block, `MusterTab()` block (gated; keep it after Models), Settings.
2. Update `tabBarItemIdentifiers` to the same order: `tab.play`, rules id, `tab.bench` (if shown), `tab.muster` (if shown), `tab.settings`.
3. **Critical:** `TabBarSelectionBridge.Controller.tabIndex(for:)` in `Support/TabBarAccessibilityBridge.swift` hard-codes tab **positions**. Rewrite it to follow the new order: learn → search → bench → muster → settings, keeping the `ReleaseSurface` conditionals. If you skip this, iPad tab highlighting will select the wrong tab.
4. Replace `systemImage` values per the table. Remove `.fill` suffixes; TabView applies fill when selected on iOS 18+.
5. Update `OnboardingContent.tabTourItems` order to match (Play, Rules, Models, Settings).
6. Keep the Play "Start" badge logic (`emphasizePlayTab`) as is.
7. Run `rg "tabIndex|selectedIndex" Support App Features` to find any other position-based code.

### Acceptance
- [ ] iPhone and iPad: tapping each tab highlights the correct item. Deep links to Models (`collection/backlog`) select Models.
- [ ] `CollectionFlowUITests` (uses `tab.bench`) passes.

---

## SH-03: Screen background and list styling

**Goal:** Lists stop looking like Settings. One modifier per pattern.
**Depends on:** DS-04
**Files:** new `DesignSystem/Theme/TTScreenStyles.swift`

```swift
import SwiftUI

public extension View {
    /// Canvas background for any screen. Use on the outermost view inside a NavigationStack destination.
    func ttScreenBackground() -> some View {
        background(TTColor.canvas.ignoresSafeArea())
    }

    /// Restyles a grouped List: canvas background, surface rows, theme separators.
    func ttGroupedList() -> some View {
        listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(TTColor.canvas.ignoresSafeArea())
            .listRowSeparatorTint(TTColor.stroke)
            .environment(\.defaultMinListRowHeight, 52)
    }

    /// Card-stack list (floating cards, no row chrome). Replaces `floatingCardListStyle()` in 1.0 screens.
    func ttCardList() -> some View {
        listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(TTColor.canvas.ignoresSafeArea())
            .contentMargins(.horizontal, DesignTokens.Spacing.md, for: .scrollContent)
            .contentMargins(.top, DesignTokens.Spacing.sm, for: .scrollContent)
    }

    /// Apply to every row inside `ttGroupedList()`.
    func ttListRow() -> some View {
        listRowBackground(TTColor.surface)
    }
}
```

Usage rules:
- **Reference / settings-style screens** (Settings, Rules browse, Army picker, Hobby settings): `List { … }.ttGroupedList()` and `.ttListRow()` on rows (or set `listRowBackground` per `Section` content).
- **Narrative / dashboard screens** (Play home, Spearhead guide, Guided Match, Battle): `ScrollView` + `VStack(spacing: DesignTokens.Spacing.lg)` with cards, or `List { … }.ttCardList()` when swipe actions are needed.
- **Section headers** in grouped lists: `Section { … } header: { TTSectionHeader("Title") }` + `.textCase(nil)` on the `List`.
- Keep `tabBarScrollInset()` where it exists. It protects content from the floating tab bar.

Also update the existing `floatingCardListStyle()` (in `SurfaceCard.swift`) to call `ttCardList()` internally so older call sites get the canvas background too.

### Acceptance
- [ ] Gallery adds a "Lists" page showing both list styles in light/dark.
- [ ] No list in a 1.0 screen shows the system gray `systemGroupedBackground` after its screen WP lands.

---

## SH-04: Toast host (one notification system)

**Goal:** Replace ad hoc inline notices for transient events (undo damage, VP changed, phase changed, copied) with a single bottom toast that never pushes layout.
**Depends on:** DS-07 (`TTToast` look)
**Files:** `Support/Hobby/Banner.swift` (extend, don't replace), `App/RootTabView.swift` (already applies `.bannerInset()`)

### Background

`BannerCenter` (`Support/Hobby/Banner.swift`) is an `@Observable` app-wide object injected in `TabletomeApp` (`.environment(hobbyBanner)`). It holds one `message: String?`, auto-clears after `duration`, renders as a **top** `safeAreaInset` (which pushes content down), and already posts a VoiceOver announcement. Models uses it via `banner.show("…")`. We extend it so it becomes the single transient-feedback API.

### Steps

1. Add a model type next to `BannerCenter`:
   ```swift
   struct BannerItem: Identifiable, Equatable {
       let id: String                 // de-dupe key, e.g. "battle.damageUndo"
       let message: String
       var systemImage: String? = nil
       var tone: TTTone = .neutral
       var actionTitle: String? = nil
       var action: (() -> Void)? = nil
       var duration: Double = 3.0
       static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id && lhs.message == rhs.message }
   }
   ```
2. Give `BannerCenter` a `current: BannerItem?` and a private FIFO `queue: [BannerItem]` (max 3, drop oldest). Add `func show(_ item: BannerItem)`. If `item.id == current?.id`, replace `current` and restart its timer; otherwise enqueue, and present when `current` clears. Items with an action default to 8 s. **Keep** `show(_ text:duration:)` working by wrapping it: `show(BannerItem(id: UUID().uuidString, message: text, duration: duration))`. Keep `message` as a computed property `current?.message` so existing reads compile.
3. If `UIAccessibility.isVoiceOverRunning`, don't auto-dismiss items that have an action; the user dismisses them (swipe down or the ✕).
4. Restyle `BannerModifier`: render as an **overlay at the bottom** (`.overlay(alignment: .bottom)`) so it never pushes layout. Use the `TTToast` look (capsule, `TTColor.raised`, `.ttElevation(.raised)`, icon in `tone.foreground`, text `TTFont.subheadline`, optional action `.ttTertiary`, 44 pt ✕). Bottom padding = `tabBarScrollBottomInset`-aware value + `toastBottomInset` environment value (new `EnvironmentValues` key, default 0; the battle screen sets it to the action bar height in BT-04). Transition: move from bottom + opacity (opacity only with Reduce Motion).
5. Swipe-down gesture on the toast dismisses it.
6. Document in `Support/README.md`: "`BannerCenter` is the only transient feedback API. Use `BannerItem` ids prefixed by screen (`battle.`, `models.`)."

### Acceptance
- [ ] Posting 3 toasts quickly shows them in sequence. Same-id posts replace.
- [ ] VoiceOver announces the toast text.
- [ ] Models' existing banners (delete undo, import results) still work and now use the new look.

---

## SH-05: Launch screen, loading and error shells

**Goal:** No white flash at launch, and branded loading/error states.
**Depends on:** DS-07
**Files:** `project.yml`, new `Resources/Assets.xcassets/LaunchBackground.colorset`, `DesignSystem/Hobby/AdaptiveLayout.swift` (`asyncContentShell`), `DesignSystem/EmptyStateView.swift`

### Steps

1. **Launch screen.** `project.yml` uses `GENERATE_INFOPLIST_FILE: YES` with `INFOPLIST_KEY_*` build settings, and a `UILaunchScreen` *dictionary* can't be expressed that way. Use XcodeGen's `info:` block on the `Tabletome` target, which writes a small Info.plist that Xcode merges with the generated keys:
   ```yaml
   targets:
     Tabletome:
       info:
         path: Resources/Info.plist
         properties:
           UILaunchScreen:
             UIColorName: LaunchBackground
             UIImageName: CrestLogo
             UIImageRespectsSafeAreaInsets: true
   ```
   Then **delete** the `INFOPLIST_KEY_UILaunchScreen_Generation: YES` line. Run `xcodegen generate`, commit the generated `Resources/Info.plist` (it holds no secrets), and confirm the built app's Info.plist still contains `CFBundleDisplayName` and the local-network keys (`plutil -p <App>.app/Info.plist`). If `Resources/` is globbed as a resource folder and Xcode warns "Info.plist in Copy Bundle Resources", add `excludes: ["Info.plist"]` to that source entry.
2. Create `LaunchBackground.colorset` with light `#F6F1E7` and dark `#0E131D` (same as `canvas`).
3. `CrestLogo` is a 1024 px full-bleed square with its own navy background, so it will look like a tile on the light launch screen. Acceptable for 1.0. Optional follow-up: export a transparent crest (`CrestMark`) from the source art. Do not attempt image editing in this WP.
4. **Loading shell.** `asyncContentShell()` wraps `ProgressView`s. Change the shell to: canvas background, centered `BrandCrest(size: 64)` at 60% opacity with a slow breathing opacity animation (disabled for Reduce Motion), then the `ProgressView` label text in `TTFont.callout` inkSecondary below. Keep accessibility identifiers on the `ProgressView` (`home.loading`, `rules.loading`).
5. **Error shell.** `EmptyStateView` → implemented via `TTEmptyState` (DS-07 §7.12). Keep its public init.

### Acceptance
- [ ] Cold launch in dark mode: navy launch → navy app, no white flash.
- [ ] Loading states show the crest. Error states show `TTEmptyState` with Retry as `.ttPrimaryInline`.
