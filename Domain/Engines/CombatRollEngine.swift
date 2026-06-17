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
        wardRoll: Int? = nil
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
}

/// Evaluates a single attack per AoS Core Rules combat sequence (simplified v1).
public enum CombatRollEngine: Sendable {
    private static let modifierCap = 1

    public static func evaluate(_ input: AttackRollInput) -> AttackRollEvaluation {
        var steps: [AttackRollStep] = []

        let cappedHitMod = capped(input.hitModifier)
        let effectiveHit = input.hitRoll + cappedHitMod
        let hitSuccess = input.hitRoll != 1 && effectiveHit >= input.hitTarget
        steps.append(
            AttackRollStep(
                id: "hit",
                name: "Hit Roll",
                outcome: hitSuccess ? .success : .failure,
                explanation: hitExplanation(input: input, effective: effectiveHit, cappedMod: cappedHitMod)
            )
        )

        guard hitSuccess else {
            return AttackRollEvaluation(steps: steps, damageDealt: 0)
        }

        let cappedWoundMod = capped(input.woundModifier)
        let effectiveWound = input.woundRoll + cappedWoundMod
        let woundSuccess = input.woundRoll != 1 && effectiveWound >= input.woundTarget
        steps.append(
            AttackRollStep(
                id: "wound",
                name: "Wound Roll",
                outcome: woundSuccess ? .success : .failure,
                explanation: woundExplanation(input: input, effective: effectiveWound, cappedMod: cappedWoundMod)
            )
        )

        guard woundSuccess else {
            return AttackRollEvaluation(steps: steps, damageDealt: 0)
        }

        let effectiveSave = input.saveRoll + input.saveModifier - input.rend
        let saveSuccess = input.saveRoll != 1 && effectiveSave >= input.saveTarget
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

        if let wardTarget = input.wardTarget, let wardRoll = input.wardRoll {
            let wardSuccess = wardRoll != 1 && wardRoll >= wardTarget
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
            steps.append(
                AttackRollStep(
                    id: "damage",
                    name: "Damage",
                    outcome: .success,
                    explanation: "Save failed — \(damage) damage point\(damage == 1 ? "" : "s") to allocate."
                )
            )
        }

        return AttackRollEvaluation(steps: steps, damageDealt: damage)
    }

    private static func capped(_ modifier: Int) -> Int {
        min(max(modifier, -modifierCap), modifierCap)
    }

    private static func hitExplanation(input: AttackRollInput, effective: Int, cappedMod: Int) -> String {
        if input.hitRoll == 1 {
            return "Unmodified roll of 1 always fails."
        }
        let modNote = cappedMod == 0 ? "" : " (modifier capped to \(cappedMod >= 0 ? "+" : "")\(cappedMod))"
        return "Rolled \(input.hitRoll)\(modNote) vs Hit \(input.hitTarget)+ — \(effective >= input.hitTarget ? "hit" : "miss")."
    }

    private static func woundExplanation(input: AttackRollInput, effective: Int, cappedMod: Int) -> String {
        if input.woundRoll == 1 {
            return "Unmodified roll of 1 always fails."
        }
        let modNote = cappedMod == 0 ? "" : " (modifier capped to \(cappedMod >= 0 ? "+" : "")\(cappedMod))"
        return "Rolled \(input.woundRoll)\(modNote) vs Wound \(input.woundTarget)+ — \(effective >= input.woundTarget ? "wound" : "no wound")."
    }

    private static func saveExplanation(input: AttackRollInput, effective: Int) -> String {
        if input.saveRoll == 1 {
            return "Unmodified roll of 1 always fails."
        }
        let rendNote = input.rend == 0 ? "" : " after Rend \(input.rend)"
        return "Rolled \(input.saveRoll) + modifiers\(rendNote) = \(effective) vs Save \(input.saveTarget)+ — \(effective >= input.saveTarget ? "saved" : "failed save")."
    }

    private static func wardExplanation(wardRoll: Int, wardTarget: Int, success: Bool) -> String {
        if wardRoll == 1 {
            return "Unmodified roll of 1 always fails ward."
        }
        return "Rolled \(wardRoll) vs Ward \(wardTarget)+ — \(success ? "damage ignored" : "ward failed")."
    }
}
