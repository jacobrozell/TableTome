import SwiftUI
import TabletomeDomain

// swiftlint:disable:next type_body_length
struct MatchStepDetailView: View {
    let step: MatchSetupStep
    let stepNumber: Int
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var usesSideBySideColumns: Bool {
        TabletomeLayout.usesSideBySideLayout(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass,
            isAccessibilitySize: dynamicTypeSize.needsLayoutAdaptation
        )
    }

    private var isComplete: Bool {
        viewModel.matchState.completedStepIds.contains(step.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(step.body)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                GlossaryChipsRow(text: step.body, gameSystemId: viewModel.gameSystemId.rawValue, ruleSections: ruleSections)

                SetupStepRulesLink(
                    gameSystemId: viewModel.gameSystemId.rawValue,
                    stepTitle: step.title,
                    relatedRuleSectionId: step.relatedRuleSectionId
                )

                stepSpecificContent

                if let relatedSection {
                    ReferenceLinksGroup {
                        NavigationLink(value: RuleSectionLink(
                            gameSystemId: viewModel.gameSystemId.rawValue,
                            sectionId: relatedSection.id
                        )) {
                            ReferenceLinkRow(title: relatedSection.title, systemImage: "doc.text")
                        }
                        .accessibilityLabel(String(localized: "Related rule: \(relatedSection.title)"))
                        .accessibilityIdentifier("guidedMatch.relatedRule.\(step.id)")
                    }
                }

                if !step.tips.isEmpty {
                    TipsCard(tips: step.tips)
                }

                stepCompletionStatus
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .tabBarScrollInset()
        .navigationTitle(step.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.syncAutoCompletions()
        }
    }

    @ViewBuilder
    private var stepCompletionStatus: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isComplete ? .green : .secondary)
                Text(completionHint)
                    .font(.subheadline)
                    .foregroundStyle(isComplete ? .primary : .secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if usesManualConfirmation, !isComplete {
                Button(String(localized: "Mark step complete")) {
                    viewModel.setStepComplete(step.id, complete: true)
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("guidedMatch.markComplete.\(step.id)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .surfaceCard()
        .accessibilityIdentifier("guidedMatch.stepComplete.\(step.id)")
    }

    private var completionHint: String {
        if isComplete {
            return String(localized: "Step complete")
        }
        if step.id == "pick-enhancement" {
            return String(
                localized: "Tap Use recommended defaults, or pick one Enhancement and one Secondary for each player."
            )
        }
        if usesManualConfirmation {
            return String(localized: "Tap below when you've finished this step.")
        }
        return String(localized: "Complete the actions above — this step checks off automatically.")
    }

    private var usesManualConfirmation: Bool {
        viewModel.gameSystemId == .scTmg
            && ["battle-format", "mission-setup", "confirm-lists"].contains(step.id)
    }

    @ViewBuilder
    private var stepSpecificContent: some View {
        switch step.id {
        case "choose-armies":
            matchupCard
        case "roll-attacker":
            attackerPicker
        case "regiment-abilities", "force-disposition":
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                armyOptionsSection(
                    title: viewModel.gameSystemId == .wh40k11e
                        ? String(localized: "Force Dispositions")
                        : String(localized: "Regiment Abilities"),
                    playerOneKeyPath: \.regimentAbilityId,
                    playerTwoKeyPath: \.regimentAbilityId,
                    options: { army in army.regimentAbilities },
                    onSelect: viewModel.setRegimentAbility
                )
                loadoutSummarySection(showRegiment: true, showEnhancement: false)
            }
        case "enhancements":
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                recommendedDefaultsControls

                armyOptionsSection(
                    title: String(localized: "Enhancements"),
                    playerOneKeyPath: \.enhancementId,
                    playerTwoKeyPath: \.enhancementId,
                    options: { army in army.enhancements },
                    onSelect: viewModel.setEnhancement
                )

                if viewModel.gameSystemId == .aosSpearhead {
                    spearheadBattleTacticsSection
                }

                if viewModel.eitherArmyHasSecondaryObjectives {
                    armyOptionsSection(
                        title: String(localized: "Secondary Objectives"),
                        playerOneKeyPath: \.secondaryObjectiveId,
                        playerTwoKeyPath: \.secondaryObjectiveId,
                        options: { army in army.secondaryObjectives },
                        onSelect: viewModel.setSecondaryObjective
                    )
                }

                loadoutSummarySection(
                    showRegiment: true,
                    showEnhancement: true,
                    showSecondary: viewModel.eitherArmyHasSecondaryObjectives
                )
            }
        case "pick-enhancement":
            combatPatrolLoadoutSection
        case "determine-mission":
            combatPatrolMissionSection
        case "setup-battlefield":
            combatPatrolSetupBattlefieldSection
        case "declare-formations":
            combatPatrolFormationsSection
        case "deploy-armies":
            combatPatrolDeploySection
        case "roll-first-turn":
            combatPatrolFirstTurnSection
        case "realm-battlefield":
            deploymentSetupSection
        case "deploy-battlefield":
            wh40kDeploymentSetupSection
        case "battlefield-setup":
            if viewModel.gameSystemId == .scTmg {
                scTmgBattlefieldSetupSection
            }
        case "battle-format", "mission-setup", "confirm-lists":
            if viewModel.gameSystemId == .scTmg {
                scTmgManualConfirmSection
            }
        case "fight-battle":
            battleStartLinks
        default:
            EmptyView()
        }
    }

    private var spearheadBattleTacticsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(
                String(
                    localized: """
                    Each player shuffles the battle tactic deck from their own army box — not the shared twist deck from the battlefield pack.
                    """
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            ReferenceLinksGroup {
                NavigationLink(value: BattleTacticsReferenceLink(gameSystemId: viewModel.gameSystemId.rawValue)) {
                    ReferenceLinkRow(
                        title: String(localized: "Battle Tactics & Twists"),
                        systemImage: "rectangle.stack"
                    )
                }
                .accessibilityIdentifier("guidedMatch.enhancements.battleTactics")
            }
        }
    }

    private var wh40kDeploymentSetupSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Wh40kDeploymentNowCard()

            Wh40kDeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedStep: Wh40kDeploymentChecklistStep.allCases.first {
                    !Wh40kDeploymentChecklist.isComplete(step: $0, completedSteps: viewModel.deploymentCompletedSteps)
                },
                onToggle: viewModel.setWh40kDeploymentStep,
                gameSystemId: viewModel.gameSystemId.rawValue,
                ruleSections: ruleSections
            )

            if let terrainSection = ruleSections.first(where: { $0.id == "11e-terrain-objectives" }) {
                ReferenceLinksGroup {
                    NavigationLink(value: RuleSectionLink(
                        gameSystemId: viewModel.gameSystemId.rawValue,
                        sectionId: terrainSection.id
                    )) {
                        ReferenceLinkRow(
                            title: terrainSection.title,
                            systemImage: "map"
                        )
                    }
                    .accessibilityIdentifier("guidedMatch.wh40kDeployment.terrainReference")
                }
            }
        }
    }

    private var combatPatrolLoadoutSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            recommendedDefaultsControls

            armyOptionsSection(
                title: String(localized: "Enhancements"),
                playerOneKeyPath: \.enhancementId,
                playerTwoKeyPath: \.enhancementId,
                options: { army in army.enhancements },
                onSelect: viewModel.setEnhancement
            )
            armyOptionsSection(
                title: String(localized: "Secondary Objectives"),
                playerOneKeyPath: \.secondaryObjectiveId,
                playerTwoKeyPath: \.secondaryObjectiveId,
                options: { army in army.secondaryObjectives },
                onSelect: viewModel.setSecondaryObjective
            )
            loadoutSummarySection(showRegiment: false, showEnhancement: true, showSecondary: true)
        }
    }

    @ViewBuilder
    private var recommendedDefaultsControls: some View {
        if viewModel.matchState.hasBothArmies {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Button(String(localized: "Use recommended defaults")) {
                    viewModel.applyRecommendedLoadouts()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("guidedMatch.applyRecommendedDefaults")

                Text(
                    String(
                        localized: "Fills enhancement and objective picks recommended for newcomers."
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var combatPatrolMissionSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if let catalog = viewModel.catalog {
                CombatPatrolMissionPickerCard(
                    missions: catalog.missions,
                    selectedMissionId: viewModel.matchState.selectedMissionId,
                    onSelect: viewModel.setSelectedMission
                )
            }
            if let mission = viewModel.catalog.flatMap({ viewModel.selectedMission(in: $0) }) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text(mission.primaryObjectiveSummary)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    if let notes = mission.scoringNotes {
                        Text(notes)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .surfaceCard()
            }
        }
    }

    private var combatPatrolSetupBattlefieldSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            CombatPatrolDeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedSteps: [.setupTerrain, .placeObjectives, .attackerDefender],
                onToggle: viewModel.setCombatPatrolDeploymentStep
            )
            AttackerDefenderPickerCard(
                playerOneName: viewModel.matchState.playerOne.playerName,
                playerTwoName: viewModel.matchState.playerTwo.playerName,
                attackerIsPlayerOne: viewModel.matchState.attackerIsPlayerOne,
                onSelect: viewModel.setAttacker,
                title: String(localized: "Who is the attacker?"),
                decidedCaption: { isPlayerOne in
                    let attacker = isPlayerOne
                        ? viewModel.matchState.playerOne.playerName
                        : viewModel.matchState.playerTwo.playerName
                    let defender = isPlayerOne
                        ? viewModel.matchState.playerTwo.playerName
                        : viewModel.matchState.playerOne.playerName
                    return String(
                        localized: "\(attacker) uses the Attacker deployment zone. \(defender) uses the Defender zone."
                    )
                }
            )
        }
    }

    private var combatPatrolFormationsSection: some View {
        CombatPatrolDeploymentChecklistCard(
            completedSteps: viewModel.deploymentCompletedSteps,
            focusedSteps: [.declareFormations],
            onToggle: viewModel.setCombatPatrolDeploymentStep
        )
    }

    private var combatPatrolDeploySection: some View {
        CombatPatrolDeploymentChecklistCard(
            completedSteps: viewModel.deploymentCompletedSteps,
            focusedSteps: [.deployArmies],
            onToggle: viewModel.setCombatPatrolDeploymentStep
        )
    }

    private var combatPatrolFirstTurnSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            FirstTurnPickerCard(
                playerOneName: viewModel.matchState.playerOne.playerName,
                playerTwoName: viewModel.matchState.playerTwo.playerName,
                firstTurnIsPlayerOne: viewModel.matchState.firstTurnIsPlayerOne,
                onSelect: viewModel.setFirstTurn
            )
            CombatPatrolDeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedSteps: [.rollFirstTurn],
                onToggle: viewModel.setCombatPatrolDeploymentStep
            )
        }
    }

    private var scTmgBattlefieldSetupSection: some View {
        ScTmgDeploymentChecklistCard(
            completedSteps: viewModel.deploymentCompletedSteps,
            focusedStep: BattleFlowGuide.nextIncompleteScTmgSetupStep(
                in: viewModel.deploymentCompletedSteps
            ),
            onToggle: viewModel.setScTmgDeploymentStep
        )
    }

    @ViewBuilder
    private var scTmgManualConfirmSection: some View {
        EmptyView()
    }

    private var deploymentSetupSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            RealmSideCoinFlipCard()
            DeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedStep: BattleFlowGuide.nextIncompleteDeploymentStep(
                    in: viewModel.deploymentCompletedSteps
                ),
                onToggle: viewModel.setDeploymentStep
            )
            ReferenceLinksGroup {
                NavigationLink(value: BattleTacticsReferenceLink(gameSystemId: viewModel.gameSystemId.rawValue)) {
                    ReferenceLinkRow(
                        title: String(localized: "Card Decks Guide"),
                        systemImage: "rectangle.stack"
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var battleStartLinks: some View {
        if viewModel.gameSystemId == .wh40k11e || viewModel.gameSystemId == .scTmg || viewModel.gameSystemId == .wh40k10eCp {
            EmptyView()
        } else {
            ReferenceLinksGroup {
                NavigationLink(value: BattleTacticsReferenceLink(gameSystemId: viewModel.gameSystemId.rawValue)) {
                    ReferenceLinkRow(
                        title: String(localized: "Card Decks Guide"),
                        systemImage: "rectangle.stack"
                    )
                }
            }
        }
    }

    private var matchupCard: some View {
        Group {
            if viewModel.matchState.hasBothArmies, let summary = viewModel.matchupSummary {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    SectionHeader(title: String(localized: "Selected Matchup"), systemImage: "person.2.fill")
                    Text(summary)
                        .font(.subheadline.weight(.medium))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .surfaceCard()
            }
        }
    }

    private var attackerPicker: some View {
        AttackerDefenderPickerCard(
            playerOneName: viewModel.matchState.playerOne.playerName,
            playerTwoName: viewModel.matchState.playerTwo.playerName,
            attackerIsPlayerOne: viewModel.matchState.attackerIsPlayerOne,
            onSelect: viewModel.setAttacker
        )
    }

    private func loadoutSummarySection(
        showRegiment: Bool,
        showEnhancement: Bool,
        showSecondary: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: String(localized: "Loadout Summary"), systemImage: "tray.full")

            if usesSideBySideColumns {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                    playerLoadoutCard(
                        player: viewModel.matchState.playerOne,
                        isAttacker: viewModel.matchState.attackerIsPlayerOne == true,
                        showRegiment: showRegiment,
                        showEnhancement: showEnhancement,
                        showSecondary: showSecondary
                    )
                    playerLoadoutCard(
                        player: viewModel.matchState.playerTwo,
                        isAttacker: viewModel.matchState.attackerIsPlayerOne == false,
                        showRegiment: showRegiment,
                        showEnhancement: showEnhancement,
                        showSecondary: showSecondary
                    )
                }
            } else {
                playerLoadoutCard(
                    player: viewModel.matchState.playerOne,
                    isAttacker: viewModel.matchState.attackerIsPlayerOne == true,
                    showRegiment: showRegiment,
                    showEnhancement: showEnhancement,
                    showSecondary: showSecondary
                )
                playerLoadoutCard(
                    player: viewModel.matchState.playerTwo,
                    isAttacker: viewModel.matchState.attackerIsPlayerOne == false,
                    showRegiment: showRegiment,
                    showEnhancement: showEnhancement,
                    showSecondary: showSecondary
                )
            }
        }
    }

    private func playerLoadoutCard(
        player: PlayerArmySelection,
        isAttacker: Bool,
        showRegiment: Bool,
        showEnhancement: Bool,
        showSecondary: Bool = false
    ) -> some View {
        LoadoutSummaryCard(
            playerName: player.playerName,
            armyName: viewModel.armyName(for: player) ?? String(localized: "No army selected"),
            regimentAbility: showRegiment ? viewModel.regimentAbility(for: player) : nil,
            enhancement: showEnhancement ? viewModel.enhancement(for: player) : nil,
            secondaryObjective: showSecondary ? viewModel.secondaryObjective(for: player) : nil,
            battleTacticDeckName: viewModel.battleTacticDeckName(for: player),
            isAttacker: isAttacker
        )
    }

    private func armyOptionsSection(
        title: String,
        playerOneKeyPath: KeyPath<PlayerArmySelection, String?>,
        playerTwoKeyPath: KeyPath<PlayerArmySelection, String?>,
        options: (SpearheadArmy) -> [ArmyRuleOption],
        onSelect: @escaping (Bool, String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            SectionHeader(title: title, systemImage: "list.bullet")

            if usesSideBySideColumns {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                    playerOptionPicker(
                        player: viewModel.matchState.playerOne,
                        selectedId: viewModel.matchState.playerOne[keyPath: playerOneKeyPath],
                        isAttacker: viewModel.matchState.attackerIsPlayerOne == true,
                        playerIsOne: true,
                        options: options,
                        onSelect: onSelect
                    )
                    playerOptionPicker(
                        player: viewModel.matchState.playerTwo,
                        selectedId: viewModel.matchState.playerTwo[keyPath: playerTwoKeyPath],
                        isAttacker: viewModel.matchState.attackerIsPlayerOne == false,
                        playerIsOne: false,
                        options: options,
                        onSelect: onSelect
                    )
                }
            } else {
                playerOptionPicker(
                    player: viewModel.matchState.playerOne,
                    selectedId: viewModel.matchState.playerOne[keyPath: playerOneKeyPath],
                    isAttacker: viewModel.matchState.attackerIsPlayerOne == true,
                    playerIsOne: true,
                    options: options,
                    onSelect: onSelect
                )

                playerOptionPicker(
                    player: viewModel.matchState.playerTwo,
                    selectedId: viewModel.matchState.playerTwo[keyPath: playerTwoKeyPath],
                    isAttacker: viewModel.matchState.attackerIsPlayerOne == false,
                    playerIsOne: false,
                    options: options,
                    onSelect: onSelect
                )
            }
        }
    }

    private func playerOptionPicker(
        player: PlayerArmySelection,
        selectedId: String?,
        isAttacker: Bool,
        playerIsOne: Bool,
        options: (SpearheadArmy) -> [ArmyRuleOption],
        onSelect: @escaping (Bool, String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Text(player.playerName)
                    .font(.headline)
                if isAttacker {
                    Text(String(localized: "Attacker — picks first"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, DesignTokens.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.12), in: Capsule())
                }
            }

            if let army = viewModel.army(factionId: player.factionId, armyId: player.armyId) {
                let armyOptions = options(army)
                if armyOptions.isEmpty {
                    Text(emptyArmyOptionsMessage)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(armyOptions) { option in
                        Button {
                            onSelect(playerIsOne, option.id)
                        } label: {
                            ArmyRuleOptionCard(
                                option: option,
                                isSelected: selectedId == option.id,
                                gameSystemId: viewModel.gameSystemId.rawValue,
                                ruleSections: ruleSections
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selectedId == option.id ? .isSelected : [])
                        .accessibilityIdentifier("guidedMatch.option.\(option.id)")
                    }
                }
            }
        }
        .surfaceCard()
    }

    private var relatedSection: RuleSection? {
        guard let sectionId = step.relatedRuleSectionId else { return nil }
        return ruleSections.first { $0.id == sectionId }
    }

    private var emptyArmyOptionsMessage: String {
        switch viewModel.gameSystemId {
        case .wh40k11e:
            String(localized: "See your Munitorum Field Manual and box datasheets for detachment options.")
        case .wh40k10eCp:
            String(localized: "Choose from the options below — defaults are marked Recommended.")
        case .scTmg:
            String(localized: "Founders Edition armies ship as fixed lists — no extra options to pick.")
        default:
            String(localized: "See your faction's free Spearhead download for regiment and enhancement options.")
        }
    }
}
