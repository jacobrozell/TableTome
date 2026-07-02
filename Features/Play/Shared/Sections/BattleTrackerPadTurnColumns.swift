import SwiftUI
import TabletomeDomain
import TabletomeData

struct BattleTrackerPadTurnColumns<
    QuickActions: View,
    PhasePlaybook: View
>: View {
    let showsSlimTurnTab: Bool
    let spacing: CGFloat
    let controlColumnMaxWidth: CGFloat
    let sidebarColumnMaxWidth: CGFloat
    let showsSpearheadBattleChrome: Bool
    let showsScoringContext: Bool
    let showsVictoryPointsOnTurnTab: Bool
    let showsDedicatedCombatTab: Bool
    let showsPhasePlaybook: Bool
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
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
    let showsBattleTacticGuide: Bool
    let currentPhase: BattleTurnPhase
    let isMovementPhase: Bool
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
    @ViewBuilder let quickActions: () -> QuickActions
    @ViewBuilder let phasePlaybook: () -> PhasePlaybook

    var body: some View {
        if showsSlimTurnTab {
            BattleTrackerPadTurnPlaybookLayout(
                spacing: spacing,
                sidebarColumnMaxWidth: sidebarColumnMaxWidth,
                showsSpearheadBattleChrome: showsSpearheadBattleChrome,
                showsScoringContext: showsScoringContext,
                showsVictoryPointsOnTurnTab: showsVictoryPointsOnTurnTab,
                showsDedicatedCombatTab: showsDedicatedCombatTab,
                showsCoach: showsCoach,
                gameSystemId: gameSystemId,
                reduceMotion: reduceMotion,
                onDismissCoach: onDismissCoach,
                guideStep: guideStep,
                showsGuide: showsGuide,
                onCompleteGuideStep: onCompleteGuideStep,
                onBattleCompleteGuide: onBattleCompleteGuide,
                showsStartOfRoundHelper: showsStartOfRoundHelper,
                startOfRoundAbilities: startOfRoundAbilities,
                showsShootingHelper: showsShootingHelper,
                shootingUnits: shootingUnits,
                armyName: armyName,
                onSelectShootingUnit: onSelectShootingUnit,
                phaseActionNudge: phaseActionNudge,
                onDismissPhaseActionNudge: onDismissPhaseActionNudge,
                reinforcementPrompt: reinforcementPrompt,
                onDismissReinforcementPrompt: onDismissReinforcementPrompt,
                turnHandoffNotice: turnHandoffNotice,
                onDismissTurnHandoff: onDismissTurnHandoff,
                scoringReminderNotice: scoringReminderNotice,
                onJumpToScoring: onJumpToScoring,
                onDismissScoringReminder: onDismissScoringReminder,
                showsHeroRoundOneNotice: showsHeroRoundOneNotice,
                onDismissHeroRoundOne: onDismissHeroRoundOne,
                roundOpenerNotice: roundOpenerNotice,
                onJumpToRoundChecklist: onJumpToRoundChecklist,
                onDismissRoundOpener: onDismissRoundOpener,
                showsBattleTacticGuide: showsBattleTacticGuide,
                currentPhase: currentPhase,
                isMovementPhase: isMovementPhase,
                activePlayerName: activePlayerName,
                activeArmy: activeArmy,
                unitWoundsRemaining: unitWoundsRemaining,
                movementAction: $movementAction,
                playerOneName: playerOneName,
                playerTwoName: playerTwoName,
                playerOneArmy: playerOneArmy,
                playerTwoArmy: playerTwoArmy,
                calledUnitKeys: calledUnitKeys,
                showsCallReminder: showsCallReminder,
                onReinforcementOnTableChanged: onReinforcementOnTableChanged,
                viewModel: viewModel,
                showsPhasePlaybook: showsPhasePlaybook,
                quickActions: quickActions,
                phasePlaybook: phasePlaybook
            )
        } else {
            BattleTrackerPadTwoColumnRow(
                controlColumnMaxWidth: controlColumnMaxWidth,
                balance: .controlSidebar
            ) {
                quickActions()
                BattleTrackerControlPanel(
                    viewModel: viewModel,
                    showsPhaseGuidanceInPicker: !showsPhasePlaybook,
                    showsAdvancePhaseButton: !showsPhasePlaybook
                )
            } secondary: {
                if showsScoringContext {
                    BattleTrackerVictoryPointsTabSection(
                        viewModel: viewModel,
                        isVisible: showsVictoryPointsOnTurnTab
                    )
                }
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
                BattleTrackerBattleTacticCommandGuideSection(
                    isVisible: showsBattleTacticGuide,
                    currentPhase: currentPhase
                )
                phasePlaybook()
                if !showsScoringContext {
                    BattleTrackerVictoryPointsTabSection(
                        viewModel: viewModel,
                        isVisible: showsVictoryPointsOnTurnTab
                    )
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
                BattleTrackerRoundOpenerNoticeSection(
                    notice: roundOpenerNotice,
                    reduceMotion: reduceMotion,
                    onJumpToChecklist: onJumpToRoundChecklist,
                    onDismiss: onDismissRoundOpener
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
                }
                BattleTrackerMovementPhaseHelperSection(
                    isMovementPhase: isMovementPhase,
                    showsSpearheadBattleChrome: showsSpearheadBattleChrome,
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
}

struct BattleTrackerPadTurnPlaybookLayout<
    QuickActions: View,
    PhasePlaybook: View
>: View {
    let spacing: CGFloat
    let sidebarColumnMaxWidth: CGFloat
    let showsSpearheadBattleChrome: Bool
    let showsScoringContext: Bool
    let showsVictoryPointsOnTurnTab: Bool
    let showsDedicatedCombatTab: Bool
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
    let showsBattleTacticGuide: Bool
    let currentPhase: BattleTurnPhase
    let isMovementPhase: Bool
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
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    let showsPhasePlaybook: Bool
    @ViewBuilder let quickActions: () -> QuickActions
    @ViewBuilder let phasePlaybook: () -> PhasePlaybook

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if showsSpearheadBattleChrome,
               viewModel.trackerState.battleRound > 1,
               viewModel.roundOpenerIsIncomplete {
                NewMainTurnReminderBanner(round: viewModel.trackerState.battleRound)
            }

            BattleTrackerRoundBar(viewModel: viewModel)
            if showsScoringContext {
                BattleTrackerVictoryPointsTabSection(
                    viewModel: viewModel,
                    isVisible: showsVictoryPointsOnTurnTab
                )
            }
            phasePlaybook()
            BattleTrackerBattleTacticCommandGuideSection(
                isVisible: showsBattleTacticGuide,
                currentPhase: currentPhase
            )
            if !showsScoringContext {
                BattleTrackerVictoryPointsTabSection(
                    viewModel: viewModel,
                    isVisible: showsVictoryPointsOnTurnTab
                )
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
            BattleTrackerRoundOpenerNoticeSection(
                notice: roundOpenerNotice,
                reduceMotion: reduceMotion,
                onJumpToChecklist: onJumpToRoundChecklist,
                onDismiss: onDismissRoundOpener
            )

            BattleTrackerPadTwoColumnRow(
                controlColumnMaxWidth: sidebarColumnMaxWidth,
                balance: .contentPrimary
            ) {
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
                }
                BattleTrackerMovementPhaseHelperSection(
                    isMovementPhase: isMovementPhase,
                    showsSpearheadBattleChrome: showsSpearheadBattleChrome,
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
            } secondary: {
                quickActions()
            }
        }
    }
}
