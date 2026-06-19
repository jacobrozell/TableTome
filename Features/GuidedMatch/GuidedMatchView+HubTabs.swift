import SwiftUI
import TabletomeDomain

extension GuidedMatchView {
    var setupIsComplete: Bool {
        guard viewModel.matchState.hasBothArmies else { return false }
        let progress = viewModel.setupProgress
        guard progress.total > 0 else { return true }
        return progress.completed == progress.total
    }

    var suggestedHubTab: GuidedMatchHubTab {
        GuidedMatchHubTab.suggested(
            hasBothArmies: viewModel.matchState.hasBothArmies,
            setupComplete: setupIsComplete
        )
    }

    func playerSummary(
        selection: PlayerArmySelection,
        catalog: SpearheadCatalog,
        fallback: String
    ) -> String {
        let name = selection.playerName.isEmpty ? fallback : selection.playerName
        guard let faction = catalog.factions.first(where: { $0.id == selection.factionId }),
              let army = faction.armies.first(where: { $0.id == selection.armyId }) else {
            return name
        }
        return "\(name) · \(army.name)"
    }

    var hasResumableBattleSession: Bool {
        BattleTrackerStore.hasResumableBattleProgress(gameSystemId: gameSystemId)
    }

    func battleTrackerSummaryLine() -> String? {
        guard setupIsComplete || hasResumableBattleSession else { return nil }
        let state = BattleTrackerStore.load(gameSystemId: gameSystemId)
        let playerName = state.activePlayerIsOne
            ? (viewModel.matchState.playerOne.playerName.isEmpty
                ? String(localized: "Player 1")
                : viewModel.matchState.playerOne.playerName)
            : (viewModel.matchState.playerTwo.playerName.isEmpty
                ? String(localized: "Player 2")
                : viewModel.matchState.playerTwo.playerName)
        return "\(BattleRules.roundLabel(round: state.battleRound, gameSystemId: gameSystemId)) · \(state.currentPhase.title) · \(playerName)"
    }

    var showsEmbeddedBattleTracker: Bool {
        hubTab == .battle
            && viewModel.matchState.hasBothArmies
            && (setupIsComplete || hasResumableBattleSession)
    }

    var usesPhoneLandscapeBattleImmersion: Bool {
        layoutContext.prefersCollapsedBattleChrome && showsEmbeddedBattleTracker
    }

    var hidesTabBarInLandscapeBattle: Bool {
        usesPhoneLandscapeBattleImmersion
    }

    var usesCompactLandscapeStatusBar: Bool {
        usesPhoneLandscapeBattleImmersion
    }

    var showsHubChromeCollapseToggle: Bool {
        !usesPhoneLandscapeBattleImmersion && !showsEmbeddedBattleTracker
    }

    func hubChromeSummaryLine(catalog: SpearheadCatalog) -> String {
        if showsEmbeddedBattleTracker, let battleSummary = battleTrackerSummaryLine() {
            return battleSummary
        }
        if viewModel.matchState.hasBothArmies {
            let playerOne = playerSummary(
                selection: viewModel.matchState.playerOne,
                catalog: catalog,
                fallback: String(localized: "Player 1")
            )
            let playerTwo = playerSummary(
                selection: viewModel.matchState.playerTwo,
                catalog: catalog,
                fallback: String(localized: "Player 2")
            )
            return "\(playerOne) \(String(localized: "vs")) \(playerTwo)"
        }
        return String(localized: "Choose both armies to unlock setup")
    }
}
