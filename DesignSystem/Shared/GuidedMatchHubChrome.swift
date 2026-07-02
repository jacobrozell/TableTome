import SwiftUI
import TabletomeDomain

enum GuidedMatchHubTab: String, CaseIterable, Identifiable {
    case armies
    case setup
    case battle

    var id: String { rawValue }

    var title: String {
        switch self {
        case .armies: String(localized: "Armies")
        case .setup: String(localized: "Setup")
        case .battle: String(localized: "Battle")
        }
    }

    var systemImage: String {
        switch self {
        case .armies: "person.2.fill"
        case .setup: "checklist"
        case .battle: "flag.checkered"
        }
    }

    /// Spearhead drops the Armies hub tab once both players have lists — reset to change box.
    static func visibleTabs(
        gameSystemId: GameSystemId,
        hasBothArmies: Bool
    ) -> [GuidedMatchHubTab] {
        if gameSystemId == .aosSpearhead {
            return hasBothArmies ? [.setup, .battle] : [.armies]
        }
        return allCases
    }

    static func suggested(
        gameSystemId: GameSystemId,
        hasBothArmies: Bool,
        setupComplete: Bool
    ) -> GuidedMatchHubTab {
        if gameSystemId == .aosSpearhead, hasBothArmies {
            return setupComplete ? .battle : .setup
        }
        return suggested(hasBothArmies: hasBothArmies, setupComplete: setupComplete)
    }

    static func suggested(
        hasBothArmies: Bool,
        setupComplete: Bool
    ) -> GuidedMatchHubTab {
        if !hasBothArmies { return .armies }
        if !setupComplete { return .setup }
        return .battle
    }
}

struct GuidedMatchHubTabBar: View {
    @Binding var selection: GuidedMatchHubTab
    let visibleTabs: [GuidedMatchHubTab]
    let hasBothArmies: Bool
    let setupComplete: Bool
    var locksArmiesTab: Bool = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var lockedTabAttempt: GuidedMatchHubTab?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Group {
                if dynamicTypeSize.needsLayoutAdaptation {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            ForEach(visibleTabs) { tab in
                                hubTabButton(tab)
                            }
                        }
                        .padding(.horizontal, DesignTokens.Spacing.xs)
                    }
                } else {
                    Picker(String(localized: "Guided match section"), selection: selectionBinding) {
                        ForEach(visibleTabs) { tab in
                            Label(tab.title, systemImage: tab.systemImage)
                                .tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .accessibilityIdentifier("guidedMatch.hubTabs")

            if let lockedTabAttempt {
                Text(lockedTabMessage(for: lockedTabAttempt))
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("guidedMatch.hubTabs.lockedNotice")
            }
        }
        .onChange(of: visibleTabs) { _, tabs in
            if !tabs.contains(selection), let first = tabs.first {
                selection = first
            }
            lockedTabAttempt = nil
        }
        .onChange(of: selection) { _, _ in
            lockedTabAttempt = nil
        }
    }

    private var selectionBinding: Binding<GuidedMatchHubTab> {
        Binding(
            get: { selection },
            set: { newTab in
                if isDisabled(newTab) {
                    lockedTabAttempt = newTab
                } else {
                    lockedTabAttempt = nil
                    selection = newTab
                }
            }
        )
    }

    private func hubTabButton(_ tab: GuidedMatchHubTab) -> some View {
        let isSelected = selection == tab
        return Button {
            if isDisabled(tab) {
                lockedTabAttempt = tab
            } else {
                lockedTabAttempt = nil
                selection = tab
            }
        } label: {
            Label(tab.title, systemImage: tab.systemImage)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.tertiarySystemFill))
                .foregroundStyle(isSelected ? Color.accentOnSurface : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(accessibilityHint(for: tab))
        .accessibilityIdentifier("guidedMatch.hubTab.\(tab.rawValue)")
    }

    private func lockedTabMessage(for tab: GuidedMatchHubTab) -> String {
        switch tab {
        case .armies:
            String(localized: "Army selection is locked while a battle is in progress. Reset the match to change armies.")
        case .setup:
            String(localized: "Choose both armies first — use Starter Matchup or pick each player below.")
        case .battle:
            if !hasBothArmies {
                String(localized: "Choose both armies before opening the battle tracker.")
            } else {
                String(localized: "Finish the remaining setup steps on the Setup tab first.")
            }
        }
    }

    private func accessibilityHint(for tab: GuidedMatchHubTab) -> String {
        switch tab {
        case .armies:
            if locksArmiesTab {
                String(localized: "Army selection is locked once a battle is in progress. Reset the match to change armies.")
            } else {
                String(
                    localized: "Before the battle: pick both player armies or use starter matchup."
                )
            }
        case .setup:
            String(
                localized: "Mission, deployment, and pre-battle steps. Unlocks after both armies are chosen."
            )
        case .battle:
            if setupComplete {
                String(localized: "Turn phases, scoring, and unit health at the table.")
            } else {
                String(localized: "Unlocks after setup steps are complete.")
            }
        }
    }

    private func isDisabled(_ tab: GuidedMatchHubTab) -> Bool {
        switch tab {
        case .armies:
            locksArmiesTab
        case .setup:
            !hasBothArmies
        case .battle:
            !hasBothArmies || !setupComplete
        }
    }
}

struct GuidedMatchStatusBar: View {
    let playerOneSummary: String
    let playerTwoSummary: String
    let hasBothArmies: Bool
    let setupCompleted: Int
    let setupTotal: Int
    let nextStepTitle: String?
    let setupComplete: Bool
    var activeHubTab: GuidedMatchHubTab = .armies
    var battleTrackerSummary: String?
    var compactMode: Bool = false

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if compactMode {
                compactBody
            } else {
                fullBody
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("guidedMatch.statusBar")
    }

    @ViewBuilder
    private var compactBody: some View {
        if let battleTrackerSummary {
            Label(battleTrackerSummary, systemImage: "flag.checkered")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .adaptiveLineLimit(1)
        } else if hasBothArmies {
            Text(matchupLine)
                .font(.caption.weight(.semibold))
                .adaptiveLineLimit(1)
                .accessibilityLabel(matchupAccessibilityLabel)
        } else {
            Text(String(localized: "Choose both armies to unlock setup"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .adaptiveLineLimit(1)
        }
    }

    @ViewBuilder
    private var fullBody: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            if hasBothArmies {
                Text(matchupLine)
                    .font(.caption.weight(.semibold))
                    .adaptiveLineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel(matchupAccessibilityLabel)

                if setupTotal > 0, !setupComplete {
                    if activeHubTab == .setup {
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            ProgressView(
                                value: Double(setupCompleted),
                                total: Double(setupTotal)
                            )
                            .frame(maxWidth: 120)
                            Text(setupProgressLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    } else {
                        Text(setupProgressLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else if setupComplete {
                    if let battleTrackerSummary {
                        Label(battleTrackerSummary, systemImage: "flag.checkered")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    } else {
                        Label(String(localized: "Setup complete — open Battle"), systemImage: "checkmark.circle.fill")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text(String(localized: "Choose both armies to unlock setup"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var setupProgressLabel: String {
        switch activeHubTab {
        case .armies:
            if hasBothArmies {
                return String(localized: "Armies ready — open Setup for pre-battle steps")
            }
            return String(localized: "Choose both armies to unlock setup")
        case .setup:
            var label = "\(String(localized: "Setup")) \(setupCompleted)/\(setupTotal)"
            if let nextStepTitle {
                label += " · \(nextStepTitle)"
            }
            return label
        case .battle:
            if setupComplete {
                return String(localized: "Setup complete")
            }
            if let nextStepTitle {
                return String(localized: "Finish setup — \(nextStepTitle)")
            }
            return String(localized: "Finish setup on the Setup tab")
        }
    }

    private var matchupLine: String {
        "\(playerOneSummary) \(String(localized: "vs")) \(playerTwoSummary)"
    }

    private var matchupAccessibilityLabel: String {
        "\(playerOneSummary), \(String(localized: "vs")), \(playerTwoSummary)"
    }
}
