import Foundation

public enum DiceRollerEngine: Sendable {
  public static func rollD6<G: RandomNumberGenerator>(
    purpose: RollPurpose,
    generator: inout G
  ) -> DiceRollResult {
    let face = Int.random(in: 1...6, using: &generator)
    return DiceRollResult(
      dieType: .d6,
      purpose: purpose,
      faceValue: face,
      underlyingRolls: [face]
    )
  }

  public static func rollD6(purpose: RollPurpose) -> DiceRollResult {
    var generator = SystemRandomNumberGenerator()
    return rollD6(purpose: purpose, generator: &generator)
  }

  /// AoS D3: roll 1d6, divide by 2 rounding up.
  public static func rollD3<G: RandomNumberGenerator>(generator: inout G) -> DiceRollResult {
    let d6 = Int.random(in: 1...6, using: &generator)
    let d3 = (d6 + 1) / 2
    return DiceRollResult(
      dieType: .d6,
      purpose: .variableDamage(.d3),
      faceValue: d3,
      underlyingRolls: [d6]
    )
  }

  public static func rollVariableDamage<G: RandomNumberGenerator>(
    _ kind: WeaponVariableDamage,
    generator: inout G
  ) -> DiceRollResult {
    switch kind {
    case .d3:
      return rollD3(generator: &generator)
    case .d6:
      let face = Int.random(in: 1...6, using: &generator)
      return DiceRollResult(
        dieType: .d6,
        purpose: .variableDamage(.d6),
        faceValue: face,
        underlyingRolls: [face]
      )
    case .twoD6:
      let first = Int.random(in: 1...6, using: &generator)
      let second = Int.random(in: 1...6, using: &generator)
      return DiceRollResult(
        dieType: .d6,
        purpose: .variableDamage(.twoD6),
        faceValue: first + second,
        underlyingRolls: [first, second]
      )
    }
  }
}
