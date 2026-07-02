import Foundation

public enum DiceRollCoach: Sendable {
    public struct Hint: Sendable, Equatable {
        public let text: String
        public let passed: Bool

        public init(text: String, passed: Bool) {
            self.text = text
            self.passed = passed
        }
    }

    public static func hitHint(input: AttackRollInput, gameSystemId: String = "aos-spearhead") -> Hint {
        if input.hitRoll == 1 {
            return Hint(text: String(localized: "Natural 1 — always fails."), passed: false)
        }
        if CombatRollEngineRouter.usesWh40kRules(gameSystemId: gameSystemId) {
            if input.hitRoll == 6 {
                return Hint(text: String(localized: "Unmodified 6 — automatic hit."), passed: true)
            }
            let passed = Wh40k10eCombatRollResolution.hitSucceeded(input)
            return Hint(
                text: String(localized: "Rolled \(input.hitRoll) — need \(input.hitTarget)+. \(passed ? "Pass" : "Fail")."),
                passed: passed
            )
        }
        if CombatRollResolution.criticalHit(input) {
            return Hint(text: String(localized: "Critical hit — automatic wound."), passed: true)
        }
        let target = input.hitTarget
        let passed = CombatRollResolution.hitSucceeded(input)
        return Hint(
            text: String(localized: "Rolled \(input.hitRoll) — need \(target)+. \(passed ? "Pass" : "Fail")."),
            passed: passed
        )
    }

    public static func woundHint(input: AttackRollInput, gameSystemId: String = "aos-spearhead") -> Hint {
        if CombatRollEngineRouter.usesWh40kRules(gameSystemId: gameSystemId) {
            if input.woundRoll == 1 {
                return Hint(text: String(localized: "Natural 1 — always fails."), passed: false)
            }
            if input.woundRoll == 6 {
                return Hint(text: String(localized: "Unmodified 6 — automatic wound."), passed: true)
            }
            let passed = Wh40k10eCombatRollResolution.woundSucceeded(input)
            return Hint(
                text: String(localized: "Rolled \(input.woundRoll) — need \(input.woundTarget)+. \(passed ? "Pass" : "Fail")."),
                passed: passed
            )
        }
        if CombatRollResolution.criticalHit(input) {
            return Hint(text: String(localized: "Auto-wound from critical hit."), passed: true)
        }
        if input.woundRoll == 1 {
            return Hint(text: String(localized: "Natural 1 — always fails."), passed: false)
        }
        if CombatRollResolution.criticalWound(input) {
            return Hint(text: String(localized: "Critical wound — mortal damage."), passed: true)
        }
        let target = input.woundTarget
        let passed = CombatRollResolution.woundSucceeded(input)
        return Hint(
            text: String(localized: "Rolled \(input.woundRoll) — need \(target)+. \(passed ? "Pass" : "Fail")."),
            passed: passed
        )
    }

    public static func saveHint(input: AttackRollInput, gameSystemId: String = "aos-spearhead") -> Hint {
        if CombatRollResolution.skipsSaveRoll(input) {
            return Hint(text: String(localized: "No save roll — mortal damage."), passed: false)
        }
        if input.saveRoll == 1 {
            return Hint(text: String(localized: "Natural 1 — always fails."), passed: false)
        }
        if CombatRollEngineRouter.usesWh40kRules(gameSystemId: gameSystemId) {
            let is11e = CombatRollEngineRouter.rulesEdition(for: gameSystemId) == .wh40k11e
            let needed = is11e
                ? Wh40k11eCombatRollResolution.effectiveSaveNeeded(input)
                : Wh40k10eCombatRollResolution.effectiveSaveNeeded(input)
            let passed = is11e
                ? Wh40k11eCombatRollResolution.armourSaveSucceeded(input)
                : Wh40k10eCombatRollResolution.saveSucceeded(input)
            let outcome = passed ? String(localized: "Saved") : String(localized: "Failed save")
            let apNote = input.rend > 0 ? String(localized: " (AP \(input.rend))") : ""
            return Hint(
                text: String(localized: "Rolled \(input.saveRoll) vs \(needed)+\(apNote) — \(outcome)."),
                passed: passed
            )
        }
        let effective = CombatRollResolution.effectiveSave(input)
        let passed = CombatRollResolution.saveSucceeded(input)
        let outcome = passed ? String(localized: "Saved") : String(localized: "Failed save")
        let needed = CombatRollResolution.saveNeededOnDice(
            saveTarget: input.saveTarget,
            rend: input.rend,
            saveModifier: input.saveModifier
        )
        let neededNote = needed > 6
            ? String(localized: "no save on D6")
            : String(localized: "need \(needed)+ on the dice")
        let text: String
        if input.rend == 0, input.saveModifier == 0 {
            text = String(localized: "Rolled \(input.saveRoll) vs Save \(input.saveTarget)+ — \(outcome).")
        } else {
            let rendNote = input.rend == 0 ? "" : " − Rend \(input.rend)"
            let saveModNote = input.saveModifier == 0
                ? ""
                : " +\(input.saveModifier) save"
            text = String(
                localized: """
                Rolled \(input.saveRoll)\(saveModNote)\(rendNote) = \(effective) vs Save \(input.saveTarget)+ — \
                \(neededNote) — \(outcome).
                """
            )
        }
        return Hint(text: text, passed: passed)
    }

    public static func wardHint(input: AttackRollInput, gameSystemId: String = "aos-spearhead") -> Hint? {
        if CombatRollEngineRouter.rulesEdition(for: gameSystemId) == .wh40k11e {
            return invulnHint(input: input)
        }
        guard !CombatRollEngineRouter.usesWh40kRules(gameSystemId: gameSystemId) else { return nil }
        guard let wardTarget = input.wardTarget, input.wardRoll != nil else { return nil }
        let wardRoll = input.wardRoll ?? 4
        if wardRoll == 1 {
            return Hint(text: String(localized: "Natural 1 — ward fails."), passed: false)
        }
        let passed = CombatRollResolution.wardSucceeded(input)
        return Hint(
            text: String(localized: "Rolled \(wardRoll) — need \(wardTarget)+. \(passed ? "Ward holds" : "Ward fails")."),
            passed: passed
        )
    }

    public static func invulnHint(input: AttackRollInput) -> Hint? {
        guard let invulnTarget = input.wardTarget, input.wardRoll != nil else { return nil }
        let invulnRoll = input.wardRoll ?? 4
        if invulnRoll == 1 {
            return Hint(text: String(localized: "Natural 1 — invulnerable save fails."), passed: false)
        }
        let passed = Wh40k11eCombatRollResolution.invulnerableSaveSucceeded(input)
        return Hint(
            text: String(
                localized: "Rolled \(invulnRoll) vs \(invulnTarget)+ invulnerable — \(passed ? "Saved" : "Failed save")."
            ),
            passed: passed
        )
    }
}
