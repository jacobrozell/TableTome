import XCTest
@testable import TabletomeDomain

final class DiceRollerEngineTests: XCTestCase {
  func testRollD6WithinBounds() {
    for _ in 0..<100 {
      let result = DiceRollerEngine.rollD6(purpose: .hit)
      XCTAssertTrue((1...6).contains(result.faceValue))
      XCTAssertEqual(result.underlyingRolls, [result.faceValue])
      XCTAssertEqual(result.dieType, .d6)
    }
  }

  func testD3MappingFromD6() {
    let mappings: [(Int, Int)] = [(1, 1), (2, 1), (3, 2), (4, 2), (5, 3), (6, 3)]
    for (d6, expectedD3) in mappings {
      var roller = QueueDiceRoller(d6Faces: [d6])
      let result = roller.rollVariableDamage(.d3)
      XCTAssertEqual(result.underlyingRolls, [d6])
      XCTAssertEqual(result.faceValue, expectedD3)
    }
  }

  func testTwoD6SumsUnderlyingRolls() {
    var roller = QueueDiceRoller(d6Faces: [2, 5])
    let result = roller.rollVariableDamage(.twoD6)
    XCTAssertEqual(result.underlyingRolls, [2, 5])
    XCTAssertEqual(result.faceValue, 7)
  }

  func testChiSquaredD6Distribution() {
    var counts = Array(repeating: 0, count: 6)
    for _ in 0..<12_000 {
      let face = DiceRollerEngine.rollD6(purpose: .hit).faceValue
      counts[face - 1] += 1
    }
    let expected = 12_000.0 / 6.0
    var chiSquared = 0.0
    for count in counts {
      let delta = Double(count) - expected
      chiSquared += (delta * delta) / expected
    }
    // df=5, α=0.01 critical value ≈ 15.09
    XCTAssertLessThan(chiSquared, 15.09, "D6 distribution skewed: χ²=\(chiSquared)")
  }
}

final class AttackRollSequenceRollerTests: XCTestCase {
  func testStopsAfterFailedHit() {
    let result = AttackRollSequenceRoller.roll(
      parameters: sampleParameters(),
      d6Faces: [1]
    )
    XCTAssertEqual(result.rolls.count, 1)
    XCTAssertEqual(result.hitRoll, 1)
  }

  func testRollsSaveWhenHitAndWoundSucceed() {
    let result = AttackRollSequenceRoller.roll(
      parameters: sampleParameters(),
      d6Faces: [4, 4, 2]
    )
    XCTAssertEqual(result.rolls.count, 3)
    XCTAssertEqual(result.saveRoll, 2)
  }

  func testSkipsWoundRollOnCritAutoWound() {
    var parameters = sampleParameters()
    parameters.critAutoWound = true
    let result = AttackRollSequenceRoller.roll(
      parameters: parameters,
      d6Faces: [6, 2]
    )
    XCTAssertEqual(result.rolls.map(\.purpose), [.hit, .save])
    XCTAssertEqual(result.woundRoll, 1)
  }

  func testRollsVariableDamageWhenAttackSucceeds() {
    var parameters = sampleParameters()
    parameters.variableDamage = .d6
    parameters.damage = 1
    let result = AttackRollSequenceRoller.roll(
      parameters: parameters,
      d6Faces: [4, 4, 2],
      variableDamageFaces: [5]
    )
    XCTAssertTrue(result.rolls.contains { $0.purpose == .variableDamage(.d6) })
    XCTAssertEqual(result.damage, 5)
  }

  func testRollsWardWhenSaveFails() {
    var parameters = sampleParameters()
    parameters.wardTarget = 4
    let result = AttackRollSequenceRoller.roll(
      parameters: parameters,
      d6Faces: [4, 4, 2, 3]
    )
    XCTAssertEqual(result.rolls.map(\.purpose), [.hit, .wound, .save, .ward])
    XCTAssertEqual(result.wardRoll, 3)
  }

  func testStopsAfterSuccessfulWard() {
    var parameters = sampleParameters()
    parameters.wardTarget = 4
    let result = AttackRollSequenceRoller.roll(
      parameters: parameters,
      d6Faces: [4, 4, 2, 5]
    )
    XCTAssertEqual(result.rolls.count, 4)
    XCTAssertEqual(result.damage, 1)
  }

  private func sampleParameters() -> AttackRollParameters {
    AttackRollParameters(
      hitTarget: 4,
      woundTarget: 4,
      saveTarget: 4,
      rend: 0,
      damage: 1
    )
  }
}
