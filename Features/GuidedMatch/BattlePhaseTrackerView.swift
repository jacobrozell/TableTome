import SwiftUI
import TabletomeDomain

struct BattlePhaseTrackerView: View {
    @StateObject private var viewModel: BattlePhaseTrackerViewModel

    init(matchState: GuidedMatchState, catalog: SpearheadCatalog) {
        _viewModel = StateObject(wrappedValue: BattlePhaseTrackerViewModel(matchState: matchState, catalog: catalog))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                controlPanel

                if !supportsBattleTracker {
                    emptyState
                } else {
                    abilitySections
                }
            }
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

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                Stepper(
                    String(localized: "Round \(viewModel.trackerState.battleRound)"),
                    value: Binding(
                        get: { viewModel.trackerState.battleRound },
                        set: { viewModel.setBattleRound($0) }
                    ),
                    in: 1...4
                )
                .accessibilityIdentifier("battleTracker.round")
            }

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

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text(String(localized: "Current Phase"))
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        ForEach(BattleTurnPhase.mainTurnPhases) { phase in
                            PhaseChip(
                                phase: phase,
                                isSelected: viewModel.trackerState.currentPhase == phase && !viewModel.trackerState.showAllAbilities
                            ) {
                                viewModel.trackerState.showAllAbilities = false
                                viewModel.setPhase(phase)
                            }
                        }
                    }
                }
                .accessibilityIdentifier("battleTracker.phasePicker")

                if !viewModel.specialPhases.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            ForEach(viewModel.specialPhases) { phase in
                                PhaseChip(
                                    phase: phase,
                                    isSelected: viewModel.trackerState.currentPhase == phase && !viewModel.trackerState.showAllAbilities,
                                    style: .secondary
                                ) {
                                    viewModel.trackerState.showAllAbilities = false
                                    viewModel.setPhase(phase)
                                }
                            }
                        }
                    }
                }

                HStack {
                    Toggle(String(localized: "Show all abilities"), isOn: Binding(
                        get: { viewModel.trackerState.showAllAbilities },
                        set: { _ in viewModel.toggleShowAll() }
                    ))
                    .accessibilityIdentifier("battleTracker.showAll")

                    Spacer()

                    Button {
                        viewModel.advancePhase()
                    } label: {
                        Label(String(localized: "Next Phase"), systemImage: "arrow.right.circle.fill")
                    }
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
            let coverageTitle = viewModel.contentCoverage.title.lowercased()
            Text(
                "This army has \(coverageTitle) data. Unit ability reminders are added via per-army detail files — use the official PDF link on the army picker in the meantime."
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

private struct PhaseChip: View {
    enum Style { case primary, secondary }

    let phase: BattleTurnPhase
    let isSelected: Bool
    var style: Style = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(shortTitle)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemFill), in: Capsule())
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
        .frame(minHeight: DesignTokens.minTouchTarget)
        .accessibilityLabel(phase.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("battleTracker.phase.\(phase.id)")
    }

    private var shortTitle: String {
        switch phase {
        case .hero: String(localized: "Hero")
        case .movement: String(localized: "Move")
        case .shooting: String(localized: "Shoot")
        case .charge: String(localized: "Charge")
        case .combat: String(localized: "Fight")
        case .endOfTurn: String(localized: "End")
        case .deployment: String(localized: "Deploy")
        case .enemyMovement: String(localized: "Enemy")
        case .endOfAnyTurn: String(localized: "End Any")
        case .anyCombat: String(localized: "Combat")
        }
    }
}
