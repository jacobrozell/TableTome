import SwiftUI
import TabletomeDomain

struct BattleTrackerSetupTabContent<StartOfRound: View, Deployment: View>: View {
    let showsBattleTacticDecks: Bool
    let battleRound: Int
    let roundOpenerIsIncomplete: Bool
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    @ViewBuilder let startOfRound: () -> StartOfRound
    @ViewBuilder let deployment: () -> Deployment

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            if showsBattleTacticDecks, battleRound > 1, roundOpenerIsIncomplete {
                NewMainTurnReminderBanner(round: battleRound)
            }
            startOfRound()
            deployment()
            BattleTrackerRoundOpenerSection(viewModel: viewModel)
        }
    }
}

struct BattleTrackerSCCombatTabContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            BattleTrackerSCTrackerPlaceholderSection()
        }
    }
}

struct BattleTrackerCompactTabContent<
    Setup: View,
    Turn: View,
    Combat: View,
    Army: View
>: View {
    let selectedSectionTab: BattleTrackerSectionTab
    @ViewBuilder let setup: () -> Setup
    @ViewBuilder let turn: () -> Turn
    @ViewBuilder let combat: () -> Combat
    @ViewBuilder let army: () -> Army

    var body: some View {
        switch selectedSectionTab {
        case .setup:
            setup()
        case .turn:
            turn()
        case .combat:
            combat()
        case .army:
            army()
        }
    }
}

struct BattleTrackerCompactLayout<TabHint: View, TabContent: View>: View {
    let spacing: CGFloat
    let reduceMotion: Bool
    let showsBattleTrackerCoach: Bool
    let selectedSectionTab: BattleTrackerSectionTab
    @ViewBuilder let tabHint: () -> TabHint
    @ViewBuilder let tabContent: () -> TabContent

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            tabHint()
            tabContent()
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: showsBattleTrackerCoach)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: selectedSectionTab)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
