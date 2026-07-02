import SwiftUI
import TabletomeDomain

struct BattleTrackerTurnTabContent<
    PhasePlaybook: View,
    CombatActivation: View,
    QuickActions: View
>: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    let showsSpearheadBattleChrome: Bool
    let showsScoringContext: Bool
    let showsDedicatedCombatTab: Bool
    let showsSlimTurnTab: Bool
    let showsPhasePlaybook: Bool
    let showsCoach: Bool
    let gameSystemId: GameSystemId
    let reduceMotion: Bool
    let onDismissCoach: () -> Void
    let guideStep: BattleFlowGuideStep?
    let showsGuide: Bool
    let onCompleteGuideStep: () -> Void
    let onBattleCompleteGuide: () -> Void
    let showsStartOfRoundHelper: Bool
    let startOfRoundAbilities: [TriggeredAbility]
    let showsShootingHelper: Bool
    let shootingUnits: [SpearheadUnit]
    let armyName: String
    let onSelectShootingUnit: (String) -> Void
    let phaseActionNudge: PhaseActionNudgeNotice?
    let onDismissPhaseActionNudge: () -> Void
    let reinforcementPrompt: ReinforcementCallPrompt?
    let onDismissReinforcementPrompt: () -> Void
    let turnHandoffNotice: TurnHandoffNotice?
    let onDismissTurnHandoff: () -> Void
    let scoringReminderNotice: ScoringReminderNotice?
    let onJumpToScoring: () -> Void
    let onDismissScoringReminder: () -> Void
    let showsHeroRoundOneNotice: Bool
    let onDismissHeroRoundOne: () -> Void
    let roundOpenerNotice: RoundOpenerNotice?
    let onJumpToRoundChecklist: () -> Void
    let onDismissRoundOpener: () -> Void
    let showsVictoryPointsOnTurnTab: Bool
    let showsBattleTacticGuide: Bool
    let currentPhase: BattleTurnPhase
    let isMovementPhase: Bool
    let showsSpearheadChromeForMovement: Bool
    let activePlayerName: String
    let activeArmy: SpearheadArmy?
    let unitWoundsRemaining: [String: Int]
    @Binding var movementAction: MovementAction
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let calledUnitKeys: Set<String>
    let showsCallReminder: Bool
    let onReinforcementOnTableChanged: (String, String, Bool) -> Void
    @ViewBuilder let phasePlaybook: () -> PhasePlaybook
    @ViewBuilder let combatActivation: () -> CombatActivation
    @ViewBuilder let quickActions: () -> QuickActions

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            if showsSpearheadBattleChrome {
                BattleTrackerRoundBar(viewModel: viewModel)
            }
            if showsScoringContext {
                BattleTrackerVictoryPointsTabSection(viewModel: viewModel, isVisible: showsVictoryPointsOnTurnTab)
            }
            if viewModel.roundOpenerIsIncomplete {
                BattleTrackerRoundOpenerSection(viewModel: viewModel)
            }
            if showsSpearheadBattleChrome,
               viewModel.trackerState.battleRound > 1,
               viewModel.roundOpenerIsIncomplete {
                NewMainTurnReminderBanner(round: viewModel.trackerState.battleRound)
            }
            phasePlaybook()
            BattleTrackerBattleTacticCommandGuideSection(
                isVisible: showsBattleTacticGuide,
                currentPhase: currentPhase
            )
            BattleTrackerCoachSection(
                gameSystemId: gameSystemId,
                isVisible: showsCoach,
                reduceMotion: reduceMotion,
                onDismiss: onDismissCoach
            )
            BattleTrackerGuideSection(
                step: guideStep,
                isVisible: showsGuide,
                onComplete: onCompleteGuideStep,
                onBattleComplete: onBattleCompleteGuide
            )
            BattleTrackerStartOfRoundHelperSection(
                isVisible: showsStartOfRoundHelper,
                abilities: startOfRoundAbilities
            )
            if !showsDedicatedCombatTab {
                BattleTrackerShootingPhaseHelperSection(
                    isVisible: showsShootingHelper,
                    units: shootingUnits,
                    armyName: armyName,
                    gameSystemId: gameSystemId,
                    onSelectUnit: onSelectShootingUnit
                )
                combatActivation()
            }
            BattleTrackerPhaseActionNudgeSection(
                notice: phaseActionNudge,
                reduceMotion: reduceMotion,
                onDismiss: onDismissPhaseActionNudge
            )
            BattleTrackerReinforcementCallBannerSection(
                prompt: reinforcementPrompt,
                onDismiss: onDismissReinforcementPrompt
            )
            BattleTrackerTurnHandoffSection(
                notice: turnHandoffNotice,
                reduceMotion: reduceMotion,
                onDismiss: onDismissTurnHandoff
            )
            BattleTrackerScoringReminderSection(
                notice: scoringReminderNotice,
                gameSystemId: gameSystemId,
                reduceMotion: reduceMotion,
                onJumpToScoring: onJumpToScoring,
                onDismiss: onDismissScoringReminder
            )
            BattleTrackerHeroRoundOneSection(
                isVisible: showsHeroRoundOneNotice,
                onDismiss: onDismissHeroRoundOne
            )
            if !showsScoringContext {
                BattleTrackerVictoryPointsTabSection(viewModel: viewModel, isVisible: showsVictoryPointsOnTurnTab)
            }
            BattleTrackerRoundOpenerNoticeSection(
                notice: roundOpenerNotice,
                reduceMotion: reduceMotion,
                onJumpToChecklist: onJumpToRoundChecklist,
                onDismiss: onDismissRoundOpener
            )
            if !showsSlimTurnTab {
                quickActions()
                BattleTrackerControlPanel(
                    viewModel: viewModel,
                    showsPhaseGuidanceInPicker: !showsPhasePlaybook,
                    showsAdvancePhaseButton: !showsPhasePlaybook
                )
            }
            BattleTrackerMovementPhaseHelperSection(
                isMovementPhase: isMovementPhase,
                showsSpearheadBattleChrome: showsSpearheadChromeForMovement,
                activePlayerName: activePlayerName,
                activeArmy: activeArmy,
                unitWoundsRemaining: unitWoundsRemaining,
                gameSystemId: gameSystemId,
                movementAction: $movementAction,
                playerOneName: playerOneName,
                playerTwoName: playerTwoName,
                playerOneArmy: playerOneArmy,
                playerTwoArmy: playerTwoArmy,
                calledUnitKeys: calledUnitKeys,
                showsCallReminder: showsCallReminder,
                onReinforcementOnTableChanged: onReinforcementOnTableChanged
            )
        }
    }
}
