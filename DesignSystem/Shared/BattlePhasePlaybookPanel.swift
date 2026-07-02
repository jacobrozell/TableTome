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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: phase)
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

            Text(viewModel.armyName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            if viewModel.gameSystemId == .aosSpearhead, viewModel.trackerState.battleRound == 1 {
                SpearheadRoundOneFirstTurnCard(
                    playerOneName: viewModel.playerOneName,
                    playerTwoName: viewModel.playerTwoName,
                    attackerName: viewModel.attackerDisplayName,
                    firstTurnIsPlayerOne: viewModel.matchState.firstTurnIsPlayerOne,
                    onSelect: { viewModel.correctRoundOneFirstTurn(isPlayerOne: $0) }
                )
            } else if viewModel.gameSystemId == .aosSpearhead, viewModel.trackerState.battleRound > 1 {
                SpearheadRoundTwoPlusOpenerCard(
                    battleRound: viewModel.trackerState.battleRound,
                    underdogPlayerName: underdogPlayerName
                )
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

            if !viewModel.playContext.usesAlternatingActivation,
               viewModel.trackerState.currentPhase != .deployment {
                BattleRoundTurnProgressChip(
                    round: viewModel.trackerState.battleRound,
                    playerOneName: viewModel.playerOneName,
                    playerTwoName: viewModel.playerTwoName,
                    completedTurnPlayerOnes: viewModel.trackerState.completedTurnsThisRound,
                    activePlayerIsOne: viewModel.trackerState.activePlayerIsOne
                )
            }

            PhaseGuidanceBar(phase: phase, gameSystemId: gameSystemId)
        }
    }

    private var playbookTitle: String {
        if viewModel.trackerState.showAllAbilities {
            return String(localized: "All abilities")
        }
        return "\(String(localized: "In")) \(phase.title)"
    }

    private var underdogPlayerName: String? {
        guard let underdogIsPlayerOne = viewModel.underdogIsPlayerOne else { return nil }
        return underdogIsPlayerOne ? viewModel.playerOneName : viewModel.playerTwoName
    }

    @ViewBuilder
    private var abilityList: some View {
        let abilities = viewModel.activeAbilities
        let armyOptions = phaseArmyOptions
        let stratagems = phaseStratagems

        if abilities.isEmpty, armyOptions.isEmpty, stratagems.isEmpty, !viewModel.trackerState.showAllAbilities {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                if phase == .movement, gameSystemId == .aosSpearhead {
                    MovementRangeCard(
                        playerName: activePlayerName,
                        army: viewModel.activeArmy,
                        woundsRemaining: viewModel.trackerState.unitWoundsRemaining,
                        armyId: viewModel.activeArmy?.id
                    )
                }
                Text(emptyPhaseTitle)
                    .font(.subheadline.weight(.semibold))
                Text(emptyPhaseDetail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if phase == .movement, gameSystemId == .aosSpearhead,
                   let retreatEntry = SpearheadRulesGlossary.entries.first(where: { $0.id == "retreat" }) {
                    GlossaryChip(entry: retreatEntry, gameSystemId: gameSystemId.rawValue, ruleSections: ruleSections)
                }
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
            if viewModel.isTurnFlowBlocked {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Label(
                        String(localized: "Finish the round opener first"),
                        systemImage: "checklist"
                    )
                    .font(.subheadline.weight(.semibold))
                    Text(
                        String(
                            localized: """
                            Roll for priority, pick who goes first on this tab, then finish the opener checklist \
                            before advancing phases.
                            """
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .accessibilityIdentifier("battleTracker.phasePlaybook.roundOpenerBlocked")
            } else if viewModel.nextPhaseTitle != nil {
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
            } else if viewModel.canPassToNextPlayerThisRound {
                Button {
                    advancePhaseTrigger += 1
                    viewModel.completePhasedRoundTurnPhase(.endOfTurn)
                } label: {
                    Label(nextPlayerButtonTitle, systemImage: "arrow.left.arrow.right.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                        .prominentButtonLabelStyle()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("battleTracker.phasePlaybook.nextPlayer")
            } else if viewModel.canAdvanceBattleRound {
                Button {
                    advancePhaseTrigger += 1
                    viewModel.advanceBattleRound()
                } label: {
                    Label(
                        String(
                            localized: "Start \(viewModel.playContext.playEngine.roundLabel(round: viewModel.trackerState.battleRound + 1))"
                        ),
                        systemImage: "arrow.up.circle.fill"
                    )
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                    .prominentButtonLabelStyle()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("battleTracker.phasePlaybook.advanceRound")
            } else if viewModel.isBattleComplete {
                Label(String(localized: "Battle complete — compare victory points"), systemImage: "flag.checkered")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .accessibilityIdentifier("battleTracker.phasePlaybook.battleComplete")
            } else {
                Label(endOfTurnHandoffHint, systemImage: "iphone.and.arrow.forward")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .accessibilityIdentifier("battleTracker.phasePlaybook.lastPhase")
            }
        }
    }

    private var nextPlayerButtonTitle: String {
        if let name = viewModel.nextHandoffPlayerName {
            return String(localized: "Pass to \(name)")
        }
        return String(localized: "Next Player's Turn")
    }

    private var endOfTurnHandoffHint: String {
        if viewModel.isBattleComplete {
            return String(localized: "Battle complete — compare victory points.")
        }
        if viewModel.canAdvanceBattleRound {
            return String(localized: "Both turns done — tap Start Next Round when scoring is finished.")
        }
        if let name = viewModel.nextHandoffPlayerName {
            return String(localized: "Score below, then pass the phone to \(name).")
        }
        return String(localized: "Last phase — pass the phone when you're done.")
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
            if viewModel.canPassToNextPlayerThisRound, let name = viewModel.nextHandoffPlayerName {
                String(
                    localized: """
                    Score victory points below, then tap Pass to \(name). Battle tactics refresh at the start of the next battle round.
                    """
                )
            } else if viewModel.canAdvanceBattleRound {
                String(
                    localized: """
                    Both turns are done — score any final points, then tap Start Next Round. Run the round opener checklist (priority roll, underdog, twist).
                    """
                )
            } else {
                String(
                    localized: """
                    Score victory points below. When both players have finished this round, start the next one.
                    """
                )
            }
        case .movement:
            String(
                localized: """
                Normal Move, Run, or Retreat. Retreat: roll D3 mortal wounds on the retreating unit, then move up to Move — \
                cannot end in enemy combat range. No shoot or charge after Run or Retreat this turn.
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
