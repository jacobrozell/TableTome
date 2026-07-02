import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    var usesPadTabbedTwoColumnLayout: Bool {
        layoutContext.usesPadSplitNavigation && !dynamicTypeSize.needsLayoutAdaptation
    }

    var showsBattleTrackerSectionTabs: Bool {
        usesCompactBattleTrackerChrome || usesPadTabbedTwoColumnLayout
    }

    var padControlColumnMaxWidth: CGFloat {
        layoutContext == .padLandscape
            ? DesignTokens.battleTrackerLandscapeControlColumnMaxWidth
            : DesignTokens.battleTrackerControlColumnMaxWidth
    }

    var padSidebarColumnMaxWidth: CGFloat {
        if isEmbeddedInGuidedMatch {
            return layoutContext == .padLandscape ? 320 : 300
        }
        return layoutContext == .padLandscape ? 340 : 380
    }

    var padEmbeddedCombatSidebarMaxWidth: CGFloat {
        layoutContext == .padLandscape ? 320 : 300
    }

    var padLayoutSpacing: CGFloat {
        layoutContext == .padLandscape
            ? DesignTokens.battleTrackerLandscapeSectionSpacing
            : DesignTokens.Spacing.lg
    }

    var padTabbedTwoColumnLayout: some View {
        BattleTrackerPadTabbedLayout(
            spacing: padLayoutSpacing,
            reduceMotion: reduceMotion,
            showsBattleTrackerCoach: showsBattleTrackerCoach,
            selectedSectionTab: selectedSectionTab,
            maxContentWidth: padContentMaxWidth,
            contentAlignment: padContentAlignment,
            tabHint: { tabHintSection },
            tabContent: { padTabContentView() }
        )
    }

    private var padContentMaxWidth: CGFloat? {
        isEmbeddedInGuidedMatch ? nil : DesignTokens.battleTrackerRegularMaxWidth
    }

    private var padContentAlignment: Alignment {
        isEmbeddedInGuidedMatch ? .leading : .center
    }

    private func padTabContentView() -> some View {
        BattleTrackerPadTabContent(
            selectedSectionTab: selectedSectionTab,
            setup: { padSetupColumnsView() },
            turn: { padTurnColumnsView() },
            combat: { padCombatColumnsView() },
            army: { padArmyColumnsView() }
        )
    }

    private func padSetupColumnsView() -> some View {
        BattleTrackerPadSetupColumns(
            spacing: padLayoutSpacing,
            showsBattleTacticDecks: viewModel.playContext.capabilities.showsBattleTacticDecks,
            battleRound: viewModel.trackerState.battleRound,
            roundOpenerIsIncomplete: viewModel.roundOpenerIsIncomplete,
            viewModel: viewModel,
            deployment: { deploymentSectionView() },
            startOfRound: { startOfRoundHelperView() }
        )
    }

    private func padTurnColumnsView() -> some View {
        let inputs = sharedTurnTabInputs()
        return BattleTrackerPadTurnColumns(
            showsSlimTurnTab: showsSlimTurnTab,
            spacing: padLayoutSpacing,
            controlColumnMaxWidth: padControlColumnMaxWidth,
            sidebarColumnMaxWidth: padSidebarColumnMaxWidth,
            showsSpearheadBattleChrome: showsSpearheadBattleChrome,
            showsScoringContext: showsScoringContext,
            showsVictoryPointsOnTurnTab: showsVictoryPointsOnTurnTab,
            showsDedicatedCombatTab: showsDedicatedCombatTab,
            showsPhasePlaybook: showsPhasePlaybook,
            viewModel: viewModel,
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
            showsBattleTacticGuide: inputs.showsBattleTacticGuide,
            currentPhase: inputs.currentPhase,
            isMovementPhase: inputs.isMovementPhase,
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
            quickActions: { quickActionsSection },
            phasePlaybook: { phasePlaybookSection }
        )
    }

    private func padCombatColumnsView() -> some View {
        BattleTrackerPadCombatColumns(
            showsActivationBar: viewModel.playContext.capabilities.showsActivationBar,
            isEmbeddedInGuidedMatch: isEmbeddedInGuidedMatch,
            sidebarColumnMaxWidth: padSidebarColumnMaxWidth,
            embeddedSidebarMaxWidth: padEmbeddedCombatSidebarMaxWidth,
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
            combatActivation: { combatActivationSection }
        )
    }

    private func padArmyColumnsView() -> some View {
        BattleTrackerPadArmyColumns(
            controlColumnMaxWidth: padControlColumnMaxWidth,
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
}

enum BattleTrackerPadColumnBalance {
    case controlSidebar
    case contentPrimary
}

struct BattleTrackerPadTwoColumnRow<Primary: View, Secondary: View>: View {
    let controlColumnMaxWidth: CGFloat
    let balance: BattleTrackerPadColumnBalance
    let primary: Primary
    let secondary: Secondary

    init(
        controlColumnMaxWidth: CGFloat,
        balance: BattleTrackerPadColumnBalance = .controlSidebar,
        @ViewBuilder primary: () -> Primary,
        @ViewBuilder secondary: () -> Secondary
    ) {
        self.controlColumnMaxWidth = controlColumnMaxWidth
        self.balance = balance
        self.primary = primary()
        self.secondary = secondary()
    }

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
            primaryColumn
            secondaryColumn
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var primaryColumn: some View {
        let column = VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            primary
        }
        switch balance {
        case .controlSidebar:
            column
                .frame(minWidth: 0, maxWidth: controlColumnMaxWidth, alignment: .leading)
        case .contentPrimary:
            column
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
        }
    }

    @ViewBuilder
    private var secondaryColumn: some View {
        let column = VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            secondary
        }
        switch balance {
        case .controlSidebar:
            column
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
        case .contentPrimary:
            column
                .frame(minWidth: 0, maxWidth: controlColumnMaxWidth, alignment: .leading)
        }
    }
}
