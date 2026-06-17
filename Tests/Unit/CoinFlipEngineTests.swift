import XCTest
@testable import TabletomeDomain

final class CoinFlipEngineTests: XCTestCase {
    func testFlipReturnsValidSideForFireAndJade() {
        var generator = LCG(seed: 42)
        for _ in 0..<100 {
            let side = CoinFlipEngine.flip(for: .fireAndJade, generator: &generator)
            XCTAssertTrue(BattlefieldSide.sides(for: .fireAndJade).contains(side))
        }
    }

    func testFlipReturnsValidSideForSandAndBone() {
        var generator = LCG(seed: 42)
        for _ in 0..<100 {
            let side = CoinFlipEngine.flip(for: .sandAndBone, generator: &generator)
            XCTAssertTrue(BattlefieldSide.sides(for: .sandAndBone).contains(side))
        }
    }

    func testFlipReturnsValidSideForCityOfAsh() {
        var generator = LCG(seed: 42)
        for _ in 0..<100 {
            let side = CoinFlipEngine.flip(for: .cityOfAsh, generator: &generator)
            XCTAssertTrue(BattlefieldSide.sides(for: .cityOfAsh).contains(side))
        }
    }

    func testFlipIsDeterministicWithSeed() {
        var generatorA = LCG(seed: 123)
        var generatorB = LCG(seed: 123)
        XCTAssertEqual(
            CoinFlipEngine.flip(for: .fireAndJade, generator: &generatorA),
            CoinFlipEngine.flip(for: .fireAndJade, generator: &generatorB)
        )
    }

    func testFlipProducesBothSidesForEachBattlefield() {
        for battlefield in SpearheadBattlefield.allCases {
            let seed: UInt64 = switch battlefield {
            case .fireAndJade: 7
            case .sandAndBone: 99
            case .cityOfAsh: 17
            }
            var generator = LCG(seed: seed)
            let results = Set((0..<64).map { _ in CoinFlipEngine.flip(for: battlefield, generator: &generator) })
            XCTAssertEqual(results, Set(BattlefieldSide.sides(for: battlefield)))
        }
    }
}

/// Simple deterministic generator for unit tests.
private struct LCG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}
