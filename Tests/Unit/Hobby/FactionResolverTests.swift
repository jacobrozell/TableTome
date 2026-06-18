import XCTest
@testable import TabletomeDomain

final class FactionResolverTests: XCTestCase {
    func testCompositeKeyJoinsGameAndFaction() {
        XCTAssertEqual(FactionResolver.compositeKey(game: "40k", faction: "Space Marines"),
                       "40k:Space Marines")
    }

    func testCompositeKeyFallsBackToFactionWhenGameMissing() {
        XCTAssertEqual(FactionResolver.compositeKey(game: " ", faction: "Orks"), "Orks")
    }

    func testNormalizeUsesAliasMap() {
        XCTAssertEqual(FactionResolver.normalize("Sisters of Battle"), "Adepta Sororitas")
        XCTAssertEqual(FactionResolver.normalize("Heretic Astartes: Death Guard"), "Death Guard")
    }

    func testResolveReturnsCatalogEntryForKnownComposite() {
        let result = FactionResolver.resolve(faction: "Space Marines", game: "40k", overrides: [])
        XCTAssertEqual(result.crest, "SM")
        XCTAssertEqual(result.color, "#1c4fa0")
    }

    func testResolveUsesOverrideWhenProvided() {
        let override = FactionPresetOverride(key: "40k:Space Marines", crest: "XX", hex: "#abcdef")
        let result = FactionResolver.resolve(faction: "Space Marines", game: "40k", overrides: [override])
        XCTAssertEqual(result.crest, "XX")
        XCTAssertEqual(result.color, "#abcdef")
    }

    func testResolveFallsBackToTwoCharCrestForUnknownFaction() {
        let result = FactionResolver.resolve(faction: "Made Up Faction", game: "40k", overrides: [])
        XCTAssertEqual(result.crest, "MA")
        XCTAssertEqual(result.color, FactionResolver.fallbackColor)
        XCTAssertTrue(FactionResolver.isFallback(result.color))
    }
}
