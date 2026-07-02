import SwiftUI
import TabletomeDomain

extension GuidedMatchView {
    var setupIsComplete: Bool {
        guard viewModel.matchState.hasBothArmies else { return false }
        let progress = viewModel.setupProgress
        guard progress.total > 0 else { return true }
        return progress.completed == progress.total
    }

    var visibleHubTabs: [GuidedMatchHubTab] {
        if gameSystemId == .aosSpearhead {
            return SpearheadHubTabs.visibleTabs(hasBothArmies: viewModel.matchState.hasBothArmies)
        }
        return GuidedMatchHubTab.visibleTabs(
            gameSystemId: gameSystemId,
            hasBothArmies: viewModel.matchState.hasBothArmies
        )
    }

    var suggestedHubTab: GuidedMatchHubTab {
        if gameSystemId == .aosSpearhead {
            return SpearheadHubTabs.suggested(
                hasBothArmies: viewModel.matchState.hasBothArmies,
                setupComplete: setupIsComplete
            )
        }
        return GuidedMatchHubTab.suggested(
            gameSystemId: gameSystemId,
            hasBothArmies: viewModel.matchState.hasBothArmies,
            setupComplete: setupIsComplete
        )
    }

    /// Spearhead hides army picker once starter matchup or manual pick is done.
    var showsSpearheadArmyPicker: Bool {
        gameSystemId != .aosSpearhead || !viewModel.matchState.hasBothArmies
    }

    /// Regiment + enhancement must be confirmed on setup steps — starter matchup only pre-selects.
    var needsPreBattleLoadoutReview: Bool {
        guard gameSystemId == .aosSpearhead, viewModel.matchState.hasBothArmies else { return false }
        let completed = viewModel.matchState.completedStepIds
        return !completed.contains("regiment-abilities") || !completed.contains("enhancements")
    }

    var spearheadAttackerLabel: String? {
        guard gameSystemId == .aosSpearhead,
              let attackerIsPlayerOne = viewModel.matchState.attackerIsPlayerOne else {
            return nil
        }
        let selection = attackerIsPlayerOne
            ? viewModel.matchState.playerOne
            : viewModel.matchState.playerTwo
        let fallback = attackerIsPlayerOne
            ? String(localized: "Player 1")
            : String(localized: "Player 2")
        return selection.playerName.isEmpty ? fallback : selection.playerName
    }

    /// iPad split detail default after armies are chosen — next setup step for Spearhead, battle tracker otherwise.
    var spearheadPadDetailDestination: GuidedMatchDestination? {
        if gameSystemId == .aosSpearhead {
            return SpearheadHubTabs.padDetailDestination(
                hasBothArmies: viewModel.matchState.hasBothArmies,
                setupComplete: setupIsComplete,
                nextIncompleteStepId: viewModel.nextIncompleteStep?.id
            )
        }
        return .battleTracker
    }

    func openSpearheadSetupStep(_ stepId: String) {
        hubTab = .setup
        if usesPadSplitNavigation {
            selectedDestination = .step(stepId)
        }
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
        if gameSystemId == .aosSpearhead {
            return "\(name) · \(faction.name) · \(army.name)"
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

    /// Phone battle tab: hide redundant hub chrome so the tracker scroll area gets vertical space.
    var hidesGuidedMatchHubChromeWhenEmbedded: Bool {
        showsEmbeddedBattleTracker && !layoutContext.usesPadSplitNavigation
    }

    var usesPhoneLandscapeBattleImmersion: Bool {
        layoutContext.prefersCollapsedBattleChrome && showsEmbeddedBattleTracker
    }

    var hidesTabBarInLandscapeBattle: Bool {
        usesPhoneLandscapeBattleImmersion
    }

    var usesCompactHubStatusBar: Bool {
        hidesGuidedMatchHubChromeWhenEmbedded
            || TabletomeLayout.prefersCompactGuidedMatchChrome(layoutContext)
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
        if playContext.capabilities.deploymentChecklistStyle == .wh40k {
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
        if playContext.capabilities.deploymentChecklistStyle == .wh40k {
            return String(
                localized: "Defaulted to \(roller) for first turn — change if your roll went differently."
            )
        }
        if playContext.capabilities.showsBattleTacticDecks {
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
