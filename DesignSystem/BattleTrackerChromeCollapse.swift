import SwiftUI
import TabletomeDomain

enum BattleTrackerChromeStorage {
    static let topCollapsedKey = "battleTracker.topChromeCollapsed"
    static let guidedMatchHubCollapsedKey = "guidedMatch.hubChromeCollapsed"
    /// User explicitly expanded battle header in phone landscape; skips auto-collapse on rotate.
    static let topChromeExpandedInLandscapeKey = "battleTracker.topChromeExpandedInLandscape"
}

struct ChromeCollapseChevronButton: View {
    enum Direction {
        case up
        case down

        var systemImage: String {
            switch self {
            case .up: "chevron.up"
            case .down: "chevron.down"
            }
        }
    }

    let direction: Direction
    var compact: Bool = false
    let accessibilityLabel: String
    let accessibilityIdentifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: direction.systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(
                    width: DesignTokens.minTouchTarget,
                    height: compact ? 28 : DesignTokens.minTouchTarget
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

struct ChromeCollapseInlineButton: View {
    let accessibilityLabel: String
    let accessibilityIdentifier: String
    let onCollapse: () -> Void

    var body: some View {
        ChromeCollapseChevronButton(
            direction: .up,
            accessibilityLabel: accessibilityLabel,
            accessibilityIdentifier: accessibilityIdentifier,
            action: onCollapse
        )
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
        HStack(spacing: DesignTokens.Spacing.xs) {
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

            Text(phaseSummary)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .adaptiveLineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel(phaseSummaryAccessibilityLabel)

            ChromeCollapseChevronButton(
                direction: .down,
                compact: true,
                accessibilityLabel: String(localized: "Show battle header"),
                accessibilityIdentifier: "battleTracker.chromeExpand",
                action: onExpand
            )
        }
        .frame(minHeight: 32)
        .barChromeBackground(horizontalPadding: DesignTokens.Spacing.sm, verticalPadding: 2)
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
        HStack(spacing: DesignTokens.Spacing.xs) {
            Text(summary)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .adaptiveLineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            ChromeCollapseChevronButton(
                direction: .down,
                compact: true,
                accessibilityLabel: String(localized: "Show match summary"),
                accessibilityIdentifier: "guidedMatch.hubChromeExpand",
                action: onExpand
            )
        }
        .frame(minHeight: 32)
        .barChromeBackground(horizontalPadding: DesignTokens.Spacing.md, verticalPadding: 2)
        .accessibilityIdentifier("guidedMatch.collapsedHubChrome")
    }
}
