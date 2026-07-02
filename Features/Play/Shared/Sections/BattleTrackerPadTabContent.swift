import SwiftUI
import TabletomeDomain

struct BattleTrackerPadSetupColumns<Deployment: View, StartOfRound: View>: View {
    let spacing: CGFloat
    let showsBattleTacticDecks: Bool
    let battleRound: Int
    let roundOpenerIsIncomplete: Bool
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    @ViewBuilder let deployment: () -> Deployment
    @ViewBuilder let startOfRound: () -> StartOfRound

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if showsBattleTacticDecks, battleRound > 1, roundOpenerIsIncomplete {
                NewMainTurnReminderBanner(round: battleRound)
            }
            deployment()
            BattleTrackerRoundOpenerSection(viewModel: viewModel)
            startOfRound()
        }
    }
}

struct BattleTrackerPadTabContent<
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

struct BattleTrackerPadTabbedLayout<TabHint: View, TabContent: View>: View {
    let spacing: CGFloat
    let reduceMotion: Bool
    let showsBattleTrackerCoach: Bool
    let selectedSectionTab: BattleTrackerSectionTab
    let maxContentWidth: CGFloat?
    let contentAlignment: Alignment
    @ViewBuilder let tabHint: () -> TabHint
    @ViewBuilder let tabContent: () -> TabContent

    var body: some View {
        let content = VStack(alignment: .leading, spacing: spacing) {
            tabHint()
            tabContent()
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: showsBattleTrackerCoach)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: selectedSectionTab)
        .accessibilityIdentifier("battleTracker.padTwoColumnLayout")

        Group {
            if let maxWidth = maxContentWidth {
                content
                    .frame(maxWidth: maxWidth, alignment: contentAlignment)
                    .frame(maxWidth: .infinity, alignment: contentAlignment)
            } else {
                content
                    .frame(maxWidth: .infinity, alignment: contentAlignment)
            }
        }
    }
}
