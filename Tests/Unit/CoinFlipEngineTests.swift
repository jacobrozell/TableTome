import XCTest
@testable import TabletomeDomain

final class CoinFlipEngineTests: XCTestCase {
    func testFlipReturnsValidSide() {
        var generator = LCG(seed: 42)
        for _ in 0..<100 {
            let side = CoinFlipEngine.flip(generator: &generator)
            XCTAssertTrue(RealmSide.allCases.contains(side))
        }
    }

    func testFlipIsDeterministicWithSeed() {
        var generatorA = LCG(seed: 123)
        var generatorB = LCG(seed: 123)
        XCTAssertEqual(
            CoinFlipEngine.flip(generator: &generatorA),
            CoinFlipEngine.flip(generator: &generatorB)
        )
    }

    func testFlipProducesBothSides() {
        var generator = LCG(seed: 7)
        let results = Set((0..<64).map { _ in CoinFlipEngine.flip(generator: &generator) })
        XCTAssertEqual(results, Set(RealmSide.allCases))
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
