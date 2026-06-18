import SwiftUI
import TabletomeDomain

enum BattleTrackerSectionTab: String, CaseIterable, Identifiable {
    case setup
    case turn
    case combat
    case army

    var id: String { rawValue }

    var title: String {
        switch self {
        case .setup: String(localized: "Setup")
        case .turn: String(localized: "Turn")
        case .combat: String(localized: "Combat")
        case .army: String(localized: "Army")
        }
    }

    var systemImage: String {
        switch self {
        case .setup: "map"
        case .turn: "arrow.triangle.2.circlepath"
        case .combat: "dice.fill"
        case .army: "person.3.fill"
        }
    }

    static func suggested(
        phase: BattleTurnPhase,
        deploymentComplete: Bool,
        roundOpenerIncomplete: Bool
    ) -> BattleTrackerSectionTab {
        if !deploymentComplete || roundOpenerIncomplete {
            return .setup
        }
        if phase.isCombatRelated {
            return .combat
        }
        return .turn
    }
}

struct BattleTrackerSectionTabBar: View {
    @Binding var selection: BattleTrackerSectionTab

    var body: some View {
        Picker(String(localized: "Battle tracker section"), selection: $selection) {
            ForEach(BattleTrackerSectionTab.allCases) { tab in
                Label(tab.title, systemImage: tab.systemImage).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("battleTracker.sectionTabs")
    }
}

struct StickyPhaseHeader: View {
    let round: Int
    let phaseTitle: String
    let playerName: String

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Text(SpearheadBattleRules.roundLabel(round: round))
                .font(.subheadline.weight(.semibold))
            Text("·")
                .foregroundStyle(.tertiary)
            Text(playerName)
                .font(.subheadline)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text(phaseTitle)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .background(Color.accentColor.opacity(0.15), in: Capsule())
                .foregroundStyle(Color.accentColor)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(.bar)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("battleTracker.stickyPhaseHeader")
    }
}
