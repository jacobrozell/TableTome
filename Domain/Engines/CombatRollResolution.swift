import Foundation

/// Shared hit / wound / save predicates used by the evaluator and simulated roll sequence.
public enum CombatRollResolution: Sendable {
    private static let modifierCap = 1

    public static func input(
        from parameters: AttackRollParameters,
        hitRoll: Int,
        woundRoll: Int,
        saveRoll: Int,
        wardRoll: Int?,
        damage: Int
    ) -> AttackRollInput {
        AttackRollInput(
            hitTarget: parameters.hitTarget,
            woundTarget: parameters.woundTarget,
            saveTarget: parameters.saveTarget,
            rend: parameters.rend,
            damage: damage,
            hitRoll: hitRoll,
            woundRoll: woundRoll,
            saveRoll: saveRoll,
            hitModifier: parameters.hitModifier,
            woundModifier: parameters.woundModifier,
            saveModifier: parameters.saveModifier,
            wardTarget: parameters.wardTarget,
            wardRoll: wardRoll,
            critAutoWound: parameters.critAutoWound,
            critMortal: parameters.critMortal,
            mortalDamage: parameters.mortalDamage
        )
    }

    public static func cappedHitModifier(_ input: AttackRollInput) -> Int {
        capped(input.hitModifier)
    }

    public static func cappedWoundModifier(_ input: AttackRollInput) -> Int {
        capped(input.woundModifier)
    }

    public static func effectiveHit(_ input: AttackRollInput) -> Int {
        input.hitRoll + cappedHitModifier(input)
    }

    public static func effectiveWound(_ input: AttackRollInput) -> Int {
        input.woundRoll + cappedWoundModifier(input)
    }

    public static func effectiveSave(_ input: AttackRollInput) -> Int {
        input.saveRoll + input.saveModifier + input.rend
    }

    public static func criticalHit(_ input: AttackRollInput) -> Bool {
        input.hitRoll == 6 && input.critAutoWound
    }

    public static func hitSucceeded(_ input: AttackRollInput) -> Bool {
        input.hitRoll != 1 && (effectiveHit(input) >= input.hitTarget || criticalHit(input))
    }

    public static func requiresWoundRoll(_ input: AttackRollInput) -> Bool {
        !criticalHit(input)
    }

    public static func criticalWound(_ input: AttackRollInput) -> Bool {
        input.woundRoll == 6 && input.critMortal
    }

    public static func woundSucceeded(_ input: AttackRollInput) -> Bool {
        criticalHit(input)
            || (input.woundRoll != 1 && effectiveWound(input) >= input.woundTarget)
    }

    public static func skipsSaveRoll(_ input: AttackRollInput) -> Bool {
        input.mortalDamage || criticalWound(input)
    }

    public static func saveSucceeded(_ input: AttackRollInput) -> Bool {
        input.saveRoll != 1 && effectiveSave(input) >= input.saveTarget
    }

    public static func wardSucceeded(_ input: AttackRollInput) -> Bool {
        guard let wardTarget = input.wardTarget, let wardRoll = input.wardRoll else { return false }
        return wardRoll != 1 && wardRoll >= wardTarget
    }

    public static func damageWouldBeDealt(_ input: AttackRollInput) -> Bool {
        guard hitSucceeded(input), woundSucceeded(input) else { return false }
        if skipsSaveRoll(input) { return input.damage > 0 }
        guard !saveSucceeded(input) else { return false }
        if input.wardTarget != nil, input.wardRoll != nil {
            return !wardSucceeded(input) && input.damage > 0
        }
        return input.damage > 0
    }

    private static func capped(_ modifier: Int) -> Int {
        min(max(modifier, -modifierCap), modifierCap)
    }
}
