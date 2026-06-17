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
            wardTarget: combatViewModel.activeWardTarget
        )
        multiAttackViewModel.bind(weapon: weapon, unitId: unit.id)
        multiAttackViewModel.hitModifier = mods.hit
        multiAttackViewModel.woundModifier = mods.wound
        multiAttackViewModel.saveModifier = mods.save
        multiAttackViewModel.damage = combatViewModel.damage
    }

    func applyCombatDamage(_ damage: Int) {
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

    func handleArmyUnitSelection(armyId: String, unitId: String) {
        let playerOneArmyId = viewModel.playerOneArmy?.id
        let playerTwoArmyId = viewModel.playerTwoArmy?.id
        let attackerArmyId = viewModel.trackerState.activePlayerIsOne ? playerOneArmyId : playerTwoArmyId
        let defenderArmyId = viewModel.trackerState.activePlayerIsOne ? playerTwoArmyId : playerOneArmyId

        if armyId == attackerArmyId {
            combatViewModel.setAttackerUnit(unitId)
        } else if armyId == defenderArmyId {
            combatViewModel.setDefenderUnit(unitId)
        }
        showsAdvancedOptions = combatViewModel.hasSuggestedWardBuffs
        scrollToCombatResolver = true
    }

    func handleResolveAttack(_ ability: TriggeredAbility) {
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
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
