import SwiftUI
import TabletomeDomain

struct BattleTrackerReferenceLinksSection: View {
    let ruleSections: [RuleSection]
    var gameSystemId: GameSystemId = .default

    init(ruleSections: [RuleSection], gameSystemId: GameSystemId = .default) {
        self.ruleSections = ruleSections
        self.gameSystemId = gameSystemId
    }

    init(ruleSections: [RuleSection], gameSystemId: String) {
        self.init(ruleSections: ruleSections, gameSystemId: GameSystemId(resolving: gameSystemId))
    }

    private var capabilities: PlayCapabilities {
        GameSystemPlayContext.context(for: gameSystemId).capabilities
    }

    var body: some View {
        VStack(spacing: 0) {
            if capabilities.showsBattleTacticDecks {
                NavigationLink(value: BattleTacticsReferenceLink(gameSystemId: gameSystemId.rawValue)) {
                    referenceLinkLabel(String(localized: "Card Decks Guide"), systemImage: "rectangle.stack")
                }
                .accessibilityIdentifier("battleTracker.battleTactics")

                Divider().padding(.leading, DesignTokens.Spacing.md)
            }

            NavigationLink(value: RulesGlossaryBrowseLink(gameSystemId: gameSystemId.rawValue)) {
                referenceLinkLabel(
                    GameSystemRulesLabels.glossaryTitle(gameSystemId: gameSystemId),
                    systemImage: "book.fill"
                )
            }
            .accessibilityIdentifier("battleTracker.glossary")

            if let scoringId = capabilities.scoringRuleSectionId,
               let section = ruleSections.first(where: { $0.id == scoringId }) {
                Divider().padding(.leading, DesignTokens.Spacing.md)
                NavigationLink(value: RuleSectionLink(gameSystemId: gameSystemId.rawValue, sectionId: section.id)) {
                    referenceLinkLabel(section.title, systemImage: "doc.text")
                }
                .accessibilityIdentifier("battleTracker.scoringRules")
            }
        }
        .surfaceCard(padding: 0)
    }

    private func referenceLinkLabel(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignTokens.Spacing.md)
            .frame(minHeight: DesignTokens.minTouchTarget)
    }
}

struct BattleTrackerBothRostersSection: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let playerIsAttacker: (Bool) -> Bool

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                rosterColumn(
                    playerName: playerOneName,
                    army: playerOneArmy,
                    isAttacker: playerIsAttacker(true)
                )
                rosterColumn(
                    playerName: playerTwoName,
                    army: playerTwoArmy,
                    isAttacker: playerIsAttacker(false)
                )
            }
            .padding(.top, DesignTokens.Spacing.sm)
        } label: {
            Label(String(localized: "Army Rosters"), systemImage: "person.2.fill")
                .font(.headline)
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.bothRosters")
    }

    @ViewBuilder
    private func rosterColumn(playerName: String, army: SpearheadArmy?, isAttacker: Bool) -> some View {
        if let army {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    Text(playerName)
                        .font(.subheadline.weight(.semibold))
                    if isAttacker {
                        Text(String(localized: "Attacker"))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.accentOnSurface)
                            .padding(.horizontal, DesignTokens.Spacing.xs)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15), in: Capsule())
                    }
                }
                Text(army.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(army.roster, id: \.self) { unit in
                    Text(unit)
                        .font(.callout)
                }
            }
        }
    }
}

struct BattleTrackerBothLoadoutsSection: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let playerOneRegimentAbility: ArmyRuleOption?
    let playerTwoRegimentAbility: ArmyRuleOption?
    let playerOneEnhancement: ArmyRuleOption?
    let playerTwoEnhancement: ArmyRuleOption?
    var playerOneSecondary: ArmyRuleOption? = nil
    var playerTwoSecondary: ArmyRuleOption? = nil
    let playerIsAttacker: (Bool) -> Bool
    let ruleSections: [RuleSection]
    let gameSystemId: GameSystemId

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    init(
        playerOneName: String,
        playerTwoName: String,
        playerOneArmy: SpearheadArmy?,
        playerTwoArmy: SpearheadArmy?,
        playerOneRegimentAbility: ArmyRuleOption?,
        playerTwoRegimentAbility: ArmyRuleOption?,
        playerOneEnhancement: ArmyRuleOption?,
        playerTwoEnhancement: ArmyRuleOption?,
        playerOneSecondary: ArmyRuleOption? = nil,
        playerTwoSecondary: ArmyRuleOption? = nil,
        playerIsAttacker: @escaping (Bool) -> Bool,
        ruleSections: [RuleSection],
        gameSystemId: GameSystemId
    ) {
        self.playerOneName = playerOneName
        self.playerTwoName = playerTwoName
        self.playerOneArmy = playerOneArmy
        self.playerTwoArmy = playerTwoArmy
        self.playerOneRegimentAbility = playerOneRegimentAbility
        self.playerTwoRegimentAbility = playerTwoRegimentAbility
        self.playerOneEnhancement = playerOneEnhancement
        self.playerTwoEnhancement = playerTwoEnhancement
        self.playerOneSecondary = playerOneSecondary
        self.playerTwoSecondary = playerTwoSecondary
        self.playerIsAttacker = playerIsAttacker
        self.ruleSections = ruleSections
        self.gameSystemId = gameSystemId
    }

    init(
        playerOneName: String,
        playerTwoName: String,
        playerOneArmy: SpearheadArmy?,
        playerTwoArmy: SpearheadArmy?,
        playerOneRegimentAbility: ArmyRuleOption?,
        playerTwoRegimentAbility: ArmyRuleOption?,
        playerOneEnhancement: ArmyRuleOption?,
        playerTwoEnhancement: ArmyRuleOption?,
        playerOneSecondary: ArmyRuleOption? = nil,
        playerTwoSecondary: ArmyRuleOption? = nil,
        playerIsAttacker: @escaping (Bool) -> Bool,
        ruleSections: [RuleSection],
        gameSystemId: String
    ) {
        self.init(
            playerOneName: playerOneName,
            playerTwoName: playerTwoName,
            playerOneArmy: playerOneArmy,
            playerTwoArmy: playerTwoArmy,
            playerOneRegimentAbility: playerOneRegimentAbility,
            playerTwoRegimentAbility: playerTwoRegimentAbility,
            playerOneEnhancement: playerOneEnhancement,
            playerTwoEnhancement: playerTwoEnhancement,
            playerOneSecondary: playerOneSecondary,
            playerTwoSecondary: playerTwoSecondary,
            playerIsAttacker: playerIsAttacker,
            ruleSections: ruleSections,
            gameSystemId: GameSystemId(resolving: gameSystemId)
        )
    }

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                if let army = playerOneArmy {
                    LoadoutSummaryCard(
                        playerName: playerOneName,
                        armyName: army.name,
                        regimentAbility: playerOneRegimentAbility,
                        enhancement: playerOneEnhancement,
                        secondaryObjective: playerOneSecondary,
                        battleTacticDeckName: playContext.capabilities.showsBattleTacticDecks ? army.name : nil,
                        isAttacker: playerIsAttacker(true)
                    )
                    warscrollLink(for: army)
                }
                if let army = playerTwoArmy {
                    LoadoutSummaryCard(
                        playerName: playerTwoName,
                        armyName: army.name,
                        regimentAbility: playerTwoRegimentAbility,
                        enhancement: playerTwoEnhancement,
                        secondaryObjective: playerTwoSecondary,
                        battleTacticDeckName: playContext.capabilities.showsBattleTacticDecks ? army.name : nil,
                        isAttacker: playerIsAttacker(false)
                    )
                    warscrollLink(for: army)
                }
            }
            .padding(.top, DesignTokens.Spacing.sm)
        } label: {
            Label(String(localized: "Both Loadouts"), systemImage: "person.2.fill")
                .font(.headline)
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.bothLoadouts")
    }

    @ViewBuilder
    private func warscrollLink(for army: SpearheadArmy) -> some View {
        let showsRoster = usesCatalogUnitReference(for: army)
        if showsRoster {
            NavigationLink(value: ArmyRosterLink(gameSystemId: gameSystemId.rawValue, armyId: army.id)) {
                Label(
                    unitRosterLinkTitle,
                    systemImage: "doc.richtext"
                )
                    .font(.caption.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: DesignTokens.minTouchTarget)
            }
            .accessibilityIdentifier("battleTracker.warscrolls.\(army.id)")
        }
    }

    private func usesCatalogUnitReference(for army: SpearheadArmy) -> Bool {
        if playContext.usesGuidedBattleTracker || playContext.capabilities.usesPatrolFormatRules {
            return !army.units.isEmpty
        }
        return army.units.contains(where: \.hasWarscroll)
    }

    private var unitRosterLinkTitle: String {
        playContext.armyUnitRosterLinkTitle
    }
}

struct BattleTrackerControlPanel: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    var showsPhaseGuidanceInPicker: Bool = true
    var showsAdvancePhaseButton: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if viewModel.playContext.usesAlternatingActivation {
                ScActivationBar(
                    activePlayerName: viewModel.trackerState.activePlayerIsOne
                        ? viewModel.playerOneName
                        : viewModel.playerTwoName,
                    phase: viewModel.trackerState.currentPhase,
                    markerHolderName: viewModel.scFirstPlayerMarkerHolderName,
                    passClaimedByActivePlayer: viewModel.trackerState.scPhasePassClaimedByPlayerOne
                        == viewModel.trackerState.activePlayerIsOne,
                    onDone: viewModel.completeActivation,
                    onPass: viewModel.passActivation
                )
            }

            Stepper(
                viewModel.playContext.playEngine.roundLabel(round: viewModel.trackerState.battleRound),
                value: Binding(
                    get: { viewModel.trackerState.battleRound },
                    set: { viewModel.setBattleRound($0) }
                ),
                in: 1...viewModel.playContext.playEngine.battleRoundCount()
            )
            .accessibilityIdentifier("battleTracker.round")

            if viewModel.canAdvanceBattleRound {
                Button {
                    viewModel.advanceBattleRound()
                } label: {
                    Label(
                        String(
                            localized: "Start \(viewModel.playContext.playEngine.roundLabel(round: viewModel.trackerState.battleRound + 1))"
                        ),
                        systemImage: "arrow.up.circle.fill"
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .prominentButtonLabelStyle()
                }
                .buttonStyle(.borderedProminent)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("battleTracker.advanceRound")
            }

            BattleTrackerPlayerSwitcher(
                playerOneName: viewModel.playerOneName,
                playerTwoName: viewModel.playerTwoName,
                activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
                label: BattleTrackerPlayerSwitcher.label(
                    round: viewModel.trackerState.battleRound,
                    playerOneVictoryPoints: viewModel.trackerState.playerOneVictoryPoints,
                    playerTwoVictoryPoints: viewModel.trackerState.playerTwoVictoryPoints,
                    completedTurnsThisRound: viewModel.trackerState.completedTurnsThisRound.count,
                    roundOpenerIncomplete: viewModel.roundOpenerIsIncomplete
                ),
                onSelect: { viewModel.setActivePlayer(isOne: $0) }
            )

            AttackerDefenderPickerCard(
                playerOneName: viewModel.playerOneName,
                playerTwoName: viewModel.playerTwoName,
                attackerIsPlayerOne: viewModel.attackerIsPlayerOne,
                onSelect: viewModel.setAttacker,
                accessibilityPrefix: "battleTracker"
            )

            if viewModel.playContext.capabilities.usesPatrolFormatRules,
               viewModel.trackerState.battleRound == 1 {
                FirstTurnPickerCard(
                    playerOneName: viewModel.playerOneName,
                    playerTwoName: viewModel.playerTwoName,
                    firstTurnIsPlayerOne: viewModel.matchState.firstTurnIsPlayerOne,
                    onSelect: viewModel.setFirstTurn
                )
            }

            Text(viewModel.armyName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            BattleTrackerPhaseControls(
                viewModel: viewModel,
                showsPhaseGuidance: showsPhaseGuidanceInPicker,
                showsAdvancePhaseButton: showsAdvancePhaseButton
            )
                .id("phaseControls")
        }
    }
}

private struct BattleTrackerPhaseControls: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    var showsPhaseGuidance: Bool = true
    var showsAdvancePhaseButton: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Current Phase"))
                .font(.headline)

            PhaseChipRow(
                phases: viewModel.playContext.playEngine.mainPhases(),
                selectedPhase: viewModel.trackerState.currentPhase,
                showAllAbilities: viewModel.trackerState.showAllAbilities,
                showsPhaseGuidance: showsPhaseGuidance,
                gameSystemId: viewModel.gameSystemId
            ) { phase in
                viewModel.trackerState.showAllAbilities = false
                viewModel.setPhase(phase)
            }
            .accessibilityIdentifier("battleTracker.phasePicker")

            if !viewModel.playContext.usesAlternatingActivation {
                if !viewModel.specialPhases.isEmpty {
                    PhaseChipRow(
                        phases: viewModel.specialPhases,
                        selectedPhase: viewModel.trackerState.currentPhase,
                        showAllAbilities: viewModel.trackerState.showAllAbilities,
                        style: .secondary,
                        gameSystemId: viewModel.gameSystemId
                    ) { phase in
                        viewModel.trackerState.showAllAbilities = false
                        viewModel.setPhase(phase)
                    }
                }

                Toggle(String(localized: "Show all abilities"), isOn: Binding(
                    get: { viewModel.trackerState.showAllAbilities },
                    set: { _ in viewModel.toggleShowAll() }
                ))
                .accessibilityIdentifier("battleTracker.showAll")
            }

            if showsAdvancePhaseButton {
                Button {
                    viewModel.advanceTurnOrPhase()
                } label: {
                    Label(String(localized: "Next Phase"), systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .prominentButtonLabelStyle()
                }
                .buttonStyle(.borderedProminent)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("battleTracker.nextPhase")
            }
        }
        .surfaceCard()
    }
}

struct BattleTrackerAbilitySections: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    let ruleSections: [RuleSection]
    var showsEmbeddedCombatTools: Bool = true
    let onResolveAttack: (TriggeredAbility) -> Void

    var body: some View {
        if viewModel.activeAbilities.isEmpty && !viewModel.trackerState.showAllAbilities {
            Text(String(localized: "No triggered abilities in this phase. Check passives below or advance to the next phase."))
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                SectionHeader(
                    title: viewModel.trackerState.showAllAbilities
                        ? String(localized: "All Abilities")
                        : String(localized: "Available Now")
                )

                ForEach(viewModel.activeAbilities) { ability in
                    UnitAbilityCard(
                        ability: ability,
                        phase: viewModel.trackerState.currentPhase,
                        isUsed: viewModel.isUsed(ability),
                        onMarkUsed: ability.usageLimit == .oncePerBattle ? { viewModel.markUsed(ability) } : nil,
                        ruleSections: ruleSections,
                        showsRollTools: false,
                        showsEmbeddedCombatTools: showsEmbeddedCombatTools,
                        onResolveAttack: { onResolveAttack(ability) }
                    )
                }
            }
        }

        if !viewModel.passiveAbilities.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                SectionHeader(title: String(localized: "Always On"), systemImage: "infinity")

                ForEach(viewModel.passiveAbilities) { ability in
                    UnitAbilityCard(
                        ability: ability,
                        phase: viewModel.trackerState.currentPhase,
                        isUsed: false,
                        onMarkUsed: nil,
                        ruleSections: ruleSections,
                        showsRollTools: false
                    )
                }
            }
        }
    }
}

/// Pre-battle and start-of-round checklist — belongs on the Setup tab.
struct BattleTrackerRoundOpenerSection: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if viewModel.playContext.capabilities.showsRoundChecklist {
                RoundChecklistCard(
                    round: viewModel.trackerState.battleRound,
                    completedSteps: viewModel.trackerState.completedRoundChecklistSteps,
                    focusedStep: viewModel.focusedRoundOpenerStep,
                    playerOneName: viewModel.playerOneName,
                    playerTwoName: viewModel.playerTwoName,
                    attackerName: viewModel.attackerDisplayName,
                    firstTurnIsPlayerOne: viewModel.matchState.firstTurnIsPlayerOne,
                    onSelectFirstTurn: { playerIsOne in
                        if viewModel.trackerState.battleRound == 1 {
                            viewModel.correctRoundOneFirstTurn(isPlayerOne: playerIsOne)
                        } else {
                            viewModel.setRoundFirstTurn(isPlayerOne: playerIsOne)
                        }
                    },
                    onToggle: viewModel.setRoundChecklistStep
                )
            }
            if viewModel.playContext.capabilities.usesPatrolFormatRules {
                CombatPatrolTableStateCard(
                    mission: viewModel.selectedMission,
                    playerOneName: viewModel.playerOneName,
                    playerTwoName: viewModel.playerTwoName,
                    playerOneArmy: viewModel.playerOneArmy,
                    playerTwoArmy: viewModel.playerTwoArmy,
                    playerOneSecondary: viewModel.playerOneSecondary,
                    playerTwoSecondary: viewModel.playerTwoSecondary,
                    activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
                    battleRound: viewModel.trackerState.battleRound,
                    currentPhase: viewModel.trackerState.currentPhase,
                    playerOneBattleReady: battleReadyBinding(isPlayerOne: true),
                    playerTwoBattleReady: battleReadyBinding(isPlayerOne: false),
                    securedObjectiveIds: securedBinding,
                    usedStratagemIds: stratagemBinding,
                    intelRecoveredObjectiveIds: intelBinding,
                    onApplyBattleReadyBonus: viewModel.applyBattleReadyBonus
                )
            }
        }
    }

    private func battleReadyBinding(isPlayerOne: Bool) -> Binding<Bool?> {
        Binding(
            get: { isPlayerOne ? viewModel.trackerState.playerOneBattleReady : viewModel.trackerState.playerTwoBattleReady },
            set: { viewModel.setBattleReady(isPlayerOne: isPlayerOne, value: $0) }
        )
    }

    private var securedBinding: Binding<Set<String>> {
        Binding(
            get: { viewModel.trackerState.securedObjectiveIds },
            set: { viewModel.setSecuredObjectiveIds($0) }
        )
    }

    private var stratagemBinding: Binding<Set<String>> {
        Binding(
            get: { viewModel.trackerState.usedStratagemIds },
            set: { viewModel.setUsedStratagemIds($0) }
        )
    }

    private var intelBinding: Binding<Set<String>> {
        Binding(
            get: { viewModel.trackerState.intelRecoveredObjectiveIds },
            set: { viewModel.setIntelRecoveredObjectiveIds($0) }
        )
    }
}

/// Ongoing match score — Turn tab after deployment; phase dock Score shortcut when enabled.
struct BattleTrackerVictoryPointsSection: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if !viewModel.playContext.usesAlternatingActivation, viewModel.trackerState.currentPhase != .deployment {
                BattleRoundTurnProgressChip(
                    round: viewModel.trackerState.battleRound,
                    playerOneName: viewModel.playerOneName,
                    playerTwoName: viewModel.playerTwoName,
                    completedTurnPlayerOnes: viewModel.trackerState.completedTurnsThisRound,
                    activePlayerIsOne: viewModel.trackerState.activePlayerIsOne
                )
            }

            VictoryPointsCard(
                playerOneName: viewModel.playerOneName,
                playerTwoName: viewModel.playerTwoName,
                playerOneVP: viewModel.trackerState.playerOneVictoryPoints,
                playerTwoVP: viewModel.trackerState.playerTwoVictoryPoints,
                battleRound: viewModel.trackerState.battleRound,
                maxBattleRounds: viewModel.playContext.playEngine.battleRoundCount(),
                victoryPointsByRound: viewModel.trackerState.victoryPointsByRound,
                activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
                completedTurnPlayerOnes: viewModel.trackerState.completedTurnsThisRound,
                scoreLeaderIsPlayerOne: viewModel.scoreLeaderIsPlayerOne,
                highlightsScoring: viewModel.trackerState.currentPhase == (viewModel.playContext.capabilities.showsActivationBar ? .scoring : .endOfTurn),
                gameSystemId: viewModel.gameSystemId,
                defaultsExpandedPerTurnBreakdown: viewModel.gameSystemId == .aosSpearhead,
                onAdjust: { viewModel.adjustVictoryPoints(playerIsOne: $0, delta: $1, reason: $2) },
                onQuickAdd: { viewModel.adjustVictoryPoints(playerIsOne: $0, delta: $1, reason: $2) },
                onSetRoundVictoryPoints: { viewModel.setRoundVictoryPoints(playerIsOne: $1, round: $0, value: $2) },
                turnIsComplete: { viewModel.turnIsComplete(round: $0, playerIsOne: $1) },
                turnIsActive: { viewModel.turnIsActive(round: $0, playerIsOne: $1) }
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            if let underdogIsPlayerOne = viewModel.underdogIsPlayerOne,
               viewModel.playContext.capabilities.showsBattleTacticDecks {
                let name = underdogIsPlayerOne ? viewModel.playerOneName : viewModel.playerTwoName
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "Underdog this round"))
                            .font(.caption.weight(.semibold))
                        Text(name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            }
        }
    }
}
