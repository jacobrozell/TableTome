import Foundation

public struct VariableAttackRollOutcome: Equatable, Sendable {
    public let perModelTotals: [Int]
    public let totalAttacks: Int
    public let breakdown: String

    public init(perModelTotals: [Int], totalAttacks: Int, breakdown: String) {
        self.perModelTotals = perModelTotals
        self.totalAttacks = totalAttacks
        self.breakdown = breakdown
    }
}

/// Rolls variable Attacks characteristics (D6, 2D6) per model.
public enum VariableAttackRollEngine: Sendable {
    public static func roll(
        expression: String,
        modelCount: Int,
        generator: inout some RandomNumberGenerator
    ) -> VariableAttackRollOutcome {
        let models = max(1, modelCount)
        let perModel = (0..<models).map { _ in rollOnce(expression: expression, generator: &generator) }
        let total = perModel.reduce(0, +)
        let breakdown = breakdownText(expression: expression, perModel: perModel, total: total)
        return VariableAttackRollOutcome(
            perModelTotals: perModel,
            totalAttacks: total,
            breakdown: breakdown
        )
    }

    public static func roll(expression: String, modelCount: Int) -> VariableAttackRollOutcome {
        var generator = SystemRandomNumberGenerator()
        return roll(expression: expression, modelCount: modelCount, generator: &generator)
    }

    private static func rollOnce(
        expression: String,
        generator: inout some RandomNumberGenerator
    ) -> Int {
        switch expression.uppercased() {
        case "D6":
            return DiceRollerEngine.rollD6(purpose: .hit, generator: &generator).faceValue
        case "2D6":
            return DiceRollerEngine.rollVariableDamage(.twoD6, generator: &generator).faceValue
        default:
            return 1
        }
    }

    private static func breakdownText(expression: String, perModel: [Int], total: Int) -> String {
        if perModel.count == 1 {
            return String(localized: "\(expression): \(perModel[0]) attacks")
        }
        let rolls = perModel.map(String.init).joined(separator: " + ")
        return String(localized: "\(expression) per model: \(rolls) = \(total) attacks")
    }
}
