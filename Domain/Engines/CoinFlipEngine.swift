import Foundation

public enum CoinFlipEngine {
    public static func flip<G: RandomNumberGenerator>(generator: inout G) -> RealmSide {
        Bool.random(using: &generator) ? .aqshy : .ghyran
    }

    public static func flip() -> RealmSide {
        var generator = SystemRandomNumberGenerator()
        return flip(generator: &generator)
    }
}
