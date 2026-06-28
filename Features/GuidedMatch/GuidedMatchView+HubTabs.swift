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
        return "\(GameSystemPlayContext.context(for: gameSystemId).playEngine.roundLabel(round: state.battleRound)) · \(state.currentPhase.title) · \(playerName)"
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

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    private var playerOneRollLabel: String {
        let name = viewModel.matchState.playerOne.playerName
        return name.isEmpty ? String(localized: "Player 1") : name
    }

    private var playerTwoRollLabel: String {
        let name = viewModel.matchState.playerTwo.playerName
        return name.isEmpty ? String(localized: "Player 2") : name
    }

    var inlineRollPickerTitle: String {
        if playContext.isWh40k11e {
            return String(localized: "Who takes the first turn?")
        }
        return String(localized: "Who is the attacker?")
    }

    @ViewBuilder
    var inlineRollPickerCard: some View {
        AttackerDefenderPickerCard(
            playerOneName: playerOneRollLabel,
            playerTwoName: playerTwoRollLabel,
            attackerIsPlayerOne: viewModel.matchState.attackerIsPlayerOne,
            onSelect: viewModel.setAttacker,
            title: inlineRollPickerTitle,
            decidedCaption: inlineRollDecidedCaption(isPlayerOne:),
            accessibilityPrefix: "guidedMatch.inlineRoll"
        )
    }

    private func inlineRollDecidedCaption(isPlayerOne: Bool) -> String {
        let roller = isPlayerOne ? playerOneRollLabel : playerTwoRollLabel
        if playContext.isWh40k11e {
            return String(
                localized: "Defaulted to \(roller) for first turn — change if your roll went differently."
            )
        }
        if playContext.isSpearhead {
            let defender = isPlayerOne ? playerTwoRollLabel : playerOneRollLabel
            return String(
                localized: "Defaulted to \(roller) as attacker and \(defender) as defender — change if your roll went differently."
            )
        }
        return String(
            localized: "Defaulted to \(roller) — change if your roll went differently."
        )
    }
}
