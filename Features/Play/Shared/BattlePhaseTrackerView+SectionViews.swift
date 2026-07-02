import SwiftUI
import TabletomeDomain
import TabletomeData

struct BattleTrackerTurnTabSectionInputs {
    let showsCoach: Bool
    let guideStep: BattleFlowGuideStep?
    let showsGuide: Bool
    let showsStartOfRoundHelper: Bool
    let startOfRoundAbilities: [TriggeredAbility]
    let showsShootingHelper: Bool
    let shootingUnits: [SpearheadUnit]
    let armyName: String
    let phaseActionNudge: PhaseActionNudgeNotice?
    let reinforcementPrompt: ReinforcementCallPrompt?
    let turnHandoffNotice: TurnHandoffNotice?
    let scoringReminderNotice: ScoringReminderNotice?
    let showsHeroRoundOneNotice: Bool
    let roundOpenerNotice: RoundOpenerNotice?
    let showsBattleTacticGuide: Bool
    let currentPhase: BattleTurnPhase
    let isMovementPhase: Bool
    let activePlayerName: String
    let activeArmy: SpearheadArmy?
    let unitWoundsRemaining: [String: Int]
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let calledUnitKeys: Set<String>
    let showsCallReminder: Bool
}

extension BattlePhaseTrackerView {
    var showsCoachSection: Bool {
        supportsBattleTracker && showsBattleTrackerCoach && !showsPhasePlaybook
    }

    var showsStartOfRoundHelperSection: Bool {
        supportsBattleTracker && showsSpearheadBattleChrome && viewModel.needsStartOfRoundAbilitiesPrompt
    }

    var showsShootingPhaseHelperSection: Bool {
        supportsBattleTracker
            && ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId)
            && viewModel.trackerState.currentPhase == .shooting
            && !viewModel.showsCombatActivationTracker
    }

    var showsShootInCombatPhaseHelperSection: Bool {
        supportsBattleTracker
            && ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId)
            && (viewModel.trackerState.currentPhase == .combat
                || viewModel.trackerState.currentPhase == .anyCombat)
            && !viewModel.shootInCombatEligibleUnits.isEmpty
    }

    var showsCombatResolverSection: Bool {
        supportsBattleTracker && ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId)
    }

    var showsArmyTrackerSection: Bool {
        supportsBattleTracker && !viewModel.playContext.capabilities.showsActivationBar
    }

    var showsBattleTacticCommandGuideSection: Bool {
        showsSpearheadBattleChrome
    }

    var isCombatRelatedPhase: Bool {
        viewModel.trackerState.currentPhase == .combat
            || viewModel.trackerState.currentPhase == .anyCombat
    }

    var isMovementPhase: Bool {
        viewModel.trackerState.currentPhase == .movement
    }

    func deploymentSectionView() -> some View {
        BattleTrackerDeploymentSection(
            battleRound: viewModel.trackerState.battleRound,
            deploymentIsComplete: deploymentIsComplete,
            showsDeploymentSetup: $showsDeploymentSetup,
            deploymentContent: { engineDeploymentSection }
        )
    }

    func coachSectionView() -> BattleTrackerCoachSection {
        BattleTrackerCoachSection(
            gameSystemId: viewModel.gameSystemId,
            isVisible: showsCoachSection,
            reduceMotion: reduceMotion,
            onDismiss: {
                NewPlayerTipsStore.markBattleTrackerCoachSeen()
                showsBattleTrackerCoach = false
            }
        )
    }

    func guideSectionView() -> BattleTrackerGuideSection {
        BattleTrackerGuideSection(
            step: viewModel.currentGuideStep,
            isVisible: showsGuideOnTurnTab,
            onComplete: { viewModel.completeCurrentGuideStep() },
            onBattleComplete: {
                if ReleaseSurface.showsMatchHistory {
                    presentVictoryScreen()
                }
                dismissedBattleCompleteGuide = true
            }
        )
    }

    func startOfRoundHelperView() -> BattleTrackerStartOfRoundHelperSection {
        BattleTrackerStartOfRoundHelperSection(
            isVisible: showsStartOfRoundHelperSection,
            abilities: viewModel.startOfRoundAbilities
        )
    }

    func shootingPhaseHelperView() -> BattleTrackerShootingPhaseHelperSection {
        BattleTrackerShootingPhaseHelperSection(
            isVisible: showsShootingPhaseHelperSection,
            units: viewModel.shootingEligibleUnits,
            armyName: viewModel.armyName,
            gameSystemId: viewModel.gameSystemId,
            onSelectUnit: { unitId in
                guard let armyId = viewModel.activeArmy?.id else { return }
                let shootingWeaponId = viewModel.activeArmy?
                    .units
                    .first(where: { $0.id == unitId })?
                    .shootingWeapons
                    .first?
                    .id
                handleArmyUnitSelection(
                    armyId: armyId,
                    unitId: unitId,
                    preferredWeaponId: shootingWeaponId
                )
            }
        )
    }

    func shootInCombatPhaseHelperView() -> BattleTrackerShootInCombatPhaseHelperSection {
        BattleTrackerShootInCombatPhaseHelperSection(
            isVisible: showsShootInCombatPhaseHelperSection,
            units: viewModel.shootInCombatEligibleUnits,
            onSelectUnit: { unitId, weaponId in
                guard let armyId = viewModel.activeArmy?.id else { return }
                handleArmyUnitSelection(
                    armyId: armyId,
                    unitId: unitId,
                    preferredWeaponId: weaponId
                )
            }
        )
    }

    func gotchaSectionView() -> BattleTrackerGotchaSection {
        BattleTrackerGotchaSection(gotchas: viewModel.activeGotchas)
    }

    func trackerContentView() -> BattleTrackerContentSection {
        BattleTrackerContentSection(
            viewModel: viewModel,
            ruleSections: ruleSections,
            supportsBattleTracker: supportsBattleTracker,
            showsActivationBar: viewModel.playContext.capabilities.showsActivationBar,
            usesGuidedBattleTracker: viewModel.playContext.usesGuidedBattleTracker,
            showsEmbeddedCombatTools: ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId),
            onResolveAttack: handleResolveAttack
        )
    }

    func phaseActionNudgeSectionView() -> BattleTrackerPhaseActionNudgeSection {
        BattleTrackerPhaseActionNudgeSection(
            notice: phaseActionNudge,
            reduceMotion: reduceMotion,
            onDismiss: { phaseActionNudge = nil }
        )
    }

    func reinforcementCallBannerSectionView() -> BattleTrackerReinforcementCallBannerSection {
        BattleTrackerReinforcementCallBannerSection(
            prompt: viewModel.pendingReinforcementCall,
            onDismiss: { viewModel.clearReinforcementCallPrompt() }
        )
    }

    func turnHandoffSectionView() -> BattleTrackerTurnHandoffSection {
        BattleTrackerTurnHandoffSection(
            notice: turnHandoffNotice,
            reduceMotion: reduceMotion,
            onDismiss: { turnHandoffNotice = nil }
        )
    }

    func damageUndoSectionView() -> BattleTrackerDamageUndoSection {
        BattleTrackerDamageUndoSection(
            notice: damageUndoNotice,
            reduceMotion: reduceMotion,
            onUndo: {
                if let notice = damageUndoNotice {
                    viewModel.setUnitWounds(key: notice.woundKey, remaining: notice.previousWounds)
                }
            },
            onDismiss: { damageUndoNotice = nil }
        )
    }

    func roundOpenerNoticeSectionView() -> BattleTrackerRoundOpenerNoticeSection {
        BattleTrackerRoundOpenerNoticeSection(
            notice: roundOpenerNotice,
            reduceMotion: reduceMotion,
            onJumpToChecklist: { scrollToRoundChecklist = true },
            onDismiss: { roundOpenerNotice = nil }
        )
    }

    func heroRoundOneSectionView() -> BattleTrackerHeroRoundOneSection {
        BattleTrackerHeroRoundOneSection(
            isVisible: showsHeroRoundOneNotice,
            onDismiss: {
                NewPlayerTipsStore.dismissHeroRoundOneNudge()
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                    showsHeroRoundOneNotice = false
                }
            }
        )
    }

    func scoringReminderSectionView() -> BattleTrackerScoringReminderSection {
        BattleTrackerScoringReminderSection(
            notice: scoringReminderNotice,
            gameSystemId: viewModel.gameSystemId,
            reduceMotion: reduceMotion,
            onJumpToScoring: {
                selectedSectionTab = .turn
                scrollToVictoryPoints = true
            },
            onDismiss: { scoringReminderNotice = nil }
        )
    }

    func battleTacticCommandGuideSectionView() -> BattleTrackerBattleTacticCommandGuideSection {
        BattleTrackerBattleTacticCommandGuideSection(
            isVisible: showsBattleTacticCommandGuideSection,
            currentPhase: viewModel.trackerState.currentPhase
        )
    }

    func movementPhaseHelperView() -> BattleTrackerMovementPhaseHelperSection {
        BattleTrackerMovementPhaseHelperSection(
            isMovementPhase: isMovementPhase,
            showsSpearheadBattleChrome: showsSpearheadBattleChrome,
            activePlayerName: viewModel.trackerState.activePlayerIsOne
                ? viewModel.playerOneName
                : viewModel.playerTwoName,
            activeArmy: viewModel.activeArmy,
            unitWoundsRemaining: viewModel.trackerState.unitWoundsRemaining,
            gameSystemId: viewModel.gameSystemId,
            movementAction: $movementAction,
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

    func combatPhaseHelperView() -> BattleTrackerCombatPhaseHelperSection {
        BattleTrackerCombatPhaseHelperSection(
            isVisible: showsSpearheadBattleChrome && isCombatRelatedPhase
        )
    }

    func callForReinforcementsSectionView() -> BattleTrackerCallForReinforcementsSection {
        BattleTrackerCallForReinforcementsSection(
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

    func combatResolverSectionView(usesLandscapeSplit: Bool = false) -> BattleTrackerCombatResolverTabSection {
        BattleTrackerCombatResolverTabSection(
            combatViewModel: combatViewModel,
            multiAttackViewModel: multiAttackViewModel,
            batchCombatViewModel: batchCombatViewModel,
            showsCombatResolver: $showsCombatResolver,
            diceInputModeRaw: $diceInputModeRaw,
            showsAdvancedOptions: $showsAdvancedOptions,
            showsMultiAttack: $showsMultiAttack,
            showsAdvancedSingleAttack: $showsAdvancedSingleAttack,
            isVisible: showsCombatResolverSection,
            trackerState: viewModel.trackerState,
            attackerName: combatAttackerName,
            defenderName: combatDefenderName,
            deploymentIsComplete: deploymentIsComplete,
            defenderWoundsRemaining: defenderWoundsRemaining,
            unitWoundsRemaining: viewModel.trackerState.unitWoundsRemaining,
            ruleSections: ruleSections,
            onSyncMultiAttack: syncMultiAttack,
            onApplyDamage: applyCombatDamage,
            usesLandscapeSplitPresentation: usesLandscapeSplit
        )
    }

    func armyTrackerSectionView(wideLayout: Bool, compactSidebar: Bool = false) -> BattleTrackerArmyTrackerSection {
        BattleTrackerArmyTrackerSection(
            isVisible: showsArmyTrackerSection,
            playerOneName: viewModel.playerOneName,
            playerTwoName: viewModel.playerTwoName,
            playerOneArmy: viewModel.playerOneArmy,
            playerTwoArmy: viewModel.playerTwoArmy,
            unitWoundsRemaining: viewModel.trackerState.unitWoundsRemaining,
            healthPerModelOverrides: viewModel.trackerState.unitHealthPerModelOverrides,
            activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
            usesWideLayout: wideLayout,
            usesCompactSidebar: compactSidebar,
            gameSystemId: viewModel.gameSystemId,
            calledReinforcementUnitKeys: viewModel.trackerState.calledReinforcementUnitKeys,
            onChange: viewModel.setUnitWounds(key:remaining:),
            onSelectUnit: { armyId, unitId in
                handleArmyUnitSelection(armyId: armyId, unitId: unitId)
            }
        )
    }

    func sharedTurnTabInputs() -> BattleTrackerTurnTabSectionInputs {
        BattleTrackerTurnTabSectionInputs(
            showsCoach: showsCoachSection,
            guideStep: viewModel.currentGuideStep,
            showsGuide: showsGuideOnTurnTab,
            showsStartOfRoundHelper: showsStartOfRoundHelperSection,
            startOfRoundAbilities: viewModel.startOfRoundAbilities,
            showsShootingHelper: showsShootingPhaseHelperSection,
            shootingUnits: viewModel.shootingEligibleUnits,
            armyName: viewModel.armyName,
            phaseActionNudge: phaseActionNudge,
            reinforcementPrompt: viewModel.pendingReinforcementCall,
            turnHandoffNotice: turnHandoffNotice,
            scoringReminderNotice: scoringReminderNotice,
            showsHeroRoundOneNotice: showsHeroRoundOneNotice,
            roundOpenerNotice: roundOpenerNotice,
            showsBattleTacticGuide: showsBattleTacticCommandGuideSection,
            currentPhase: viewModel.trackerState.currentPhase,
            isMovementPhase: isMovementPhase,
            activePlayerName: viewModel.trackerState.activePlayerIsOne
                ? viewModel.playerOneName
                : viewModel.playerTwoName,
            activeArmy: viewModel.activeArmy,
            unitWoundsRemaining: viewModel.trackerState.unitWoundsRemaining,
            playerOneName: viewModel.playerOneName,
            playerTwoName: viewModel.playerTwoName,
            playerOneArmy: viewModel.playerOneArmy,
            playerTwoArmy: viewModel.playerTwoArmy,
            calledUnitKeys: viewModel.trackerState.calledReinforcementUnitKeys,
            showsCallReminder: viewModel.pendingReinforcementCall != nil
        )
    }
}
