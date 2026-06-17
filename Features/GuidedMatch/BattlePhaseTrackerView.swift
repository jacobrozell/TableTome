import SwiftUI
import TabletomeDomain
import TabletomeData

struct BattlePhaseTrackerView: View {
    @StateObject private var viewModel: BattlePhaseTrackerViewModel
    @StateObject private var combatViewModel: UnitMatchupEvaluatorViewModel
    @StateObject private var multiAttackViewModel = MultiAttackEvaluatorViewModel()
    @AppStorage("diceInputMode") private var diceInputModeRaw = DiceInputMode.physical.rawValue
    @State private var showsCombatResolver = false
    @State private var showsAdvancedOptions = false
    @State private var showsMultiAttack = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let ruleSections: [RuleSection]

    init(matchState: GuidedMatchState, catalog: SpearheadCatalog, ruleSections: [RuleSection] = []) {
        _viewModel = StateObject(wrappedValue: BattlePhaseTrackerViewModel(matchState: matchState, catalog: catalog))
        _combatViewModel = StateObject(
            wrappedValue: UnitMatchupEvaluatorViewModel(
                catalogRepository: BundledSpearheadCatalogRepository(),
                attackerPrefill: Self.matchupPrefill(for: matchState.playerOne),
                defenderPrefill: Self.matchupPrefill(for: matchState.playerTwo)
            )
        )
        self.ruleSections = ruleSections
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                Group {
                    if horizontalSizeClass == .regular {
                        regularLayout
                    } else {
                        compactLayout
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .readableContentWidth()
                .padding(DesignTokens.Spacing.md)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .tabBarScrollInset()
            .onChange(of: viewModel.trackerState.currentPhase) { _, phase in
                if phase.isCombatRelated {
                    showsCombatResolver = true
                    withAnimation(.easeInOut(duration: 0.35)) {
                        proxy.scrollTo("combatResolver", anchor: .top)
                    }
                }
            }
        }
        .navigationTitle(String(localized: "Battle Tracker"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "Reset")) {
                    viewModel.resetTracker()
                }
                .accessibilityIdentifier("battleTracker.reset")
            }
        }
        .accessibilityIdentifier("battleTracker.screen")
        .task {
            await combatViewModel.load()
            syncCombatContext()
        }
        .onChange(of: viewModel.trackerState.activePlayerIsOne) { _, _ in
            syncCombatContext()
        }
        .onChange(of: diceInputModeRaw) { _, _ in
            combatViewModel.clearSimulatedRolls()
            multiAttackViewModel.clearSimulatedRolls()
        }
        .onChange(of: combatViewModel.enabledBuffIds) { _, _ in
            syncMultiAttack()
            combatViewModel.refreshEvaluation()
        }
        .onChange(of: combatViewModel.hitRoll) { _, _ in combatViewModel.refreshEvaluation() }
        .onChange(of: combatViewModel.woundRoll) { _, _ in combatViewModel.refreshEvaluation() }
        .onChange(of: combatViewModel.saveRoll) { _, _ in combatViewModel.refreshEvaluation() }
        .onChange(of: combatViewModel.wardRoll) { _, _ in combatViewModel.refreshEvaluation() }
        .onChange(of: combatViewModel.damage) { _, _ in combatViewModel.refreshEvaluation() }
        .onChange(of: combatViewModel.rollOptions) { _, _ in combatViewModel.refreshEvaluation() }
        .onChange(of: combatViewModel.attackerWeaponId) { _, _ in syncMultiAttack() }
        .onChange(of: combatViewModel.defenderUnitId) { _, _ in syncMultiAttack() }
    }

    private static func matchupPrefill(for player: PlayerArmySelection) -> MatchupUnitPrefill? {
        guard !player.armyId.isEmpty else { return nil }
        return MatchupUnitPrefill(armyId: player.armyId, unitId: "")
    }

    private func syncCombatContext() {
        combatViewModel.syncBattleContext(
            activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
            playerOneArmyId: viewModel.playerOneArmy?.id,
            playerTwoArmyId: viewModel.playerTwoArmy?.id
        )
    }

    private func syncMultiAttack() {
        guard let weapon = combatViewModel.selectedAttackerWeapon,
              let unit = combatViewModel.selectedAttackerUnit,
              let save = combatViewModel.selectedDefenderUnit?.save else { return }
        let mods = CombatMatchupBuffCatalog.aggregateModifiers(
            from: combatViewModel.matchupBuffs,
            enabledIds: combatViewModel.enabledBuffIds
        )
        multiAttackViewModel.apply(
            weapon: weapon,
            saveTarget: save,
            unitId: unit.id,
            wardTarget: combatViewModel.activeWardTarget
        )
        multiAttackViewModel.bind(weapon: weapon, unitId: unit.id)
        multiAttackViewModel.hitModifier = mods.hit
        multiAttackViewModel.woundModifier = mods.wound
        multiAttackViewModel.saveModifier = mods.save
        multiAttackViewModel.damage = combatViewModel.damage
    }

    private var compactLayout: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            guideSection
            roundAndScoreSection
            controlPanel
            combatResolverSection
            trackerContent
            deploymentSection
            bothLoadoutsSection
            woundTrackerSection
            gotchaSection
            loadoutSection
            referenceLinksSection
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var regularLayout: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                guideSection
                deploymentSection
                roundAndScoreSection
                controlPanel
                bothLoadoutsSection
                woundTrackerSection
                gotchaSection
                loadoutSection
                referenceLinksSection
            }
            .frame(minWidth: 0, maxWidth: DesignTokens.battleTrackerControlColumnMaxWidth, alignment: .leading)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                combatResolverSection
                trackerContent
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var guideSection: some View {
        if let step = viewModel.currentGuideStep {
            BattleGuideCard(step: step) {
                viewModel.completeCurrentGuideStep()
            }
        }
    }

    @ViewBuilder
    private var combatResolverSection: some View {
        if supportsBattleTracker {
            BattleTrackerCombatResolverSection(
                combatViewModel: combatViewModel,
                multiAttackViewModel: multiAttackViewModel,
                showsCombatResolver: $showsCombatResolver,
                diceInputModeRaw: $diceInputModeRaw,
                showsAdvancedOptions: $showsAdvancedOptions,
                showsMultiAttack: $showsMultiAttack,
                trackerState: viewModel.trackerState,
                attackerName: combatAttackerName,
                defenderName: combatDefenderName,
                deploymentIsComplete: deploymentIsComplete,
                ruleSections: ruleSections,
                onSyncMultiAttack: syncMultiAttack
            )
        }
    }

    private var combatAttackerName: String {
        viewModel.trackerState.activePlayerIsOne ? viewModel.playerOneName : viewModel.playerTwoName
    }

    private var combatDefenderName: String {
        viewModel.trackerState.activePlayerIsOne ? viewModel.playerTwoName : viewModel.playerOneName
    }

    private var deploymentIsComplete: Bool {
        DeploymentChecklist.completionCount(completedSteps: viewModel.trackerState.completedDeploymentSteps).done
            == DeploymentChecklistStep.allCases.count
    }

    @ViewBuilder
    private var deploymentSection: some View {
        if viewModel.trackerState.battleRound == 1, !deploymentIsComplete {
            RealmSideCoinFlipCard()
            DeploymentChecklistCard(
                completedSteps: viewModel.trackerState.completedDeploymentSteps,
                focusedStep: viewModel.focusedDeploymentStep,
                onToggle: viewModel.setDeploymentStep
            )
        }
    }

    private var referenceLinksSection: some View {
        VStack(spacing: 0) {
            NavigationLink {
                BattleTacticsReferenceView(ruleSections: ruleSections)
            } label: {
                referenceLinkLabel(String(localized: "Battle Tactics & Twists"), systemImage: "rectangle.stack")
            }
            .accessibilityIdentifier("battleTracker.battleTactics")

            Divider().padding(.leading, DesignTokens.Spacing.md)

            NavigationLink {
                RulesGlossaryView()
            } label: {
                referenceLinkLabel(String(localized: "Rules Glossary"), systemImage: "book.fill")
            }
            .accessibilityIdentifier("battleTracker.glossary")

            if let section = ruleSections.first(where: { $0.id == "spearhead-scoring" }) {
                Divider().padding(.leading, DesignTokens.Spacing.md)
                NavigationLink {
                    RuleSectionDetailView(section: section, allSections: ruleSections)
                } label: {
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

    private var roundAndScoreSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            RoundChecklistCard(
                round: viewModel.trackerState.battleRound,
                completedSteps: viewModel.trackerState.completedRoundChecklistSteps,
                focusedStep: viewModel.focusedRoundOpenerStep,
                onToggle: viewModel.setRoundChecklistStep
            )
            VictoryPointsCard(
                playerOneName: viewModel.playerOneName,
                playerTwoName: viewModel.playerTwoName,
                playerOneVP: viewModel.trackerState.playerOneVictoryPoints,
                playerTwoVP: viewModel.trackerState.playerTwoVictoryPoints,
                onAdjust: { viewModel.adjustVictoryPoints(playerIsOne: $0, delta: $1) },
                onQuickAdd: { viewModel.adjustVictoryPoints(playerIsOne: $0, delta: $1) }
            )
            if let underdogIsPlayerOne = viewModel.underdogIsPlayerOne {
                let name = underdogIsPlayerOne ? viewModel.playerOneName : viewModel.playerTwoName
                Label(String(localized: "Underdog: \(name)"), systemImage: "arrow.down.circle.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            }
        }
    }

    private var bothLoadoutsSection: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                if let army = viewModel.playerOneArmy {
                    LoadoutSummaryCard(
                        playerName: viewModel.playerOneName,
                        armyName: army.name,
                        regimentAbility: viewModel.playerOneRegimentAbility,
                        enhancement: viewModel.playerOneEnhancement,
                        isAttacker: viewModel.playerIsAttacker(isOne: true)
                    )
                }
                if let army = viewModel.playerTwoArmy {
                    LoadoutSummaryCard(
                        playerName: viewModel.playerTwoName,
                        armyName: army.name,
                        regimentAbility: viewModel.playerTwoRegimentAbility,
                        enhancement: viewModel.playerTwoEnhancement,
                        isAttacker: viewModel.playerIsAttacker(isOne: false)
                    )
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
    private var woundTrackerSection: some View {
        if supportsBattleTracker {
            DisclosureGroup {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    if let army = viewModel.playerOneArmy {
                        UnitWoundTrackerSection(
                            title: viewModel.playerOneName,
                            armyId: army.id,
                            units: army.units,
                            woundsRemaining: viewModel.trackerState.unitWoundsRemaining,
                            onChange: viewModel.setUnitWounds(key:remaining:)
                        )
                    }
                    if let army = viewModel.playerTwoArmy {
                        UnitWoundTrackerSection(
                            title: viewModel.playerTwoName,
                            armyId: army.id,
                            units: army.units,
                            woundsRemaining: viewModel.trackerState.unitWoundsRemaining,
                            onChange: viewModel.setUnitWounds(key:remaining:)
                        )
                    }
                }
                .padding(.top, DesignTokens.Spacing.sm)
            } label: {
                Label(String(localized: "Wound Tracker"), systemImage: "heart.fill")
                    .font(.headline)
            }
            .surfaceCard()
            .accessibilityIdentifier("battleTracker.woundTracker")
        }
    }

    @ViewBuilder
    private var gotchaSection: some View {
        if !viewModel.activeGotchas.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                SectionHeader(title: String(localized: "Army Reminders"), systemImage: "bolt.fill")
                ForEach(viewModel.activeGotchas) { gotcha in
                    ArmyGotchaCard(gotcha: gotcha)
                }
            }
        }
    }

    @ViewBuilder
    private var loadoutSection: some View {
        if let army = viewModel.activeArmy {
            LoadoutSummaryCard(
                playerName: viewModel.trackerState.activePlayerIsOne ? viewModel.playerOneName : viewModel.playerTwoName,
                armyName: army.name,
                regimentAbility: viewModel.activeRegimentAbility,
                enhancement: viewModel.activeEnhancement,
                isAttacker: viewModel.activePlayerIsAttacker
            )
            if army.units.contains(where: \.hasWarscroll) {
                NavigationLink {
                    ArmyRosterView(army: army, ruleSections: ruleSections)
                } label: {
                    Label(String(localized: "View Warscrolls"), systemImage: "doc.richtext")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: DesignTokens.minTouchTarget)
                }
                .accessibilityIdentifier("battleTracker.warscrolls")
            }
        }
    }

    @ViewBuilder
    private var trackerContent: some View {
        if !supportsBattleTracker {
            emptyState
        } else {
            abilitySections
        }
    }

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Stepper(
                String(localized: "Round \(viewModel.trackerState.battleRound)"),
                value: Binding(
                    get: { viewModel.trackerState.battleRound },
                    set: { viewModel.setBattleRound($0) }
                ),
                in: 1...4
            )
            .accessibilityIdentifier("battleTracker.round")

            Picker(String(localized: "Active Player"), selection: Binding(
                get: { viewModel.trackerState.activePlayerIsOne },
                set: { viewModel.setActivePlayer(isOne: $0) }
            )) {
                Text(viewModel.playerOneName)
                    .tag(true)
                Text(viewModel.playerTwoName)
                    .tag(false)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("battleTracker.activePlayer")

            Text(viewModel.armyName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            phaseControls
        }
    }

    private var phaseControls: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Current Phase"))
                .font(.headline)

            PhaseChipRow(
                phases: BattleTurnPhase.mainTurnPhases,
                selectedPhase: viewModel.trackerState.currentPhase,
                showAllAbilities: viewModel.trackerState.showAllAbilities
            ) { phase in
                viewModel.trackerState.showAllAbilities = false
                viewModel.setPhase(phase)
            }
            .accessibilityIdentifier("battleTracker.phasePicker")

            if !viewModel.specialPhases.isEmpty {
                PhaseChipRow(
                    phases: viewModel.specialPhases,
                    selectedPhase: viewModel.trackerState.currentPhase,
                    showAllAbilities: viewModel.trackerState.showAllAbilities,
                    style: .secondary
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

            Button {
                viewModel.advancePhase()
            } label: {
                Label(String(localized: "Next Phase"), systemImage: "arrow.right.circle.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderedProminent)
            .frame(minHeight: DesignTokens.minTouchTarget)
            .accessibilityIdentifier("battleTracker.nextPhase")
        }
        .surfaceCard()
    }

    @ViewBuilder
    private var abilitySections: some View {
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
                        showsRollTools: false
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

    private var supportsBattleTracker: Bool {
        viewModel.contentCoverage >= .battleTracker
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Battle tracker isn't available for this army yet."))
                .font(.headline)
            Text(
                "Ability reminders for this army aren't in Tabletome yet. Use the GW Spearhead PDF link on the army picker for full rules."
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard()
    }
}
