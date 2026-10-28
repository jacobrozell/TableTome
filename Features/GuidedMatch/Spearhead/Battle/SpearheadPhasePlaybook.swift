import SwiftUI
import TabletomeDomain

/// Phase-specific guidance card with context and smart advance control.
struct SpearheadPhasePlaybook: View {
    @ObservedObject var viewModel: SpearheadBattleViewModel
    var showsOwnChrome: Bool = true
    let onAdvance: () -> Void

    private var phase: BattleTurnPhase { viewModel.trackerState.currentPhase }
    private var round: Int { viewModel.trackerState.battleRound }

    var body: some View {
        if showsOwnChrome {
            playbookStack
                .surfaceCard()
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("spearheadBattle.phasePlaybook")
        } else {
            playbookStack
        }
    }

    private var playbookStack: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if showsOwnChrome {
                headerRow
            }
            bodyText
            if showsOwnChrome {
                advanceButton
            }
        }
    }

    @ViewBuilder
    private var headerRow: some View {
        HStack {
            Label(phase.title.uppercased(), systemImage: phaseIcon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.accentOnSurface)
            Spacer()
        }
    }

    private var phaseIcon: String {
        switch phase {
        case .hero: "sparkles"
        case .movement: "figure.walk"
        case .shooting: "scope"
        case .charge: "arrow.right.circle"
        case .combat, .anyCombat: "burst.fill"
        case .endOfTurn, .endOfAnyTurn: "flag.checkered"
        default: "questionmark.circle"
        }
    }

    @ViewBuilder
    private var bodyText: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(phaseDescription)
                .font(.callout)
                .foregroundStyle(.primary)

            if let hint = phaseHint {
                Text(hint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var phaseDescription: String {
        switch phase {
        case .hero:
            return String(localized: "Activate abilities before moving. Most Spearhead games: skip to Movement.")
        case .movement:
            return String(localized: "Move each unit up to its Move characteristic. Units in combat can only Retreat.")
        case .shooting:
            if viewModel.shootingEligibleUnits.isEmpty {
                return String(localized: "None of your units have ranged weapons this turn.")
            }
            return String(localized: "Pick a unit with ranged weapons, choose a target, roll hit dice.")
        case .charge:
            return String(localized: "Units not in combat can charge. Roll 2D6 — must reach within ½\" of an enemy.")
        case .combat, .anyCombat:
            return String(localized: "Fight with units in melee range. Each unit fights once — mark when done.")
        case .endOfTurn, .endOfAnyTurn:
            return String(localized: "Score objectives you control. Check your battle tactic if you completed it.")
        default:
            return String(localized: "Continue with this phase.")
        }
    }

    private var phaseHint: String? {
        switch phase {
        case .shooting where !viewModel.shootingEligibleUnits.isEmpty:
            let unacted = viewModel.unactedCombatUnitCount
            if unacted == 0, !viewModel.shootingEligibleUnits.isEmpty {
                return String(localized: "All shooting units have acted this phase.")
            }
            if unacted > 0 {
                return String(
                    localized: "\(unacted) of \(viewModel.shootingEligibleUnits.count) units still need to shoot."
                )
            }
            return String(
                localized: "\(viewModel.shootingEligibleUnits.count) of \(viewModel.yourUnits.count) units can shoot this phase."
            )
        case .combat, .anyCombat:
            let unacted = viewModel.unactedCombatUnitCount
            if unacted > 0 {
                return String(localized: "\(unacted) units still need to fight this phase.")
            }
            if !viewModel.combatActivationUnits.isEmpty {
                return String(localized: "All eligible units have fought this phase.")
            }
            return nil
        case .hero where round == 1:
            return String(localized: "Round 1: Remember to check deployment abilities.")
        case .endOfTurn, .endOfAnyTurn:
            return endOfTurnHint
        default:
            return nil
        }
    }

    private var endOfTurnHint: String? {
        if viewModel.isBattleComplete {
            return String(localized: "Battle complete — tap See Results when you're ready.")
        }
        if viewModel.canAdvanceBattleRound {
            return String(localized: "Both turns done — start the next round when scoring is finished.")
        }
        if let name = viewModel.nextHandoffPlayerName {
            return String(localized: "Score below, then pass the phone to \(name).")
        }
        return nil
    }

    @ViewBuilder
    private var advanceButton: some View {
        Group {
            if viewModel.isTurnFlowBlocked {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Label(String(localized: "Finish the round opener first"), systemImage: "checklist")
                        .font(.subheadline.weight(.semibold))
                    Text(
                        String(
                            localized: """
                            Priority roll, underdog, twist card, and battle tactics must be checked off \
                            before advancing phases.
                            """
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if viewModel.nextPhaseTitle != nil {
                Button(action: onAdvance) {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Text("Advance to \(viewModel.nextPhaseTitle ?? "")")
                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline.weight(.medium))
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibilityIdentifier("spearheadBattle.advancePhase")
            } else if viewModel.canPassToNextPlayerThisRound {
                Button(action: onAdvance) {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Text(nextPlayerButtonTitle)
                        Image(systemName: "arrow.left.arrow.right")
                    }
                    .font(.subheadline.weight(.medium))
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibilityIdentifier("spearheadBattle.passToNextPlayer")
            } else if viewModel.canAdvanceBattleRound {
                Button(action: onAdvance) {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Text(
                            String(
                                localized: "Start \(viewModel.playContext.playEngine.roundLabel(round: round + 1))"
                            )
                        )
                        Image(systemName: "arrow.up.circle")
                    }
                    .font(.subheadline.weight(.medium))
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibilityIdentifier("spearheadBattle.startNextRound")
            } else if viewModel.isBattleComplete {
                Label(String(localized: "Battle complete — compare victory points"), systemImage: "flag.checkered")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var nextPlayerButtonTitle: String {
        if let name = viewModel.nextHandoffPlayerName {
            return String(localized: "Pass to \(name)")
        }
        return String(localized: "Next Player's Turn")
    }
}
