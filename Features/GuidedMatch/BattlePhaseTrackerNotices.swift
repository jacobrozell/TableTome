import SwiftUI
import TabletomeDomain

struct TurnHandoffNotice: Equatable {
    let title: String
    let detail: String
}

struct DamageUndoNotice: Equatable {
    let message: String
    let woundKey: String
    let previousWounds: Int
}

struct RoundOpenerNotice: Equatable {
    let round: Int
    let nextStepTitle: String
}

struct ScoringReminderNotice: Equatable {
    let playerName: String
}

extension BattlePhaseTrackerView {
    @ViewBuilder
    var turnHandoffSection: some View {
        if let notice = turnHandoffNotice {
            BattleTrackerTurnHandoffBanner(
                title: notice.title,
                detail: notice.detail,
                onDismiss: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        turnHandoffNotice = nil
                    }
                }
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    @ViewBuilder
    var damageUndoSection: some View {
        if let notice = damageUndoNotice {
            BattleTrackerDamageUndoBanner(
                message: notice.message,
                onUndo: {
                    viewModel.setUnitWounds(key: notice.woundKey, remaining: notice.previousWounds)
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        damageUndoNotice = nil
                    }
                },
                onDismiss: {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        damageUndoNotice = nil
                    }
                }
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    @ViewBuilder
    var roundOpenerSection: some View {
        if let notice = roundOpenerNotice {
            BattleTrackerRoundOpenerBanner(
                round: notice.round,
                nextStepTitle: notice.nextStepTitle,
                onJumpToChecklist: { scrollToRoundChecklist = true },
                onDismiss: {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        roundOpenerNotice = nil
                    }
                }
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    @ViewBuilder
    var scoringReminderSection: some View {
        if let notice = scoringReminderNotice {
            BattleTrackerScoringReminderBanner(
                playerName: notice.playerName,
                gameSystemId: viewModel.gameSystemId,
                onJumpToScoring: { scrollToVictoryPoints = true },
                onDismiss: {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        scoringReminderNotice = nil
                    }
                }
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    func presentRoundOpenerNudgeIfNeeded() {
        guard showsSpearheadBattleChrome, let step = viewModel.focusedRoundOpenerStep else { return }
        let round = viewModel.trackerState.battleRound
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            roundOpenerNotice = RoundOpenerNotice(
                round: round,
                nextStepTitle: step.title(round: round)
            )
        }
    }

    func presentScoringReminderIfNeeded() {
        let scoringPhase: BattleTurnPhase = viewModel.usesAlternatingActivation ? .scoring : .endOfTurn
        guard viewModel.trackerState.currentPhase == scoringPhase else { return }
        let playerName = viewModel.trackerState.activePlayerIsOne
            ? viewModel.playerOneName
            : viewModel.playerTwoName
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            scoringReminderNotice = ScoringReminderNotice(playerName: playerName)
        }
    }

    func presentTurnHandoff(
        from previousPhase: BattleTurnPhase,
        to phase: BattleTurnPhase,
        playerChanged: Bool
    ) {
        let activeName = viewModel.trackerState.activePlayerIsOne
            ? viewModel.playerOneName
            : viewModel.playerTwoName
        let notice: TurnHandoffNotice?
        if viewModel.usesAlternatingActivation {
            if phase == .scoring {
                notice = TurnHandoffNotice(
                    title: String(localized: "Scoring phase"),
                    detail: String(
                        localized: "Award mission victory points for Supply within 3\", then start the next battle round."
                    )
                )
            } else if playerChanged {
                notice = TurnHandoffNotice(
                    title: String(localized: "Pass to \(activeName)"),
                    detail: String(localized: "\(phase.title) — activate one unit, then Done or Pass.")
                )
            } else {
                notice = nil
            }
        } else if phase == .endOfTurn {
            notice = TurnHandoffNotice(
                title: String(localized: "End of \(activeName)'s turn"),
                detail: viewModel.playContext.usesGuidedBattleTracker
                    ? String(
                        localized: """
                        Score objectives for this turn, then pass the phone. Command Points refresh at the start of \
                        the next Command phase.
                        """
                    )
                    : String(
                        localized: """
                        Score any victory points, then pass the phone. Battle tactics refresh at the start of the \
                        next battle round.
                        """
                    )
            )
        } else if phase == .hero, playerChanged || previousPhase == .endOfTurn {
            notice = TurnHandoffNotice(
                title: String(localized: "Pass to \(activeName)"),
                detail: String(localized: "Hero phase — start of their turn.")
            )
        } else if phase == .command, viewModel.playContext.isWh40k11e,
                  playerChanged || previousPhase == .endOfTurn {
            notice = TurnHandoffNotice(
                title: String(localized: "Pass to \(activeName)"),
                detail: String(localized: "Command phase — start of their turn.")
            )
        } else if playerChanged {
            notice = TurnHandoffNotice(
                title: String(localized: "Pass to \(activeName)"),
                detail: String(localized: "\(phase.title) phase.")
            )
        } else {
            notice = nil
        }
        guard let notice else { return }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            turnHandoffNotice = notice
        }
    }
}
