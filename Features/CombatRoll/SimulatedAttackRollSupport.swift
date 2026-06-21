import Foundation
import TabletomeDomain
#if canImport(UIKit)
import UIKit
#endif

@MainActor
enum SimulatedAttackRollSupport {
    static func rollParameters(from viewModel: CombatRollEvaluatorViewModel) -> AttackRollParameters {
        AttackRollParameters(
            hitTarget: viewModel.hitTarget,
            woundTarget: viewModel.woundTarget,
            saveTarget: viewModel.saveTarget,
            rend: viewModel.rend,
            damage: viewModel.damage,
            hitModifier: viewModel.hitModifier,
            woundModifier: viewModel.woundModifier,
            saveModifier: viewModel.saveModifier,
            critAutoWound: viewModel.rollOptions.critAutoWound,
            critMortal: viewModel.rollOptions.critMortal,
            mortalDamage: viewModel.rollOptions.mortalDamage,
            variableDamage: viewModel.variableDamage
        )
    }

    static func rollParameters(from viewModel: UnitMatchupEvaluatorViewModel) -> AttackRollParameters? {
        guard let weapon = viewModel.selectedAttackerWeapon,
              let save = viewModel.selectedDefenderUnit?.save else { return nil }
        let mods = CombatMatchupBuffCatalog.aggregateModifiers(
            from: viewModel.matchupBuffs,
            enabledIds: viewModel.enabledBuffIds
        )
        let options = viewModel.resolvedRollOptions()
        let variableDamage: WeaponVariableDamage?
        if case .variable(let kind) = weapon.damageKind {
            variableDamage = kind
        } else {
            variableDamage = nil
        }
        return AttackRollParameters(
            hitTarget: weapon.hit,
            woundTarget: weapon.wound,
            saveTarget: save,
            rend: weapon.rend,
            damage: viewModel.damage,
            hitModifier: mods.hit,
            woundModifier: mods.wound,
            saveModifier: mods.save,
            wardTarget: viewModel.activeInvulnTarget ?? mods.wardTarget,
            critAutoWound: options.critAutoWound,
            critMortal: options.critMortal,
            mortalDamage: options.mortalDamage,
            variableDamage: variableDamage
        )
    }

    static func rollParameters(from viewModel: MultiAttackEvaluatorViewModel) -> AttackRollParameters {
        let options = viewModel.resolvedRollOptions()
        return AttackRollParameters(
            hitTarget: viewModel.hitTarget,
            woundTarget: viewModel.woundTarget,
            saveTarget: viewModel.saveTarget,
            rend: viewModel.rend,
            damage: viewModel.damage,
            hitModifier: viewModel.hitModifier,
            woundModifier: viewModel.woundModifier,
            saveModifier: viewModel.saveModifier,
            wardTarget: viewModel.wardTarget,
            critAutoWound: options.critAutoWound,
            critMortal: options.critMortal,
            mortalDamage: options.mortalDamage,
            variableDamage: viewModel.variableDamage
        )
    }

    static func rollField(
        _ purpose: RollPurpose,
        currentValue: inout Int,
        lastRolls: inout [DiceRollResult]
    ) {
        let roll = DiceRollerEngine.rollD6(purpose: purpose)
        currentValue = roll.faceValue
        if let index = lastRolls.firstIndex(where: { DiceRollDisplay.matchesPurpose($0.purpose, purpose) }) {
            lastRolls[index] = roll
        } else {
            lastRolls.append(roll)
        }
        announceRoll(roll)
    }

    static func announceRoll(_ roll: DiceRollResult) {
        #if canImport(UIKit)
        let label = DiceRollDisplay.purposeLabel(roll.purpose)
        let valueText: String
        switch roll.purpose {
        case .variableDamage(.d3):
            let d6 = roll.underlyingRolls.first ?? roll.faceValue
            valueText = "\(d6), damage \(roll.faceValue)"
        case .variableDamage(.twoD6):
            valueText = "\(roll.faceValue)"
        default:
            valueText = "\(roll.faceValue)"
        }
        UIAccessibility.post(
            notification: .announcement,
            argument: "\(label) roll, \(valueText)"
        )
        #endif
    }
}
