import SwiftUI
import TabletomeDomain
import TabletomeData

extension BattlePhaseTrackerView {
    func syncCombatContext() {
        combatViewModel.syncBattleContext(
            activePlayerIsOne: viewModel.trackerState.activePlayerIsOne,
            playerOneArmyId: viewModel.playerOneArmy?.id,
            playerTwoArmyId: viewModel.playerTwoArmy?.id
        )
    }

    func syncMultiAttack() {
        guard let weapon = combatViewModel.selectedAttackerWeapon,
              let unit = combatViewModel.selectedAttackerUnit,
              let save = combatViewModel.selectedDefenderUnit?.save else { return }
        let mods = CombatMatchupBuffCatalog.aggregateModifiers(
            from: combatViewModel.matchupBuffs,
            enabledIds: combatViewModel.enabledBuffIds
        )
        multiAttackViewModel.apply(
            weapon: weapon,
            saveTarget: save,
            unitId: unit.id,
            deployedModelCount: combatViewModel.attackerDeployedModelCount,
            wardTarget: CombatRollEngineRouter.usesWh40kRules(gameSystemId: combatViewModel.gameSystemId)
                ? nil
                : combatViewModel.activeWardTarget,
            resolvedAttackCount: combatViewModel.resolvedVariableAttackCount
        )
        multiAttackViewModel.bind(
            weapon: weapon,
            unitId: unit.id,
            unitModelCount: unit.modelCount
        )
        multiAttackViewModel.hitModifier = mods.hit
        multiAttackViewModel.woundModifier = mods.wound
        multiAttackViewModel.saveModifier = mods.save
        multiAttackViewModel.damage = combatViewModel.damage
    }

    func applyCombatDamage(_ damage: Int, batchLog: CombatBatchLogContext? = nil) {
        if let batchLog {
            viewModel.recordCombatBatchResolved(batchLog)
        }
        guard let armyId = combatViewModel.defenderArmyId.nilIfEmpty,
              let unitId = combatViewModel.defenderUnitId.nilIfEmpty,
              let defender = combatViewModel.selectedDefenderUnit,
              let previous = viewModel.applyDamageToUnit(armyId: armyId, unitId: unitId, damage: damage) else { return }
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unitId)
        damageUndoNotice = DamageUndoNotice(
            message: String(localized: "Applied \(damage) damage to \(defender.name)."),
            woundKey: key,
            previousWounds: previous
        )
    }

    func handleArmyUnitSelection(
        armyId: String,
        unitId: String,
        preferredWeaponId: String? = nil
    ) {
        presentUnitFocus(armyId: armyId, unitId: unitId, preferredWeaponId: preferredWeaponId)
    }

    func applyArmyUnitCombatPrefill(
        armyId: String,
        unitId: String,
        preferredWeaponId: String? = nil
    ) {
        guard ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId) else { return }
        let playerOneArmyId = viewModel.playerOneArmy?.id
        let playerTwoArmyId = viewModel.playerTwoArmy?.id
        let attackerArmyId = viewModel.trackerState.activePlayerIsOne ? playerOneArmyId : playerTwoArmyId
        let defenderArmyId = viewModel.trackerState.activePlayerIsOne ? playerTwoArmyId : playerOneArmyId

        if armyId == attackerArmyId {
            combatViewModel.setAttackerUnit(unitId)
            if let preferredWeaponId,
               combatViewModel.evaluableWeapons.contains(where: { $0.id == preferredWeaponId }) {
                combatViewModel.setAttackerWeapon(preferredWeaponId)
                syncMultiAttack()
            }
        } else if armyId == defenderArmyId {
            combatViewModel.setDefenderUnit(unitId)
        }
        showsAdvancedOptions = combatViewModel.hasSuggestedWardBuffs
        showsCombatResolver = true
        scrollToCombatResolver = true
    }

    func handleResolveAttack(_ ability: TriggeredAbility) {
        guard ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId) else { return }
        if let unitId = viewModel.unitId(matchingSource: ability.source, in: viewModel.activeArmy) {
            combatViewModel.prefillAttackerUnit(unitId: unitId)
        }
        showsAdvancedOptions = combatViewModel.hasSuggestedWardBuffs
        scrollToCombatResolver = true
    }

    func requestCombatResolverFocus(using proxy: ScrollViewProxy) {
        showsCombatResolver = true
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) {
            proxy.scrollTo("combatResolver", anchor: .top)
        }
    }

    var combatAttackerName: String {
        viewModel.trackerState.activePlayerIsOne ? viewModel.playerOneName : viewModel.playerTwoName
    }

    var combatDefenderName: String {
        viewModel.trackerState.activePlayerIsOne ? viewModel.playerTwoName : viewModel.playerOneName
    }

    var deploymentIsComplete: Bool {
        if viewModel.usesAlternatingActivation {
            return ScTmgDeploymentChecklist.completionCount(
                completedSteps: viewModel.trackerState.completedDeploymentSteps
            ).done == ScTmgDeploymentChecklistStep.allCases.count
        }
        if viewModel.playContext.capabilities.usesPatrolFormatRules {
            return CombatPatrolDeploymentChecklist.completionCount(
                completedSteps: viewModel.trackerState.completedDeploymentSteps
            ).done == CombatPatrolDeploymentChecklistStep.allCases.count
        }
        if viewModel.gameSystemId == .wh40k11e {
            return Wh40kDeploymentChecklist.completionCount(
                completedSteps: viewModel.trackerState.completedDeploymentSteps
            ).done == Wh40kDeploymentChecklistStep.allCases.count
        }
        return DeploymentChecklist.completionCount(completedSteps: viewModel.trackerState.completedDeploymentSteps).done
            == DeploymentChecklistStep.allCases.count
    }

    var defenderWoundsRemaining: Int? {
        guard let key = combatViewModel.defenderWoundKey else { return nil }
        return viewModel.trackerState.unitWoundsRemaining[key]
    }

    var defenderWoundsSummaryLabel: String? {
        guard let defender = combatViewModel.selectedDefenderUnit,
              let remaining = defenderWoundsRemaining else { return nil }
        let capacity = viewModel.woundCapacity(
            for: combatViewModel.defenderArmyId,
            unit: defender
        )
        if remaining == 0 {
            return String(localized: "\(defender.name): destroyed")
        }
        return String(localized: "\(defender.name): \(remaining)/\(capacity) wounds")
    }

    static func matchupPrefill(for player: PlayerArmySelection) -> MatchupUnitPrefill? {
        guard !player.armyId.isEmpty else { return nil }
        return MatchupUnitPrefill(armyId: player.armyId, unitId: "")
    }

    static func catalogRepository(for gameSystemId: GameSystemId) -> any SpearheadCatalogRepository {
        GameSystemCatalogRepository(
            gameSystemId: gameSystemId.rawValue,
            repository: BundledPlayCatalogRepository()
        )
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
