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
    let hasBothArmies: Bool
    let setupComplete: Bool

    var body: some View {
        Picker(String(localized: "Guided match section"), selection: $selection) {
            ForEach(GuidedMatchHubTab.allCases) { tab in
                Label(tab.title, systemImage: tab.systemImage)
                    .tag(tab)
                    .disabled(isDisabled(tab))
                    .accessibilityHint(accessibilityHint(for: tab))
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("guidedMatch.hubTabs")
    }

    private func accessibilityHint(for tab: GuidedMatchHubTab) -> String {
        switch tab {
        case .armies:
            String(
                localized: "Pick both armies or use starter matchup. Required before setup unlocks."
            )
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
            false
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
    var battleTrackerSummary: String?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            if hasBothArmies {
                HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                    Text(playerOneSummary)
                        .font(.caption.weight(.semibold))
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                    Text(String(localized: "vs"))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(playerTwoSummary)
                        .font(.caption.weight(.semibold))
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }
                .fixedSize(horizontal: false, vertical: true)

                if setupTotal > 0, !setupComplete {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        ProgressView(
                            value: Double(setupCompleted),
                            total: Double(setupTotal)
                        )
                        .frame(maxWidth: 120)
                        Text(self.setupProgressLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                } else if setupComplete {
                    if let battleTrackerSummary {
                        Label(battleTrackerSummary, systemImage: "flag.checkered")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.accentColor)
                            .lineLimit(2)
                    } else {
                        Label(String(localized: "Setup complete — open Battle"), systemImage: "checkmark.circle.fill")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.accentColor)
                    }
                }
            } else {
                Text(String(localized: "Choose both armies to unlock setup"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.bar)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("guidedMatch.statusBar")
    }

    private var setupProgressLabel: String {
        var label = "\(String(localized: "Setup")) \(setupCompleted)/\(setupTotal)"
        if let nextStepTitle {
            label += " · \(nextStepTitle)"
        }
        return label
    }
}
