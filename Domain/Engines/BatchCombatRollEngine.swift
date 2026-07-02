import Foundation

public struct BatchCombatRollInput: Sendable, Equatable {
    public let successfulHits: Int
    public let successfulWounds: Int
    public let failedSaves: Int
    public let damagePerWound: Int
    public let wardNegatedCount: Int
    public let mortalDamage: Bool
    public let manualTotalDamage: Int?

    public init(
        successfulHits: Int,
        successfulWounds: Int,
        failedSaves: Int,
        damagePerWound: Int,
        wardNegatedCount: Int = 0,
        mortalDamage: Bool = false,
        manualTotalDamage: Int? = nil
    ) {
        self.successfulHits = successfulHits
        self.successfulWounds = successfulWounds
        self.failedSaves = failedSaves
        self.damagePerWound = damagePerWound
        self.wardNegatedCount = wardNegatedCount
        self.mortalDamage = mortalDamage
        self.manualTotalDamage = manualTotalDamage
    }
}

public struct BatchCombatSummaryStep: Sendable, Equatable, Identifiable {
    public let id: String
    public let title: String
    public let detail: String

    public init(id: String, title: String, detail: String) {
        self.id = id
        self.title = title
        self.detail = detail
    }
}

public struct BatchCombatRollEvaluation: Sendable, Equatable {
    public let totalDamage: Int
    public let summarySteps: [BatchCombatSummaryStep]

    public init(totalDamage: Int, summarySteps: [BatchCombatSummaryStep]) {
        self.totalDamage = totalDamage
        self.summarySteps = summarySteps
    }

    public var outcomeHeadline: String {
        if totalDamage > 0 {
            return String(localized: "\(totalDamage) damage to allocate")
        }
        return String(localized: "No damage to allocate")
    }
}

/// Resolves physical-dice combat batches: hits → wounds → failed saves → damage.
public enum BatchCombatRollEngine: Sendable {
    public static func evaluate(_ input: BatchCombatRollInput) -> BatchCombatRollEvaluation {
        var steps: [BatchCombatSummaryStep] = []

        let hits = max(0, input.successfulHits)
        steps.append(
            BatchCombatSummaryStep(
                id: "hits",
                title: String(localized: "Hits"),
                detail: String(localized: "\(hits) successful hit\(hits == 1 ? "" : "s")")
            )
        )

        let wounds = min(max(0, input.successfulWounds), hits)
        if hits > 0 {
            steps.append(
                BatchCombatSummaryStep(
                    id: "wounds",
                    title: String(localized: "Wounds"),
                    detail: String(localized: "\(wounds) wound\(wounds == 1 ? "" : "s") caused")
                )
            )
        }

        let savesFailed: Int
        if input.mortalDamage, wounds > 0 {
            savesFailed = wounds
            steps.append(
                BatchCombatSummaryStep(
                    id: "saves",
                    title: String(localized: "Save Roll"),
                    detail: String(localized: "Mortal damage — save rolls skipped.")
                )
            )
        } else if wounds > 0 {
            savesFailed = min(max(0, input.failedSaves), wounds)
            steps.append(
                BatchCombatSummaryStep(
                    id: "saves",
                    title: String(localized: "Failed Saves"),
                    detail: String(
                        localized: "\(savesFailed) of \(wounds) wound\(wounds == 1 ? "" : "s") failed their save"
                    )
                )
            )
        } else {
            savesFailed = 0
        }

        let wardNegated = min(max(0, input.wardNegatedCount), savesFailed)
        if wardNegated > 0 {
            steps.append(
                BatchCombatSummaryStep(
                    id: "ward",
                    title: String(localized: "Ward"),
                    detail: String(localized: "\(wardNegated) wound\(wardNegated == 1 ? "" : "s") ignored by ward")
                )
            )
        }

        let damageInstances = max(0, savesFailed - wardNegated)
        let perWound = max(1, input.damagePerWound)
        let computedDamage = damageInstances * perWound
        let total = max(0, input.manualTotalDamage ?? computedDamage)

        if let manual = input.manualTotalDamage {
            steps.append(
                BatchCombatSummaryStep(
                    id: "damage",
                    title: String(localized: "Damage"),
                    detail: String(localized: "\(manual) damage entered manually")
                )
            )
        } else if damageInstances > 0 {
            steps.append(
                BatchCombatSummaryStep(
                    id: "damage",
                    title: String(localized: "Damage"),
                    detail: String(
                        localized: "\(damageInstances) × \(perWound) = \(total) damage to allocate"
                    )
                )
            )
        } else {
            steps.append(
                BatchCombatSummaryStep(
                    id: "damage",
                    title: String(localized: "Damage"),
                    detail: String(localized: "No damage to allocate")
                )
            )
        }

        return BatchCombatRollEvaluation(totalDamage: total, summarySteps: steps)
    }

    public static func saveNeededOnDice(saveTarget: Int, rend: Int, saveModifier: Int) -> Int {
        CombatRollResolution.saveNeededOnDice(
            saveTarget: saveTarget,
            rend: rend,
            saveModifier: saveModifier
        )
    }
}
