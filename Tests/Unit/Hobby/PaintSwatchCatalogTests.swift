import XCTest
@testable import TabletomeDomain

final class PaintSwatchCatalogTests: XCTestCase {
    func testBundledPaintCatalogLoadsSubstantialSet() {
        XCTAssertGreaterThanOrEqual(PaintSwatchCatalog.count, 200)
        XCTAssertEqual(PaintSwatchCatalog.allEntries.filter { $0.type == "Basing" }.count, 0)
    }

    func testLookupKnownCitadelPaintByName() {
        XCTAssertEqual(PaintSwatchCatalog.lookup(name: "Macragge Blue"), "#1c4fa0")
        XCTAssertEqual(PaintSwatchCatalog.lookup(name: "macragge blue"), "#1c4fa0")
    }

    func testLookupPrefersBrandWhenProvided() {
        XCTAssertEqual(
            PaintSwatchCatalog.lookup(name: "Kantor Blue", brand: "Citadel"),
            "#002158"
        )
    }

    func testLookupArmyPainterSpeedpaint() {
        XCTAssertEqual(
            PaintSwatchCatalog.lookup(name: "Gravelord Grey", brand: "Army Painter"),
            "#808080"
        )
        let entry = PaintSwatchCatalog.lookupEntry(name: "Slaughter Red", brand: "Army Painter")
        XCTAssertEqual(entry?.type, "Speedpaint")
    }

    func testLookupReturnsNilForUnknownPaint() {
        XCTAssertNil(PaintSwatchCatalog.lookup(name: "Mystery Purple"))
    }

    func testSearchRequiresMinimumQueryLength() {
        XCTAssertTrue(PaintSwatchCatalog.search("M").isEmpty)
    }

    func testSearchFindsPrefixMatches() {
        let results = PaintSwatchCatalog.search("Macr", limit: 5)
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.contains { $0.name == "Macragge Blue" })
    }

    func testSearchFindsArmyPainterSpeedpaint() {
        let results = PaintSwatchCatalog.search("Gravelord", limit: 5)
        XCTAssertTrue(results.contains { $0.name == "Gravelord Grey" && $0.brand == "Army Painter" })
    }
}

final class BasingMaterialCatalogTests: XCTestCase {
    func testBundledBasingCatalogLoads() {
        XCTAssertGreaterThanOrEqual(BasingMaterialCatalog.count, 70)
    }

    func testLookupArmyPainterStaticGrass() {
        let entry = BasingMaterialCatalog.lookupEntry(name: "Battlefield Grass Green", brand: "Army Painter")
        XCTAssertEqual(entry?.type, "Basing")
        XCTAssertEqual(entry?.category, "Static Grass")
        XCTAssertEqual(entry?.hex, "#4a7040")
    }

    func testLookupCitadelTexturePaste() {
        let entry = BasingMaterialCatalog.lookupEntry(name: "Stirland Mud", brand: "Citadel")
        XCTAssertEqual(entry?.category, "Texture Paste")
    }

    func testLookupWoodlandScenicsGrass() {
        let entry = BasingMaterialCatalog.lookupEntry(name: "Fine Turf Green Grass", brand: "Woodland Scenics")
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.category, "Static Grass")
    }

    func testSearchFindsTufts() {
        let results = BasingMaterialCatalog.search("Undergrowth", limit: 5)
        XCTAssertTrue(results.contains { $0.name == "Summer Undergrowth" })
    }
}

final class PaintInventoryCatalogTests: XCTestCase {
    func testUnifiedLookupChecksBothCatalogs() {
        XCTAssertNotNil(PaintInventoryCatalog.lookupEntry(name: "Macragge Blue"))
        XCTAssertNotNil(PaintInventoryCatalog.lookupEntry(name: "Battlefield Snow", brand: "Army Painter"))
        XCTAssertNotNil(PaintInventoryCatalog.lookupEntry(name: "Vallejo Model Color White", brand: "Vallejo"))
        XCTAssertNotNil(PaintInventoryCatalog.lookupEntry(name: "Chaos Black Spray", brand: "Citadel"))
    }

    func testBasingPreferredSearch() {
        let results = PaintInventoryCatalog.search("Battlefield", preferredType: "Basing", limit: 8)
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.type == "Basing" })
    }
}
