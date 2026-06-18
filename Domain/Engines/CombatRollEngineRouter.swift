import Foundation

public enum CombatRollEngineRouter: Sendable {
    public static func usesWh40kRules(gameSystemId: GameSystemId) -> Bool {
        usesWh40kRules(gameSystemId: gameSystemId.rawValue)
    }

    public static func usesWh40kRules(gameSystemId: String) -> Bool {
        GameSystemPlayContext.context(for: gameSystemId).capabilities.usesWh40kCombatRollEngine
    }

    public static func evaluate(_ input: AttackRollInput, gameSystemId: String) -> AttackRollEvaluation {
        if usesWh40kRules(gameSystemId: gameSystemId) {
            return Wh40k10eCombatRollEngine.evaluate(input)
        }
        return CombatRollEngine.evaluate(input)
    }

    public static func saveNeededOnDice(
        saveTarget: Int,
        rend: Int,
        saveModifier: Int,
        gameSystemId: String
    ) -> Int {
        if usesWh40kRules(gameSystemId: gameSystemId) {
            return Wh40k10eCombatRollResolution.saveNeededOnDice(
                saveTarget: saveTarget,
                ap: rend,
                saveModifier: saveModifier
            )
        }
        return BatchCombatRollEngine.saveNeededOnDice(
            saveTarget: saveTarget,
            rend: rend,
            saveModifier: saveModifier
        )
    }
}
