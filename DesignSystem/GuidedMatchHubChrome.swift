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

    var body: some View {
        Picker(String(localized: "Guided match section"), selection: $selection) {
            ForEach(GuidedMatchHubTab.allCases) { tab in
                Label(tab.title, systemImage: tab.systemImage)
                    .tag(tab)
                    .disabled(tab == .setup && !hasBothArmies)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("guidedMatch.hubTabs")
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

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            if hasBothArmies {
                HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                    Text(playerOneSummary)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                    Text(String(localized: "vs"))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text(playerTwoSummary)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                }

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
                        .lineLimit(2)
                    }
                } else if setupComplete {
                    Label(String(localized: "Setup complete — open Battle"), systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.accentColor)
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
