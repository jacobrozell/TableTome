import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    var compactLayoutSpacing: CGFloat {
        layoutContext == .phoneLandscape
            ? DesignTokens.phoneLandscapeSectionSpacing
            : DesignTokens.Spacing.lg
    }

    var compactLayout: some View {
        BattleTrackerCompactLayout(
            spacing: compactLayoutSpacing,
            reduceMotion: reduceMotion,
            showsBattleTrackerCoach: showsBattleTrackerCoach,
            selectedSectionTab: selectedSectionTab,
            tabHint: { tabHintSection },
            tabContent: { compactTabContentView() }
        )
    }

    private func compactTabContentView() -> some View {
        BattleTrackerCompactTabContent(
            selectedSectionTab: selectedSectionTab,
            setup: { setupTabContentView() },
            turn: { turnTabContentView() },
            combat: { combatTabContentView() },
            army: { armyTabContentView() }
        )
    }

    private func setupTabContentView() -> some View {
        BattleTrackerSetupTabContent(
            showsBattleTacticDecks: viewModel.playContext.capabilities.showsBattleTacticDecks,
            battleRound: viewModel.trackerState.battleRound,
            roundOpenerIsIncomplete: viewModel.roundOpenerIsIncomplete,
            viewModel: viewModel,
            startOfRound: { startOfRoundHelperView() },
            deployment: { deploymentSectionView() }
        )
    }

    private func turnTabContentView() -> some View {
        let inputs = sharedTurnTabInputs()
        return BattleTrackerTurnTabContent(
            viewModel: viewModel,
            showsSpearheadBattleChrome: showsSpearheadBattleChrome,
            showsScoringContext: showsScoringContext,
            showsDedicatedCombatTab: showsDedicatedCombatTab,
            showsSlimTurnTab: showsSlimTurnTab,
            showsPhasePlaybook: showsPhasePlaybook,
            showsCoach: inputs.showsCoach,
            gameSystemId: viewModel.gameSystemId,
            reduceMotion: reduceMotion,
            onDismissCoach: {
                NewPlayerTipsStore.markBattleTrackerCoachSeen()
                showsBattleTrackerCoach = false
            },
            guideStep: inputs.guideStep,
            showsGuide: inputs.showsGuide,
            onCompleteGuideStep: { viewModel.completeCurrentGuideStep() },
            onBattleCompleteGuide: {
                if ReleaseSurface.showsMatchHistory {
                    presentVictoryScreen()
                }
                dismissedBattleCompleteGuide = true
            },
            showsStartOfRoundHelper: inputs.showsStartOfRoundHelper,
            startOfRoundAbilities: inputs.startOfRoundAbilities,
            showsShootingHelper: inputs.showsShootingHelper,
            shootingUnits: inputs.shootingUnits,
            armyName: inputs.armyName,
            onSelectShootingUnit: { unitId in
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
            },
            phaseActionNudge: inputs.phaseActionNudge,
            onDismissPhaseActionNudge: { phaseActionNudge = nil },
            reinforcementPrompt: inputs.reinforcementPrompt,
            onDismissReinforcementPrompt: { viewModel.clearReinforcementCallPrompt() },
            turnHandoffNotice: inputs.turnHandoffNotice,
            onDismissTurnHandoff: { turnHandoffNotice = nil },
            scoringReminderNotice: inputs.scoringReminderNotice,
            onJumpToScoring: {
                selectedSectionTab = .turn
                scrollToVictoryPoints = true
            },
            onDismissScoringReminder: { scoringReminderNotice = nil },
            showsHeroRoundOneNotice: inputs.showsHeroRoundOneNotice,
            onDismissHeroRoundOne: {
                NewPlayerTipsStore.dismissHeroRoundOneNudge()
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                    showsHeroRoundOneNotice = false
                }
            },
            roundOpenerNotice: inputs.roundOpenerNotice,
            onJumpToRoundChecklist: { scrollToRoundChecklist = true },
            onDismissRoundOpener: { roundOpenerNotice = nil },
            showsVictoryPointsOnTurnTab: showsVictoryPointsOnTurnTab,
            showsBattleTacticGuide: inputs.showsBattleTacticGuide,
            currentPhase: inputs.currentPhase,
            isMovementPhase: inputs.isMovementPhase,
            showsSpearheadChromeForMovement: showsSpearheadBattleChrome,
            activePlayerName: inputs.activePlayerName,
            activeArmy: inputs.activeArmy,
            unitWoundsRemaining: inputs.unitWoundsRemaining,
            movementAction: $movementAction,
            playerOneName: inputs.playerOneName,
            playerTwoName: inputs.playerTwoName,
            playerOneArmy: inputs.playerOneArmy,
            playerTwoArmy: inputs.playerTwoArmy,
            calledUnitKeys: inputs.calledUnitKeys,
            showsCallReminder: inputs.showsCallReminder,
            onReinforcementOnTableChanged: { armyId, unitId, onTable in
                viewModel.setReinforcementOnTable(armyId: armyId, unitId: unitId, onTable: onTable)
            },
            phasePlaybook: { phasePlaybookSection },
            combatActivation: { combatActivationSection },
            quickActions: { quickActionsSection }
        )
    }

    private func combatTabContentView() -> some View {
        BattleTrackerCombatTabContent(
            showsActivationBar: viewModel.playContext.capabilities.showsActivationBar,
            usesPhoneLandscapeCombatSplit: usesPhoneLandscapeCombatSplit,
            showsDedicatedCombatTab: showsDedicatedCombatTab,
            showsCombatResolver: showsCombatResolverSection,
            showsSpearheadBattleChrome: showsSpearheadBattleChrome,
            isCombatPhase: isCombatRelatedPhase,
            showsShootingHelper: showsShootingPhaseHelperSection,
            shootingUnits: viewModel.shootingEligibleUnits,
            armyName: viewModel.armyName,
            gameSystemId: viewModel.gameSystemId,
            onSelectShootingUnit: { unitId in
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
            },
            showsShootInCombatHelper: showsShootInCombatPhaseHelperSection,
            shootInCombatUnits: viewModel.shootInCombatEligibleUnits,
            onSelectShootInCombatUnit: { unitId, weaponId in
                guard let armyId = viewModel.activeArmy?.id else { return }
                handleArmyUnitSelection(
                    armyId: armyId,
                    unitId: unitId,
                    preferredWeaponId: weaponId
                )
            },
            damageUndoNotice: damageUndoNotice,
            reduceMotion: reduceMotion,
            onUndoDamage: {
                if let notice = damageUndoNotice {
                    viewModel.setUnitWounds(key: notice.woundKey, remaining: notice.previousWounds)
                }
            },
            onDismissDamageUndo: { damageUndoNotice = nil },
            combatViewModel: combatViewModel,
            multiAttackViewModel: multiAttackViewModel,
            batchCombatViewModel: batchCombatViewModel,
            showsCombatResolverPanel: $showsCombatResolver,
            diceInputModeRaw: $diceInputModeRaw,
            showsAdvancedOptions: $showsAdvancedOptions,
            showsMultiAttack: $showsMultiAttack,
            showsAdvancedSingleAttack: $showsAdvancedSingleAttack,
            trackerState: viewModel.trackerState,
            attackerName: combatAttackerName,
            defenderName: combatDefenderName,
            deploymentIsComplete: deploymentIsComplete,
            defenderWoundsRemaining: defenderWoundsRemaining,
            unitWoundsRemaining: viewModel.trackerState.unitWoundsRemaining,
            ruleSections: ruleSections,
            onSyncMultiAttack: syncMultiAttack,
            onApplyDamage: applyCombatDamage,
            showsArmyTracker: showsArmyTrackerSection,
            playerOneName: viewModel.playerOneName,
            playerTwoName: viewModel.playerTwoName,
            playerOneArmy: viewModel.playerOneArmy,
            playerTwoArmy: viewModel.playerTwoArmy,
            healthPerModelOverrides: viewModel.trackerState.unitHealthPerModelOverrides,
            activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
            calledReinforcementUnitKeys: viewModel.trackerState.calledReinforcementUnitKeys,
            onUnitWoundsChange: viewModel.setUnitWounds(key:remaining:),
            onSelectArmyUnit: { armyId, unitId in
                handleArmyUnitSelection(armyId: armyId, unitId: unitId)
            },
            combatActivation: { combatActivationSection },
            phoneLandscapeSplit: { phoneLandscapeCombatSplitLayout }
        )
    }

    private func armyTabContentView() -> some View {
        BattleTrackerArmyTabContent(
            viewModel: viewModel,
            showsArmyTracker: showsArmyTrackerSection,
            playerOneName: viewModel.playerOneName,
            playerTwoName: viewModel.playerTwoName,
            playerOneArmy: viewModel.playerOneArmy,
            playerTwoArmy: viewModel.playerTwoArmy,
            unitWoundsRemaining: viewModel.trackerState.unitWoundsRemaining,
            healthPerModelOverrides: viewModel.trackerState.unitHealthPerModelOverrides,
            activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
            gameSystemId: viewModel.gameSystemId,
            calledReinforcementUnitKeys: viewModel.trackerState.calledReinforcementUnitKeys,
            onUnitWoundsChange: viewModel.setUnitWounds(key:remaining:),
            onSelectArmyUnit: { armyId, unitId in
                handleArmyUnitSelection(armyId: armyId, unitId: unitId)
            },
            ruleSections: ruleSections,
            supportsBattleTracker: supportsBattleTracker,
            showsActivationBar: viewModel.playContext.capabilities.showsActivationBar,
            usesGuidedBattleTracker: viewModel.playContext.usesGuidedBattleTracker,
            showsEmbeddedCombatTools: ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId),
            onResolveAttack: handleResolveAttack,
            secondarySections: { secondarySections },
            passiveAbilities: { passiveAbilitiesSection }
        )
    }

    var showsScoringContext: Bool {
        let phase = viewModel.trackerState.currentPhase
        if phase == .endOfTurn { return true }
        return viewModel.playContext.capabilities.showsActivationBar && phase == .scoring
    }
}
