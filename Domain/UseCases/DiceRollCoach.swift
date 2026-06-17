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

    public static func hitHint(input: AttackRollInput) -> Hint {
        if input.hitRoll == 1 {
            return Hint(text: String(localized: "Natural 1 — always fails."), passed: false)
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

    public static func woundHint(input: AttackRollInput) -> Hint {
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

    public static func saveHint(input: AttackRollInput) -> Hint {
        if CombatRollResolution.skipsSaveRoll(input) {
            return Hint(text: String(localized: "No save roll — mortal damage."), passed: false)
        }
        if input.saveRoll == 1 {
            return Hint(text: String(localized: "Natural 1 — always fails."), passed: false)
        }
        let effective = CombatRollResolution.effectiveSave(input)
        let passed = CombatRollResolution.saveSucceeded(input)
        let outcome = passed ? String(localized: "Saved") : String(localized: "Failed save")
        let text: String
        if input.rend == 0, input.saveModifier == 0 {
            text = String(localized: "Rolled \(input.saveRoll) vs Save \(input.saveTarget)+ — \(outcome).")
        } else {
            let rendNote = input.rend == 0 ? "" : " (Rend \(input.rend >= 0 ? "+" : "")\(input.rend))"
            let saveModNote = input.saveModifier == 0
                ? ""
                : " (\(input.saveModifier >= 0 ? "+" : "")\(input.saveModifier) save)"
            text = String(
                localized: """
                Rolled \(input.saveRoll)\(saveModNote)\(rendNote) = \(effective) vs Save \(input.saveTarget)+ — \(outcome).
                """
            )
        }
        return Hint(text: text, passed: passed)
    }

    public static func wardHint(input: AttackRollInput) -> Hint? {
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
}
