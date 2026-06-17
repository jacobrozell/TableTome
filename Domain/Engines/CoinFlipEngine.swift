import Foundation

public enum CoinFlipEngine {
    public static func flip<G: RandomNumberGenerator>(
        for battlefield: SpearheadBattlefield,
        generator: inout G
    ) -> BattlefieldSide {
        let sides = BattlefieldSide.sides(for: battlefield)
        return Bool.random(using: &generator) ? sides[0] : sides[1]
    }

    public static func flip(for battlefield: SpearheadBattlefield) -> BattlefieldSide {
        var generator = SystemRandomNumberGenerator()
        return flip(for: battlefield, generator: &generator)
    }
}
