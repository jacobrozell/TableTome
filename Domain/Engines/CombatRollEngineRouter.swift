import Foundation

public enum CombatRollRulesEdition: Sendable {
    case aos
    case wh40k10e
    case wh40k11e
}

public enum CombatRollEngineRouter: Sendable {
    public static func rulesEdition(for gameSystemId: GameSystemId) -> CombatRollRulesEdition {
        rulesEdition(for: gameSystemId.rawValue)
    }

    public static func rulesEdition(for gameSystemId: String) -> CombatRollRulesEdition {
        let capabilities = GameSystemPlayContext.context(for: gameSystemId).capabilities
        if capabilities.usesWh40k11eCombatRollEngine {
            return .wh40k11e
        }
        if capabilities.usesWh40k10eCombatRollEngine {
            return .wh40k10e
        }
        return .aos
    }

    public static func usesWh40kRules(gameSystemId: GameSystemId) -> Bool {
        usesWh40kRules(gameSystemId: gameSystemId.rawValue)
    }

    /// True for 10e Combat Patrol and 11e — both use AP-based saves, not AoS rend/ward.
    public static func usesWh40kRules(gameSystemId: String) -> Bool {
        rulesEdition(for: gameSystemId) != .aos
    }

    public static func evaluate(_ input: AttackRollInput, gameSystemId: String) -> AttackRollEvaluation {
        switch rulesEdition(for: gameSystemId) {
        case .aos:
            return CombatRollEngine.evaluate(input)
        case .wh40k10e:
            return Wh40k10eCombatRollEngine.evaluate(input)
        case .wh40k11e:
            return Wh40k11eCombatRollEngine.evaluate(input)
        }
    }

    public static func saveNeededOnDice(
        saveTarget: Int,
        rend: Int,
        saveModifier: Int,
        gameSystemId: String
    ) -> Int {
        switch rulesEdition(for: gameSystemId) {
        case .aos:
            return BatchCombatRollEngine.saveNeededOnDice(
                saveTarget: saveTarget,
                rend: rend,
                saveModifier: saveModifier
            )
        case .wh40k10e:
            return Wh40k10eCombatRollResolution.saveNeededOnDice(
                saveTarget: saveTarget,
                ap: rend,
                saveModifier: saveModifier
            )
        case .wh40k11e:
            return Wh40k11eCombatRollResolution.saveNeededOnDice(
                saveTarget: saveTarget,
                ap: rend,
                saveModifier: saveModifier
            )
        }
    }
}
