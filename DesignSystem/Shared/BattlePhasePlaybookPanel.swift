import SwiftUI
import TabletomeDomain

/// Phase-first hand-holding — lists every ability the active player can use right now.
struct BattlePhasePlaybookPanel: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    let ruleSections: [RuleSection]
    var showsEmbeddedCombatTools: Bool = true
    let onResolveAttack: (TriggeredAbility) -> Void
    let onAdvancePhase: () -> Void

    @State private var advancePhaseTrigger = 0

    private var phase: BattleTurnPhase { viewModel.trackerState.currentPhase }
    private var gameSystemId: GameSystemId { viewModel.gameSystemId }

    private var activePlayerName: String {
        viewModel.trackerState.activePlayerIsOne ? viewModel.playerOneName : viewModel.playerTwoName
    }

    private var phaseArmyOptions: [ArmyRuleOption] { viewModel.phaseArmyRuleOptions }
    private var phaseStratagems: [CombatPatrolStratagem] { viewModel.phaseStratagems }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            header
            abilityList
            advanceButton
        }
        .accentHighlightCard()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("battleTracker.phasePlaybook")
        .id("battleTracker.phasePlaybook")
        .animation(.easeInOut(duration: 0.2), value: phase)
        .sensoryFeedback(.selection, trigger: advancePhaseTrigger)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label {
                Text(playbookTitle)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
            } icon: {
                Image(systemName: phaseIcon)
                    .foregroundStyle(Color.accentOnSurface)
                    .symbolRenderingMode(.hierarchical)
            }

            Text("\(activePlayerName) · \(viewModel.armyName)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            PhaseGuidanceBar(phase: phase, gameSystemId: gameSystemId)
        }
    }

    private var playbookTitle: String {
        if viewModel.trackerState.showAllAbilities {
            return String(localized: "All abilities")
        }
        return "\(String(localized: "In")) \(phase.title)"
    }

    @ViewBuilder
    private var abilityList: some View {
        let abilities = viewModel.activeAbilities
        let armyOptions = phaseArmyOptions
        let stratagems = phaseStratagems

        if abilities.isEmpty, armyOptions.isEmpty, stratagems.isEmpty, !viewModel.trackerState.showAllAbilities {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(emptyPhaseTitle)
                    .font(.subheadline.weight(.semibold))
                Text(emptyPhaseDetail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(DesignTokens.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        } else {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                if !abilities.isEmpty {
                    Text(abilityCountLabel(abilities.count))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    ForEach(abilities) { ability in
                        UnitAbilityCard(
                            ability: ability,
                            phase: phase,
                            isUsed: viewModel.isUsed(ability),
                            onMarkUsed: ability.usageLimit == .oncePerBattle ? { viewModel.markUsed(ability) } : nil,
                            ruleSections: ruleSections,
                            showsRollTools: false,
                            showsEmbeddedCombatTools: showsEmbeddedCombatTools,
                            onResolveAttack: { onResolveAttack(ability) }
                        )
                    }
                }

                if !armyOptions.isEmpty {
                    Text(String(localized: "Army picks"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .padding(.top, abilities.isEmpty ? 0 : DesignTokens.Spacing.xs)

                    ForEach(armyOptions) { option in
                        ArmyRuleOptionCard(
                            option: option,
                            isSelected: true,
                            gameSystemId: gameSystemId.rawValue,
                            ruleSections: ruleSections
                        )
                    }
                }

                if !stratagems.isEmpty {
                    Text(String(localized: "Stratagems"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .padding(.top, abilities.isEmpty && armyOptions.isEmpty ? 0 : DesignTokens.Spacing.xs)

                    ForEach(stratagems) { stratagem in
                        CombatPatrolStratagemRow(
                            stratagem: stratagem,
                            isUsed: viewModel.isStratagemUsed(stratagem),
                            onToggle: { viewModel.toggleStratagem(stratagem) }
                        )
                    }
                }
            }
        }
    }

    private func abilityCountLabel(_ count: Int) -> String {
        if viewModel.trackerState.showAllAbilities {
            return String(localized: "Every ability")
        }
        return "\(count) \(String(localized: "available now"))"
    }

    private var advanceButton: some View {
        Group {
            if viewModel.nextPhaseTitle != nil {
                Button {
                    advancePhaseTrigger += 1
                    onAdvancePhase()
                } label: {
                    Label(nextPhaseButtonTitle, systemImage: "arrow.right.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                        .prominentButtonLabelStyle()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("battleTracker.phasePlaybook.nextPhase")
            } else {
                Label(String(localized: "Last phase — pass the phone when you're done"), systemImage: "iphone.and.arrow.forward")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .accessibilityIdentifier("battleTracker.phasePlaybook.lastPhase")
            }
        }
    }

    private var emptyPhaseTitle: String {
        switch phase {
        case .endOfTurn, .scoring:
            String(localized: "Score and wrap up")
        case .movement:
            String(localized: "Move your units")
        case .shooting, .assault:
            String(localized: "Resolve shooting")
        case .charge:
            String(localized: "Declare charges")
        case .combat, .anyCombat:
            String(localized: "Fight in melee")
        default:
            String(localized: "Nothing to trigger in this phase")
        }
    }

    private var emptyPhaseDetail: String {
        switch phase {
        case .endOfTurn, .scoring:
            String(
                localized: """
                Tally victory points on the Setup tab scorecard, then pass the phone to your opponent.
                """
            )
        case .movement:
            String(
                localized: """
                Use the movement picker below if you ran or stayed put. Tap Next when every unit has moved.
                """
            )
        case .shooting, .assault:
            String(
                localized: """
                Pick a unit below to open its datasheet and combat tools, or tap Next when shooting is done.
                """
            )
        default:
            String(
                localized: """
                Check passives on the Army tab, or tap Next when you're ready to continue.
                """
            )
        }
    }

    private var nextPhaseButtonTitle: String {
        if let nextPhaseTitle = viewModel.nextPhaseTitle {
            return "\(String(localized: "Next")): \(nextPhaseTitle)"
        }
        return String(localized: "Next Phase")
    }

    private var phaseIcon: String {
        switch phase {
        case .hero: "sparkles"
        case .movement: "figure.walk"
        case .shooting, .assault: "scope"
        case .charge: "bolt.fill"
        case .combat, .anyCombat: "figure.fencing"
        case .command: "flag.fill"
        case .endOfTurn, .scoring: "star.circle.fill"
        case .deployment: "map"
        default: "list.bullet.rectangle"
        }
    }
}
