import SwiftUI
import TabletomeDomain

enum BattleTrackerChromeStorage {
    static let topCollapsedKey = "battleTracker.topChromeCollapsed"
    static let guidedMatchHubCollapsedKey = "guidedMatch.hubChromeCollapsed"
    /// User explicitly expanded battle header in phone landscape; skips auto-collapse on rotate.
    static let topChromeExpandedInLandscapeKey = "battleTracker.topChromeExpandedInLandscape"
}

struct ChromeCollapseInlineButton: View {
    let accessibilityLabel: String
    let accessibilityIdentifier: String
    let onCollapse: () -> Void

    var body: some View {
        Button(action: onCollapse) {
            Image(systemName: "chevron.up")
                .font(.caption.weight(.semibold))
                .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

struct ChromeCollapseToolbarButton: View {
    @Binding var isCollapsed: Bool
    let expandedAccessibilityLabel: String
    let collapsedAccessibilityLabel: String
    var accessibilityIdentifier: String

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isCollapsed.toggle()
            }
        } label: {
            Image(systemName: isCollapsed ? "rectangle.expand.vertical" : "rectangle.compress.vertical")
        }
        .accessibilityLabel(isCollapsed ? collapsedAccessibilityLabel : expandedAccessibilityLabel)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

struct BattleTrackerCollapsedTopChrome: View {
    let gameSystemId: GameSystemId
    let tabs: [BattleTrackerSectionTab]
    @Binding var selection: BattleTrackerSectionTab
    let round: Int
    let phaseTitle: String
    let playerName: String
    let onExpand: () -> Void

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button(action: onExpand) {
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "Show battle header"))
            .accessibilityIdentifier("battleTracker.chromeExpand")

            Menu {
                ForEach(tabs) { tab in
                    Button {
                        selection = tab
                    } label: {
                        if selection == tab {
                            Label(tab.title, systemImage: "checkmark")
                        } else {
                            Text(tab.title)
                        }
                    }
                }
            } label: {
                Label(selection.title, systemImage: selection.systemImage)
                    .font(.caption.weight(.semibold))
                    .adaptiveLineLimit(1)
            }
            .accessibilityHint(String(localized: "Switch battle tracker section"))

            Spacer(minLength: 0)

            Text(phaseSummary)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .adaptiveLineLimit(1)
                .accessibilityLabel(phaseSummaryAccessibilityLabel)
        }
        .barChromeBackground(horizontalPadding: DesignTokens.Spacing.sm, verticalPadding: DesignTokens.Spacing.xs)
        .accessibilityIdentifier("battleTracker.collapsedTopChrome")
    }

    private var playEngine: PlayEngineConfig {
        GameSystemPlayContext.context(for: gameSystemId).playEngine
    }

    private var phaseSummary: String {
        "\(playEngine.roundLabel(round: round)) · \(phaseTitle)"
    }

    private var phaseSummaryAccessibilityLabel: String {
        [
            playEngine.roundLabel(round: round),
            phaseTitle,
            playerName
        ].joined(separator: ", ")
    }
}

struct GuidedMatchCollapsedHubChrome: View {
    let summary: String
    let onExpand: () -> Void

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button(action: onExpand) {
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "Show match summary"))
            .accessibilityIdentifier("guidedMatch.hubChromeExpand")

            Text(summary)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .adaptiveLineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .barChromeBackground()
        .accessibilityIdentifier("guidedMatch.collapsedHubChrome")
    }
}
