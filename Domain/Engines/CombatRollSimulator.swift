import Foundation

/// Rolls dice and evaluates combat using one code path so simulated results always match the engine.
public enum CombatRollSimulator: Sendable {
    public struct Result: Sendable, Equatable {
        public let rolls: SimulatedAttackRolls
        public let evaluation: AttackRollEvaluation

        public init(rolls: SimulatedAttackRolls, evaluation: AttackRollEvaluation) {
            self.rolls = rolls
            self.evaluation = evaluation
        }
    }

    public static func rollAndEvaluate(parameters: AttackRollParameters) -> Result {
        rollAndEvaluate(parameters: parameters, gameSystemId: "aos-spearhead")
    }

    public static func rollAndEvaluate(
        parameters: AttackRollParameters,
        gameSystemId: String
    ) -> Result {
        let rolls = AttackRollSequenceRoller.roll(parameters: parameters)
        return evaluate(rolls: rolls, parameters: parameters, gameSystemId: gameSystemId)
    }

    public static func rollAndEvaluate<G: RandomNumberGenerator>(
        parameters: AttackRollParameters,
        generator: inout G
    ) -> Result {
        let rolls = AttackRollSequenceRoller.roll(parameters: parameters, generator: &generator)
        return evaluate(rolls: rolls, parameters: parameters)
    }

    internal static func rollAndEvaluate(
        parameters: AttackRollParameters,
        d6Faces: [Int],
        variableDamageFaces: [Int] = []
    ) -> Result {
        let rolls = AttackRollSequenceRoller.roll(
            parameters: parameters,
            d6Faces: d6Faces,
            variableDamageFaces: variableDamageFaces
        )
        return evaluate(rolls: rolls, parameters: parameters)
    }

    public static func evaluate(rolls: SimulatedAttackRolls, parameters: AttackRollParameters) -> Result {
        evaluate(rolls: rolls, parameters: parameters, gameSystemId: "aos-spearhead")
    }

    public static func evaluate(
        rolls: SimulatedAttackRolls,
        parameters: AttackRollParameters,
        gameSystemId: String
    ) -> Result {
        let input = CombatRollResolution.input(
            from: parameters,
            hitRoll: rolls.hitRoll,
            woundRoll: rolls.woundRoll,
            saveRoll: rolls.saveRoll,
            wardRoll: rolls.wardRoll,
            damage: rolls.damage
        )
        let evaluation = CombatRollEngineRouter.evaluate(input, gameSystemId: gameSystemId)
        return Result(rolls: rolls, evaluation: evaluation)
    }
}
