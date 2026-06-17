import Foundation

public enum AttackRollSequenceRoller: Sendable {
  public static func roll<G: RandomNumberGenerator>(
    parameters: AttackRollParameters,
    generator: inout G
  ) -> SimulatedAttackRolls {
    var roller = GeneratorDiceRoller(generator: generator)
    return roll(parameters: parameters, roller: &roller)
  }

  public static func roll(parameters: AttackRollParameters) -> SimulatedAttackRolls {
    var generator = SystemRandomNumberGenerator()
    return roll(parameters: parameters, generator: &generator)
  }

  internal static func roll(
    parameters: AttackRollParameters,
    d6Faces: [Int],
    variableDamageFaces: [Int] = []
  ) -> SimulatedAttackRolls {
    var roller = QueueDiceRoller(d6Faces: d6Faces, variableDamageFaces: variableDamageFaces)
    return roll(parameters: parameters, roller: &roller)
  }

  private static func roll<R: DiceRollerProtocol>(
    parameters: AttackRollParameters,
    roller: inout R
  ) -> SimulatedAttackRolls {
    var state = RollState(parameters: parameters)
    state.record(roller.rollD6(purpose: .hit))
    guard state.hitSucceeded else { return state.result }

    if state.requiresWoundRoll {
      state.record(roller.rollD6(purpose: .wound))
      guard state.woundSucceeded else { return state.result }
    }

    if state.skipsSaveRoll {
      state.applyVariableDamage(using: &roller)
      return state.result
    }

    state.record(roller.rollD6(purpose: .save))
    guard !state.saveSucceeded else { return state.result }

    if parameters.wardTarget != nil {
      state.record(roller.rollD6(purpose: .ward))
      guard !state.wardSucceeded else { return state.result }
    }

    state.applyVariableDamage(using: &roller)
    return state.result
  }
}

private struct RollState {
  let parameters: AttackRollParameters
  var rolls: [DiceRollResult] = []
  var hitRoll = 1
  var woundRoll = 1
  var saveRoll = 1
  var wardRoll: Int?
  var damage: Int

  init(parameters: AttackRollParameters) {
    self.parameters = parameters
    damage = parameters.damage
  }

  mutating func record(_ roll: DiceRollResult) {
    rolls.append(roll)
    switch roll.purpose {
    case .hit: hitRoll = roll.faceValue
    case .wound: woundRoll = roll.faceValue
    case .save: saveRoll = roll.faceValue
    case .ward: wardRoll = roll.faceValue
    default: break
    }
  }

  var input: AttackRollInput {
    CombatRollResolution.input(
      from: parameters,
      hitRoll: hitRoll,
      woundRoll: woundRoll,
      saveRoll: saveRoll,
      wardRoll: wardRoll,
      damage: damage
    )
  }

  var hitSucceeded: Bool { CombatRollResolution.hitSucceeded(input) }
  var requiresWoundRoll: Bool { CombatRollResolution.requiresWoundRoll(input) }
  var woundSucceeded: Bool { CombatRollResolution.woundSucceeded(input) }
  var skipsSaveRoll: Bool { CombatRollResolution.skipsSaveRoll(input) }
  var saveSucceeded: Bool { CombatRollResolution.saveSucceeded(input) }
  var wardSucceeded: Bool { CombatRollResolution.wardSucceeded(input) }

  var result: SimulatedAttackRolls {
    SimulatedAttackRolls(
      rolls: rolls,
      hitRoll: hitRoll,
      woundRoll: woundRoll,
      saveRoll: saveRoll,
      wardRoll: wardRoll,
      damage: damage
    )
  }

  mutating func applyVariableDamage<R: DiceRollerProtocol>(using roller: inout R) {
    guard CombatRollResolution.damageWouldBeDealt(input),
          let variableDamage = parameters.variableDamage else { return }
    let damageRoll = roller.rollVariableDamage(variableDamage)
    rolls.append(damageRoll)
    damage = damageRoll.faceValue
  }
}

private protocol DiceRollerProtocol {
  mutating func rollD6(purpose: RollPurpose) -> DiceRollResult
  mutating func rollVariableDamage(_ kind: WeaponVariableDamage) -> DiceRollResult
}

private struct GeneratorDiceRoller<G: RandomNumberGenerator>: DiceRollerProtocol {
  var generator: G

  mutating func rollD6(purpose: RollPurpose) -> DiceRollResult {
    DiceRollerEngine.rollD6(purpose: purpose, generator: &generator)
  }

  mutating func rollVariableDamage(_ kind: WeaponVariableDamage) -> DiceRollResult {
    DiceRollerEngine.rollVariableDamage(kind, generator: &generator)
  }
}

internal struct QueueDiceRoller: DiceRollerProtocol {
  private var d6Faces: [Int]
  private var variableDamageFaces: [Int]

  init(d6Faces: [Int], variableDamageFaces: [Int] = []) {
    self.d6Faces = d6Faces
    self.variableDamageFaces = variableDamageFaces
  }

  mutating func rollD6(purpose: RollPurpose) -> DiceRollResult {
    let face = d6Faces.isEmpty ? 1 : d6Faces.removeFirst()
    return DiceRollResult(dieType: .d6, purpose: purpose, faceValue: face, underlyingRolls: [face])
  }

  mutating func rollVariableDamage(_ kind: WeaponVariableDamage) -> DiceRollResult {
    switch kind {
    case .d3:
      let d6 = d6Faces.isEmpty ? 1 : d6Faces.removeFirst()
      let d3 = (d6 + 1) / 2
      return DiceRollResult(
        dieType: .d6,
        purpose: .variableDamage(.d3),
        faceValue: d3,
        underlyingRolls: [d6]
      )
    case .d6:
      let face = variableDamageFaces.isEmpty
        ? (d6Faces.isEmpty ? 1 : d6Faces.removeFirst())
        : variableDamageFaces.removeFirst()
      return DiceRollResult(
        dieType: .d6,
        purpose: .variableDamage(.d6),
        faceValue: face,
        underlyingRolls: [face]
      )
    case .twoD6:
      let first = d6Faces.isEmpty ? 1 : d6Faces.removeFirst()
      let second = d6Faces.isEmpty ? 1 : d6Faces.removeFirst()
      return DiceRollResult(
        dieType: .d6,
        purpose: .variableDamage(.twoD6),
        faceValue: first + second,
        underlyingRolls: [first, second]
      )
    }
  }
}
