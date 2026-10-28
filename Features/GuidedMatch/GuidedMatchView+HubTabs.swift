import SwiftUI
import TabletomeDomain

extension GuidedMatchView {
    var setupIsComplete: Bool {
        viewModel.setupIsComplete
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

    func syncHubTabWithVisibleTabs() {
        let tabs = visibleHubTabs
        if !tabs.contains(hubTab), let first = tabs.first {
            hubTab = first
        } else if hubTab == .armies, gameSystemId == .aosSpearhead, !showsSpearheadArmyPicker {
            hubTab = suggestedHubTab
        }
    }

    /// Single hub-tab pass after catalog + household defaults — avoids multiple `hubTab` writes per frame.
    func applyGuidedMatchHubTabPolicyAfterLoad() {
        if !hasAppliedInitialHubTab {
            hasAppliedInitialHubTab = true
            hubTab = initialHubTab ?? suggestedHubTab
        }
        syncHubTabWithVisibleTabs()
        if hasResumableBattleSession, visibleHubTabs.contains(.battle) {
            hubTab = .battle
            logBattleTrackerOpened(source: "resume")
        }
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
        } else {
            router.learnPath.append(GuidedMatchDestination.step(stepId))
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

    var playerOneRollLabel: String {
        let name = viewModel.matchState.playerOne.playerName
        return name.isEmpty ? String(localized: "Player 1") : name
    }

    var playerTwoRollLabel: String {
        let name = viewModel.matchState.playerTwo.playerName
        return name.isEmpty ? String(localized: "Player 2") : name
    }

    var inlineRollPickerTitle: String {
        if playContext.capabilities.deploymentChecklistStyle == .wh40k {
            return String(localized: "Who takes the first turn?")
        }
        return String(localized: "Who is the attacker?")
    }

    func inlineRollDecidedCaption(isPlayerOne: Bool) -> String {
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

struct GuidedMatchStageHeader: View {
    @Binding var selection: GuidedMatchHubTab
    let visibleTabs: [GuidedMatchHubTab]
    let hasBothArmies: Bool
    let setupComplete: Bool
    var locksArmiesTab: Bool = false
    var setupCompleted: Int = 0
    var setupTotal: Int = 0

    @State private var lockedTabAttempt: GuidedMatchHubTab?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(Array(visibleTabs.enumerated()), id: \.element.id) { index, tab in
                    if index > 0 {
                        Rectangle()
                            .fill(TTColor.stroke)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 15)
                    }
                    node(tab)
                }
            }
            .accessibilityIdentifier("guidedMatch.hubTabs")
            if let lockedTabAttempt {
                Text(lockedTabAttempt.lockedMessage(hasBothArmies: hasBothArmies))
                    .font(TTFont.caption)
                    .foregroundStyle(TTColor.warning)
                    .accessibilityIdentifier("guidedMatch.hubTabs.lockedNotice")
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .frame(minHeight: 64)
        .barChromeBackground()
    }

    private func node(_ tab: GuidedMatchHubTab) -> some View {
        let locked = tab.isLocked(
            hasBothArmies: hasBothArmies,
            setupComplete: setupComplete,
            locksArmiesTab: locksArmiesTab
        )
        let selected = selection == tab
        return Button {
            if locked {
                lockedTabAttempt = tab
            } else {
                lockedTabAttempt = nil
                selection = tab
            }
        } label: {
            VStack(spacing: DesignTokens.Spacing.xxs) {
                nodeMark(tab, selected: selected)
                Text(label(for: tab))
                    .font(tab == .setup ? TTFont.numericSmall : TTFont.caption)
                    .foregroundStyle(selected ? TTColor.inkPrimary : TTColor.inkSecondary)
                    .lineLimit(1)
            }
            .frame(minWidth: 72)
            .opacity(locked ? 0.4 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .accessibilityHint(tab.guidedMatchAccessibilityHint(locksArmiesTab: locksArmiesTab, setupComplete: setupComplete))
        .accessibilityIdentifier("guidedMatch.hubTab.\(tab.rawValue)")
    }

    private func label(for tab: GuidedMatchHubTab) -> String {
        if tab == .setup, setupTotal > 0, !setupComplete {
            return String(localized: "Setup \(setupCompleted)/\(setupTotal)")
        }
        return tab.title
    }

    @ViewBuilder
    private func nodeMark(_ tab: GuidedMatchHubTab, selected: Bool) -> some View {
        let done = isDone(tab)
        ZStack {
            Circle()
                .strokeBorder(done ? TTColor.success : (selected ? TTColor.brandFill : TTColor.stroke), lineWidth: 2)
                .frame(width: 28, height: 28)
            if done {
                Circle().fill(TTColor.success).frame(width: 28, height: 28)
                Image(systemName: "checkmark")
                    .font(TTFont.caption.weight(.bold))
                    .foregroundStyle(TTColor.inkOnPlayer)
            } else if selected {
                Circle().fill(TTColor.brandFill).frame(width: 12, height: 12)
            }
        }
        .accessibilityHidden(true)
    }

    private func isDone(_ tab: GuidedMatchHubTab) -> Bool {
        switch tab {
        case .armies: hasBothArmies && selection != .armies
        case .setup: setupComplete && selection == .battle
        case .battle: false
        }
    }
}

extension GuidedMatchHubTab {
    func isLocked(hasBothArmies: Bool, setupComplete: Bool, locksArmiesTab: Bool) -> Bool {
        switch self {
        case .armies: locksArmiesTab
        case .setup: !hasBothArmies
        case .battle: !hasBothArmies || !setupComplete
        }
    }

    func lockedMessage(hasBothArmies: Bool) -> String {
        switch self {
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

    func guidedMatchAccessibilityHint(locksArmiesTab: Bool, setupComplete: Bool) -> String {
        switch self {
        case .armies:
            if locksArmiesTab {
                String(localized: "Army selection is locked once a battle is in progress. Reset the match to change armies.")
            } else {
                String(localized: "Before the battle: pick both player armies or use starter matchup.")
            }
        case .setup:
            String(localized: "Mission, deployment, and pre-battle steps. Unlocks after both armies are chosen.")
        case .battle:
            if setupComplete {
                String(localized: "Turn phases, scoring, and unit health at the table.")
            } else {
                String(localized: "Unlocks after setup steps are complete.")
            }
        }
    }
}
