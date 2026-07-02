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

struct PhaseActionNudgeNotice: Equatable {
    let phase: BattleTurnPhase
    let title: String
    let message: String
}

extension BattlePhaseTrackerView {
    @ViewBuilder
    var reinforcementCallBannerSection: some View {
        if let prompt = viewModel.pendingReinforcementCall {
            BattleTrackerReinforcementCallBanner(
                prompt: prompt,
                onDismiss: { viewModel.clearReinforcementCallPrompt() }
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    var callForReinforcementsCard: some View {
        CallForReinforcementsCard(
            playerOneName: viewModel.playerOneName,
            playerTwoName: viewModel.playerTwoName,
            playerOneArmy: viewModel.playerOneArmy,
            playerTwoArmy: viewModel.playerTwoArmy,
            calledUnitKeys: viewModel.trackerState.calledReinforcementUnitKeys,
            showsCallReminder: viewModel.pendingReinforcementCall != nil,
            onReinforcementOnTableChanged: { armyId, unitId, onTable in
                viewModel.setReinforcementOnTable(armyId: armyId, unitId: unitId, onTable: onTable)
            }
        )
    }

    @ViewBuilder
    var phaseActionNudgeSection: some View {
        if let notice = phaseActionNudge {
            BattleTrackerPhaseActionBanner(
                phaseTitle: notice.title,
                message: notice.message,
                onDismiss: {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        phaseActionNudge = nil
                    }
                }
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    @ViewBuilder
    var turnHandoffSection: some View {
        if let notice = turnHandoffNotice {
            BattleTrackerTurnHandoffBanner(
                title: notice.title,
                detail: notice.detail,
                onDismiss: {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
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
    var heroRoundOneSection: some View {
        if showsHeroRoundOneNotice {
            HeroPhaseRoundOneBanner {
                NewPlayerTipsStore.dismissHeroRoundOneNudge()
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                    showsHeroRoundOneNotice = false
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    @ViewBuilder
    var scoringReminderSection: some View {
        if let notice = scoringReminderNotice {
            BattleTrackerScoringReminderBanner(
                playerName: notice.playerName,
                gameSystemId: viewModel.gameSystemId,
                onJumpToScoring: {
                    selectedSectionTab = .turn
                    scrollToVictoryPoints = true
                },
                onDismiss: {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        scoringReminderNotice = nil
                    }
                }
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    @ViewBuilder
    var battleTacticCommandGuideSection: some View {
        if showsSpearheadBattleChrome, isMidTurnPhase {
            BattleTacticCommandGuideCard()
        }
    }

    private var isMidTurnPhase: Bool {
        switch viewModel.trackerState.currentPhase {
        case .hero, .movement, .shooting, .charge, .combat, .anyCombat:
            true
        default:
            false
        }
    }

    func presentPhaseActionNudgeIfNeeded(from oldPhase: BattleTurnPhase, to phase: BattleTurnPhase) {
        guard oldPhase != phase else { return }
        guard !FirstSessionStore.hasCompletedFirstBattleRound else { return }
        guard supportsBattleTracker else { return }
        if phase == .hero || phase == .command, oldPhase == .endOfTurn {
            return
        }
        guard let message = PhaseContextCoach.phaseActionNudge(
            for: phase,
            gameSystemId: viewModel.gameSystemId.rawValue
        ) else {
            return
        }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            phaseActionNudge = PhaseActionNudgeNotice(
                phase: phase,
                title: phase.title,
                message: message
            )
        }
    }

    func presentRoundOpenerNudgeIfNeeded() {
        guard !MarketingSnapshotBootstrap.suppressesCoachingUI else { return }
        guard showsSpearheadBattleChrome, let step = viewModel.focusedRoundOpenerStep else { return }
        let round = viewModel.trackerState.battleRound
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            roundOpenerNotice = RoundOpenerNotice(
                round: round,
                nextStepTitle: step.title(round: round)
            )
        }
    }

    func presentHeroRoundOneNudgeIfNeeded() {
        guard !MarketingSnapshotBootstrap.suppressesCoachingUI else { return }
        guard viewModel.gameSystemId == .aosSpearhead else { return }
        guard viewModel.trackerState.battleRound == 1 else { return }
        guard viewModel.trackerState.currentPhase == .hero else { return }
        guard !NewPlayerTipsStore.hasDismissedHeroRoundOneNudge else { return }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
            showsHeroRoundOneNotice = true
        }
    }

    func presentScoringReminderIfNeeded() {
        let scoringPhase: BattleTurnPhase = viewModel.playContext.usesAlternatingActivation ? .scoring : .endOfTurn
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
        if viewModel.playContext.usesAlternatingActivation {
            if phase == .scoring {
                notice = TurnHandoffNotice(
                    title: String(localized: "Scoring phase"),
                    detail: String(
                        localized: "Award mission victory points for Supply within 3\", then start the next battle round."
                    )
                )
            } else if playerChanged {
                notice = TurnHandoffNotice(
                    title: String(localized: "Hand the phone to \(activeName)"),
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
                    : handoffDetailAfterEndOfTurn(activeName: activeName)
            )
        } else if phase == .hero, playerChanged || previousPhase == .endOfTurn {
            let heroDetail = viewModel.playContext.capabilities.showsBattleTacticDecks
                ? String(
                    localized: """
                    Hero phase — start of their turn. Check battle tactic cards for command abilities to use before end of turn.
                    """
                )
                : String(localized: "Hero phase — start of their turn.")
            notice = TurnHandoffNotice(
                title: String(localized: "Hand the phone to \(activeName)"),
                detail: heroDetail
            )
        } else if phase == .command, viewModel.playContext.capabilities.deploymentChecklistStyle == .wh40k,
                  playerChanged || previousPhase == .endOfTurn {
            notice = TurnHandoffNotice(
                title: String(localized: "Hand the phone to \(activeName)"),
                detail: String(localized: "Command phase — start of their turn.")
            )
        } else if playerChanged {
            notice = TurnHandoffNotice(
                title: String(localized: "Hand the phone to \(activeName)"),
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

    private func handoffDetailAfterEndOfTurn(activeName: String) -> String {
        if viewModel.canPassToNextPlayerThisRound, let nextName = viewModel.nextHandoffPlayerName {
            return String(
                localized: """
                Use the quick-add buttons on the scorecard, then tap Pass to \(nextName).
                """
            )
        }
        if viewModel.canAdvanceBattleRound {
            return String(
                localized: """
                Both turns are done. Finish scoring, then start the next battle round and run the opener checklist.
                """
            )
        }
        return String(
            localized: """
            Score victory points on the scorecard. Battle tactics refresh at the start of the next battle round.
            """
        )
    }
}
