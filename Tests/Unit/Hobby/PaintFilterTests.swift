import XCTest
@testable import Tabletome
@testable import TabletomeHobbyData

@MainActor
final class PaintFilterTests: XCTestCase {
    func testFilterCombinesTypeBrandLowAndSearch() {
        let paints = [
            HobbyPaint(
                name: "Kantor Blue", type: "Base", qty: 1,
                brand: "Citadel", source: "Stormcast Spearhead", notes: "armor", low: true
            ),
            HobbyPaint(
                name: "Nuln Oil", type: "Shade", qty: 1,
                brand: "Citadel", source: "Paint set", notes: "recess wash", low: true
            ),
            HobbyPaint(
                name: "Gravelord Grey", type: "Speedpaint", qty: 1,
                brand: "Army Painter", source: "Speedpaint starter", notes: "cloth", low: false
            ),
        ]
        let cfg = AppConfiguration()
        cfg.paintTypeFilter = "Base"
        cfg.paintBrandFilter = "Citadel"
        cfg.paintLowOnly = true

        let filtered = PaintFilter.filter(paints, cfg: cfg, search: "spearhead")

        XCTAssertEqual(filtered.map(\.name), ["Kantor Blue"])
    }

    func testSearchMatchesNameTypeBrandSourceAndNotesCaseInsensitively() {
        let paint = HobbyPaint(
            name: "Kantor Blue", type: "Base", qty: 1,
            brand: "Citadel", source: "Stormcast Spearhead", notes: "Armor panels"
        )
        let cfg = AppConfiguration()

        XCTAssertEqual(PaintFilter.filter([paint], cfg: cfg, search: "kantor").count, 1)
        XCTAssertEqual(PaintFilter.filter([paint], cfg: cfg, search: "BASE").count, 1)
        XCTAssertEqual(PaintFilter.filter([paint], cfg: cfg, search: "citadel").count, 1)
        XCTAssertEqual(PaintFilter.filter([paint], cfg: cfg, search: "spearhead").count, 1)
        XCTAssertEqual(PaintFilter.filter([paint], cfg: cfg, search: "armor").count, 1)
        XCTAssertTrue(PaintFilter.filter([paint], cfg: cfg, search: "shade").isEmpty)
    }

    func testActiveStateCountsSavedFiltersOnly() {
        let cfg = AppConfiguration()
        XCTAssertFalse(PaintFilter.isActive(cfg, search: ""))
        XCTAssertTrue(PaintFilter.isActive(cfg, search: "blue"))
        XCTAssertEqual(PaintFilter.activeFilterCount(cfg), 0)

        cfg.paintTypeFilter = "Base"
        cfg.paintBrandFilter = "Citadel"
        cfg.paintLowOnly = true

        XCTAssertTrue(PaintFilter.isActive(cfg, search: ""))
        XCTAssertEqual(PaintFilter.activeFilterCount(cfg), 3)
    }

    func testClearFiltersResetsSavedPaintFilters() {
        let cfg = AppConfiguration()
        cfg.paintTypeFilter = "Shade"
        cfg.paintBrandFilter = "Citadel"
        cfg.paintLowOnly = true

        PaintFilter.clearFilters(cfg)

        XCTAssertEqual(cfg.paintTypeFilter, "All")
        XCTAssertEqual(cfg.paintBrandFilter, "All")
        XCTAssertFalse(cfg.paintLowOnly)
    }
}
