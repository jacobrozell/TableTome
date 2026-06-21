import Foundation

/// Evaluates a single 11th Edition attack — separate from Combat Patrol (10e) engine.
public enum Wh40k11eCombatRollEngine: Sendable {
    public static func evaluate(_ input: AttackRollInput) -> AttackRollEvaluation {
        var steps: [AttackRollStep] = []

        let hitSuccess = Wh40k11eCombatRollResolution.hitSucceeded(input)
        steps.append(
            AttackRollStep(
                id: "hit",
                name: String(localized: "Hit Roll"),
                outcome: hitSuccess ? .success : .failure,
                explanation: hitExplanation(input: input, success: hitSuccess)
            )
        )
        guard hitSuccess else {
            return AttackRollEvaluation(steps: steps, damageDealt: 0)
        }

        let woundSuccess = Wh40k11eCombatRollResolution.woundSucceeded(input)
        steps.append(
            AttackRollStep(
                id: "wound",
                name: String(localized: "Wound Roll"),
                outcome: woundSuccess ? .success : .failure,
                explanation: woundExplanation(input: input, success: woundSuccess)
            )
        )
        guard woundSuccess else {
            return AttackRollEvaluation(steps: steps, damageDealt: 0)
        }

        if Wh40k11eCombatRollResolution.skipsSaveRoll(input) {
            steps.append(
                AttackRollStep(
                    id: "save",
                    name: String(localized: "Save Roll"),
                    outcome: .failure,
                    explanation: String(localized: "Mortal damage — no save roll.")
                )
            )
        } else {
            let armourSuccess = Wh40k11eCombatRollResolution.armourSaveSucceeded(input)
            steps.append(
                AttackRollStep(
                    id: "save",
                    name: String(localized: "Armour Save"),
                    outcome: armourSuccess ? .success : .failure,
                    explanation: saveExplanation(input: input, success: armourSuccess)
                )
            )

            if let invulnTarget = input.wardTarget, input.wardRoll != nil {
                let invulnSuccess = Wh40k11eCombatRollResolution.invulnerableSaveSucceeded(input)
                steps.append(
                    AttackRollStep(
                        id: "invuln",
                        name: String(localized: "Invulnerable Save"),
                        outcome: invulnSuccess ? .success : .failure,
                        explanation: invulnExplanation(
                            input: input,
                            target: invulnTarget,
                            success: invulnSuccess
                        )
                    )
                )
            }

            guard !Wh40k11eCombatRollResolution.saveSucceeded(input) else {
                return AttackRollEvaluation(steps: steps, damageDealt: 0)
            }
        }

        let damage = input.damage
        if damage > 0 {
            steps.append(
                AttackRollStep(
                    id: "damage",
                    name: String(localized: "Damage"),
                    outcome: .success,
                    explanation: String(
                        localized: "\(damage) damage point\(damage == 1 ? "" : "s") to allocate."
                    )
                )
            )
        }

        return AttackRollEvaluation(steps: steps, damageDealt: damage)
    }

    private static func hitExplanation(input: AttackRollInput, success: Bool) -> String {
        if input.hitRoll == 1 {
            return String(localized: "Unmodified roll of 1 always fails.")
        }
        if input.hitRoll == 6 {
            return String(localized: "Unmodified roll of 6 — automatic hit.")
        }
        let modNote = input.hitModifier == 0
            ? ""
            : String(localized: " (modifier \(input.hitModifier >= 0 ? "+" : "")\(input.hitModifier))")
        return String(
            localized: "Rolled \(input.hitRoll)\(modNote) vs \(input.hitTarget)+ — \(success ? "hit" : "miss")."
        )
    }

    private static func woundExplanation(input: AttackRollInput, success: Bool) -> String {
        if input.woundRoll == 1 {
            return String(localized: "Unmodified roll of 1 always fails.")
        }
        if input.woundRoll == 6 {
            return String(localized: "Unmodified roll of 6 — automatic wound.")
        }
        let modNote = input.woundModifier == 0
            ? ""
            : String(localized: " (modifier \(input.woundModifier >= 0 ? "+" : "")\(input.woundModifier))")
        return String(
            localized: "Rolled \(input.woundRoll)\(modNote) vs \(input.woundTarget)+ — \(success ? "wound" : "no wound")."
        )
    }

    private static func saveExplanation(input: AttackRollInput, success: Bool) -> String {
        if input.saveRoll == 1 {
            return String(localized: "Unmodified roll of 1 always fails.")
        }
        let needed = Wh40k11eCombatRollResolution.effectiveSaveNeeded(input)
        if input.rend > 0 {
            return String(
                localized: """
                Rolled \(input.saveRoll) vs \(needed)+ (Save \(input.saveTarget)+, AP \(input.rend)) — \
                \(success ? "saved" : "failed save").
                """
            )
        }
        let modNote = input.saveModifier == 0
            ? ""
            : String(localized: " (modifier \(input.saveModifier >= 0 ? "+" : "")\(input.saveModifier))")
        return String(
            localized: "Rolled \(input.saveRoll)\(modNote) vs \(needed)+ — \(success ? "saved" : "failed save")."
        )
    }

    private static func invulnExplanation(input: AttackRollInput, target: Int, success: Bool) -> String {
        guard let roll = input.wardRoll else {
            return String(localized: "No invulnerable save roll entered.")
        }
        if roll == 1 {
            return String(localized: "Unmodified roll of 1 always fails.")
        }
        return String(
            localized: "Rolled \(roll) vs \(target)+ invulnerable — \(success ? "saved" : "failed save")."
        )
    }
}
