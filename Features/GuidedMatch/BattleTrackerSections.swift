import SwiftUI
import TabletomeDomain

struct BattleTrackerReferenceLinksSection: View {
    let ruleSections: [RuleSection]

    var body: some View {
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
    let playerIsAttacker: (Bool) -> Bool
    let ruleSections: [RuleSection]

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                if let army = playerOneArmy {
                    LoadoutSummaryCard(
                        playerName: playerOneName,
                        armyName: army.name,
                        regimentAbility: playerOneRegimentAbility,
                        enhancement: playerOneEnhancement,
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
        if army.units.contains(where: \.hasWarscroll) {
            NavigationLink {
                ArmyRosterView(army: army, ruleSections: ruleSections)
            } label: {
                Label(String(localized: "View Warscrolls"), systemImage: "doc.richtext")
                    .font(.caption.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: DesignTokens.minTouchTarget)
            }
            .accessibilityIdentifier("battleTracker.warscrolls.\(army.id)")
        }
    }
}

struct BattleTrackerWoundTrackerSection: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let woundsRemaining: [String: Int]
    let onChange: (String, Int) -> Void

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                if let army = playerOneArmy {
                    UnitWoundTrackerSection(
                        title: playerOneName,
                        armyId: army.id,
                        units: army.units,
                        woundsRemaining: woundsRemaining,
                        onChange: onChange
                    )
                }
                if let army = playerTwoArmy {
                    UnitWoundTrackerSection(
                        title: playerTwoName,
                        armyId: army.id,
                        units: army.units,
                        woundsRemaining: woundsRemaining,
                        onChange: onChange
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

struct BattleTrackerControlPanel: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel

    var body: some View {
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
                Text(viewModel.playerOneName).tag(true)
                Text(viewModel.playerTwoName).tag(false)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("battleTracker.activePlayer")

            Text(viewModel.armyName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            BattleTrackerPhaseControls(viewModel: viewModel)
        }
    }
}

private struct BattleTrackerPhaseControls: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel

    var body: some View {
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
}

struct BattleTrackerAbilitySections: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    let ruleSections: [RuleSection]
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
                        showsEmbeddedCombatTools: true,
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

struct BattleTrackerRoundAndScoreSection: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel

    var body: some View {
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
}
