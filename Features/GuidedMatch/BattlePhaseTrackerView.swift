import SwiftUI
import TabletomeDomain

struct BattlePhaseTrackerView: View {
    @StateObject private var viewModel: BattlePhaseTrackerViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let ruleSections: [RuleSection]

    init(matchState: GuidedMatchState, catalog: SpearheadCatalog, ruleSections: [RuleSection] = []) {
        _viewModel = StateObject(wrappedValue: BattlePhaseTrackerViewModel(matchState: matchState, catalog: catalog))
        self.ruleSections = ruleSections
    }

    var body: some View {
        ScrollView {
            Group {
                if horizontalSizeClass == .regular {
                    regularLayout
                } else {
                    compactLayout
                }
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
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
    }

    private var compactLayout: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            loadoutSection
            controlPanel
            trackerContent
        }
    }

    private var regularLayout: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                loadoutSection
                controlPanel
            }
            .frame(width: 320, alignment: .leading)
            trackerContent
                .frame(maxWidth: .infinity, alignment: .leading)
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
                    .accessibilityLabel(viewModel.playerOneName)
                Text(viewModel.playerTwoName)
                    .tag(false)
                    .accessibilityLabel(viewModel.playerTwoName)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("battleTracker.activePlayer")

            Text(viewModel.armyName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

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

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
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
            }
            .padding(DesignTokens.Spacing.md)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        }
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
                Text(viewModel.trackerState.showAllAbilities
                    ? String(localized: "All Abilities")
                    : String(localized: "Available Now"))
                    .font(.title3.bold())

                ForEach(viewModel.activeAbilities) { ability in
                    UnitAbilityCard(
                        ability: ability,
                        phase: viewModel.trackerState.currentPhase,
                        isUsed: viewModel.isUsed(ability),
                        onMarkUsed: ability.usageLimit == .oncePerBattle ? { viewModel.markUsed(ability) } : nil
                    )
                }
            }
        }

        if !viewModel.passiveAbilities.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text(String(localized: "Always On"))
                    .font(.title3.bold())

                ForEach(viewModel.passiveAbilities) { ability in
                    UnitAbilityCard(
                        ability: ability,
                        phase: viewModel.trackerState.currentPhase,
                        isUsed: false,
                        onMarkUsed: nil
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
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }
}
