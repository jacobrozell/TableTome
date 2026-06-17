import Foundation

public enum RollOutcome: Equatable, Sendable {
    case success
    case failure
}

public struct AttackRollInput: Sendable, Equatable {
    public let hitTarget: Int
    public let woundTarget: Int
    public let saveTarget: Int
    public let rend: Int
    public let damage: Int
    public let hitRoll: Int
    public let woundRoll: Int
    public let saveRoll: Int
    public let hitModifier: Int
    public let woundModifier: Int
    public let saveModifier: Int
    public let wardTarget: Int?
    public let wardRoll: Int?
    public let critAutoWound: Bool
    public let critMortal: Bool
    public let mortalDamage: Bool

    public init(
        hitTarget: Int,
        woundTarget: Int,
        saveTarget: Int,
        rend: Int,
        damage: Int,
        hitRoll: Int,
        woundRoll: Int,
        saveRoll: Int,
        hitModifier: Int = 0,
        woundModifier: Int = 0,
        saveModifier: Int = 0,
        wardTarget: Int? = nil,
        wardRoll: Int? = nil,
        critAutoWound: Bool = false,
        critMortal: Bool = false,
        mortalDamage: Bool = false
    ) {
        self.hitTarget = hitTarget
        self.woundTarget = woundTarget
        self.saveTarget = saveTarget
        self.rend = rend
        self.damage = damage
        self.hitRoll = hitRoll
        self.woundRoll = woundRoll
        self.saveRoll = saveRoll
        self.hitModifier = hitModifier
        self.woundModifier = woundModifier
        self.saveModifier = saveModifier
        self.wardTarget = wardTarget
        self.wardRoll = wardRoll
        self.critAutoWound = critAutoWound
        self.critMortal = critMortal
        self.mortalDamage = mortalDamage
    }
}

public struct AttackRollStep: Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let outcome: RollOutcome
    public let explanation: String

    public init(id: String, name: String, outcome: RollOutcome, explanation: String) {
        self.id = id
        self.name = name
        self.outcome = outcome
        self.explanation = explanation
    }
}

public struct AttackRollEvaluation: Sendable, Equatable {
    public let steps: [AttackRollStep]
    public let damageDealt: Int

    public init(steps: [AttackRollStep], damageDealt: Int) {
        self.steps = steps
        self.damageDealt = damageDealt
    }

    public var outcomeHeadline: String {
        if damageDealt > 0 {
            return String(localized: "\(damageDealt) damage to allocate")
        }
        if let failedStep = steps.first(where: { $0.outcome == .failure }) {
            return String(localized: "Attack stopped — \(failedStep.name) failed")
        }
        return String(localized: "No damage dealt")
    }

    public var attackSucceeded: Bool {
        damageDealt > 0
    }
}

/// Evaluates a single attack per AoS Core Rules combat sequence (simplified v1).
public enum CombatRollEngine: Sendable {
    public static func evaluate(_ input: AttackRollInput) -> AttackRollEvaluation {
        var steps: [AttackRollStep] = []

        let cappedHitMod = CombatRollResolution.cappedHitModifier(input)
        let effectiveHit = CombatRollResolution.effectiveHit(input)
        let criticalHit = CombatRollResolution.criticalHit(input)
        let hitSuccess = CombatRollResolution.hitSucceeded(input)
        steps.append(
            AttackRollStep(
                id: "hit",
                name: "Hit Roll",
                outcome: hitSuccess ? .success : .failure,
                explanation: hitExplanation(
                    input: input,
                    effective: effectiveHit,
                    cappedMod: cappedHitMod,
                    criticalHit: criticalHit
                )
            )
        )

        guard hitSuccess else {
            return AttackRollEvaluation(steps: steps, damageDealt: 0)
        }

        let cappedWoundMod = CombatRollResolution.cappedWoundModifier(input)
        let effectiveWound = CombatRollResolution.effectiveWound(input)
        let criticalWound = CombatRollResolution.criticalWound(input)
        let woundSuccess = CombatRollResolution.woundSucceeded(input)
        steps.append(
            AttackRollStep(
                id: "wound",
                name: "Wound Roll",
                outcome: woundSuccess ? .success : .failure,
                explanation: woundExplanation(
                    input: input,
                    effective: effectiveWound,
                    cappedMod: cappedWoundMod,
                    criticalHit: criticalHit,
                    criticalWound: criticalWound
                )
            )
        )

        guard woundSuccess else {
            return AttackRollEvaluation(steps: steps, damageDealt: 0)
        }

        let skipSave = CombatRollResolution.skipsSaveRoll(input)
        if skipSave {
            steps.append(
                AttackRollStep(
                    id: "save",
                    name: "Save Roll",
                    outcome: .failure,
                    explanation: criticalWound
                        ? "Crit (Mortal) — unmodified wound roll of 6. No save roll; mortal damage."
                        : "Mortal damage — no save roll."
                )
            )
        } else {
            let effectiveSave = CombatRollResolution.effectiveSave(input)
            let saveSuccess = CombatRollResolution.saveSucceeded(input)
            steps.append(
                AttackRollStep(
                    id: "save",
                    name: "Save Roll",
                    outcome: saveSuccess ? .success : .failure,
                    explanation: saveExplanation(input: input, effective: effectiveSave)
                )
            )
            guard !saveSuccess else {
                return AttackRollEvaluation(steps: steps, damageDealt: 0)
            }
        }

        if let wardTarget = input.wardTarget, let wardRoll = input.wardRoll, !skipSave {
            let wardSuccess = CombatRollResolution.wardSucceeded(input)
            steps.append(
                AttackRollStep(
                    id: "ward",
                    name: "Ward Roll",
                    outcome: wardSuccess ? .success : .failure,
                    explanation: wardExplanation(wardRoll: wardRoll, wardTarget: wardTarget, success: wardSuccess)
                )
            )
            if wardSuccess {
                return AttackRollEvaluation(steps: steps, damageDealt: 0)
            }
        }

        let damage = input.damage
        if damage > 0 {
            let mortalNote = skipSave ? " (mortal)" : ""
            steps.append(
                AttackRollStep(
                    id: "damage",
                    name: "Damage",
                    outcome: .success,
                    explanation: "\(damage) damage point\(damage == 1 ? "" : "s")\(mortalNote) to allocate."
                )
            )
        }

        return AttackRollEvaluation(steps: steps, damageDealt: damage)
    }

    private static func hitExplanation(
        input: AttackRollInput,
        effective: Int,
        cappedMod: Int,
        criticalHit: Bool
    ) -> String {
        if input.hitRoll == 1 {
            return "Unmodified roll of 1 always fails."
        }
        if criticalHit {
            return "Unmodified roll of 6 with Crit (Auto-wound) — automatic wound."
        }
        let modNote = cappedMod == 0 ? "" : " (modifier capped to \(cappedMod >= 0 ? "+" : "")\(cappedMod))"
        return "Rolled \(input.hitRoll)\(modNote) vs Hit \(input.hitTarget)+ — \(effective >= input.hitTarget ? "hit" : "miss")."
    }

    private static func woundExplanation(
        input: AttackRollInput,
        effective: Int,
        cappedMod: Int,
        criticalHit: Bool,
        criticalWound: Bool
    ) -> String {
        if criticalHit {
            return "Crit (Auto-wound) from hit roll — wound succeeded automatically."
        }
        if input.woundRoll == 1 {
            return "Unmodified roll of 1 always fails."
        }
        if criticalWound {
            return "Unmodified roll of 6 with Crit (Mortal) — wound succeeds; damage will be mortal."
        }
        let modNote = cappedMod == 0 ? "" : " (modifier capped to \(cappedMod >= 0 ? "+" : "")\(cappedMod))"
        return "Rolled \(input.woundRoll)\(modNote) vs Wound \(input.woundTarget)+ — \(effective >= input.woundTarget ? "wound" : "no wound")."
    }

    private static func saveExplanation(input: AttackRollInput, effective: Int) -> String {
        if input.saveRoll == 1 {
            return "Unmodified roll of 1 always fails."
        }
        let rendNote = input.rend == 0 ? "" : " (Rend \(input.rend >= 0 ? "+" : "")\(input.rend))"
        return "Rolled \(input.saveRoll) + modifiers\(rendNote) = \(effective) vs Save \(input.saveTarget)+ — \(effective >= input.saveTarget ? "saved" : "failed save")."
    }

    private static func wardExplanation(wardRoll: Int, wardTarget: Int, success: Bool) -> String {
        if wardRoll == 1 {
            return "Unmodified roll of 1 always fails ward."
        }
        return "Rolled \(wardRoll) vs Ward \(wardTarget)+ — \(success ? "damage ignored" : "ward failed")."
    }
}
