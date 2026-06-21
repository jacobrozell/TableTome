import Foundation

/// 11th Edition Warhammer 40,000 hit / wound / save predicates — not shared with Combat Patrol (10e).
public enum Wh40k11eCombatRollResolution: Sendable {
    public static func effectiveHit(_ input: AttackRollInput) -> Int {
        input.hitRoll + input.hitModifier
    }

    public static func effectiveWound(_ input: AttackRollInput) -> Int {
        input.woundRoll + input.woundModifier
    }

    /// `rend` stores AP magnitude — higher AP worsens the required armour save.
    public static func saveNeededOnDice(saveTarget: Int, ap: Int, saveModifier: Int) -> Int {
        min(7, max(2, saveTarget + ap - saveModifier))
    }

    public static func effectiveSaveNeeded(_ input: AttackRollInput) -> Int {
        saveNeededOnDice(
            saveTarget: input.saveTarget,
            ap: input.rend,
            saveModifier: input.saveModifier
        )
    }

    public static func hitSucceeded(_ input: AttackRollInput) -> Bool {
        input.hitRoll == 6 || (input.hitRoll != 1 && effectiveHit(input) >= input.hitTarget)
    }

    public static func woundSucceeded(_ input: AttackRollInput) -> Bool {
        input.woundRoll == 6 || (input.woundRoll != 1 && effectiveWound(input) >= input.woundTarget)
    }

    public static func skipsSaveRoll(_ input: AttackRollInput) -> Bool {
        input.mortalDamage
    }

    /// Armour save only — invulnerable save is evaluated separately.
    public static func armourSaveSucceeded(_ input: AttackRollInput) -> Bool {
        input.saveRoll != 1 && input.saveRoll >= effectiveSaveNeeded(input)
    }

    /// Invulnerable save ignores AP; stored in `wardTarget` / `wardRoll` for roll input.
    public static func invulnerableSaveSucceeded(_ input: AttackRollInput) -> Bool {
        guard let target = input.wardTarget, let roll = input.wardRoll else { return false }
        return roll != 1 && roll >= target
    }

    public static func saveSucceeded(_ input: AttackRollInput) -> Bool {
        armourSaveSucceeded(input) || invulnerableSaveSucceeded(input)
    }

    public static func damageWouldBeDealt(_ input: AttackRollInput) -> Bool {
        guard hitSucceeded(input), woundSucceeded(input) else { return false }
        if skipsSaveRoll(input) { return input.damage > 0 }
        return !saveSucceeded(input) && input.damage > 0
    }
}
