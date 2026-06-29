import XCTest
import SwiftData
@testable import Tabletome
@testable import TabletomeHobbyData
@testable import TabletomeDomain

@MainActor
final class PaintStoreSwatchTests: XCTestCase {
    private var context: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        context = HobbyAppContainer.unitTestContext()
        HobbyAppContainer.resetUnitTestStore()
    }

    func testAddUsesCatalogColourForKnownPaint() throws {
        XCTAssertTrue(
            PaintStore.add(
                name: "Kantor Blue", type: "Base", brand: "Citadel",
                source: "", qty: 1, notes: "", low: false, in: context
            )
        )

        let paint = try XCTUnwrap((try? context.fetch(FetchDescriptor<HobbyPaint>()))?.first)
        XCTAssertEqual(paint.swatchHex, "#002158")
        XCTAssertFalse(paint.usesCustomSwatch)
    }

    func testAddPreservesCustomSwatch() throws {
        XCTAssertTrue(
            PaintStore.add(
                name: "Custom Mix", type: "Base", brand: "",
                source: "", qty: 1, notes: "", low: false,
                swatchHex: "#ff00ff", usesCustomSwatch: true, in: context
            )
        )

        let paint = try XCTUnwrap((try? context.fetch(FetchDescriptor<HobbyPaint>()))?.first)
        XCTAssertEqual(paint.swatchHex, "#ff00ff")
        XCTAssertTrue(paint.usesCustomSwatch)
    }

    func testAddRejectsBlankAndDuplicateNamesCaseInsensitively() throws {
        XCTAssertFalse(
            PaintStore.add(
                name: "   ", type: "Base", brand: "",
                source: "", qty: 1, notes: "", low: false, in: context
            )
        )
        XCTAssertTrue(
            PaintStore.add(
                name: "Kantor Blue", type: "Base", brand: "Citadel",
                source: "", qty: 1, notes: "", low: false, in: context
            )
        )
        XCTAssertFalse(
            PaintStore.add(
                name: "kantor blue", type: "Base", brand: "Citadel",
                source: "", qty: 1, notes: "", low: false, in: context
            )
        )

        let paints = try context.fetch(FetchDescriptor<HobbyPaint>())
        XCTAssertEqual(paints.count, 1)
    }

    func testAddTrimsNameAndClampsMinimumQuantity() throws {
        XCTAssertTrue(
            PaintStore.add(
                name: "  Reikland Fleshshade  ", type: "Shade", brand: "Citadel",
                source: "", qty: 0, notes: "", low: true, in: context
            )
        )

        let paint = try XCTUnwrap((try? context.fetch(FetchDescriptor<HobbyPaint>()))?.first)
        XCTAssertEqual(paint.name, "Reikland Fleshshade")
        XCTAssertEqual(paint.qty, 1)
        XCTAssertTrue(paint.low)
    }

    func testUpdateTypeKeepsCustomSwatch() throws {
        context.insert(
            HobbyPaint(
                name: "Custom Mix", type: "Base", swatchHex: "#ff00ff",
                usesCustomSwatch: true, qty: 1
            )
        )
        try context.save()
        let paint = try XCTUnwrap((try? context.fetch(FetchDescriptor<HobbyPaint>()))?.first)

        XCTAssertTrue(
            PaintStore.update(
                paint, name: "Custom Mix", type: "Shade", brand: "",
                source: "", qty: 1, notes: "", low: false, in: context
            )
        )

        XCTAssertEqual(paint.swatchHex, "#ff00ff")
        XCTAssertTrue(paint.usesCustomSwatch)
    }

    func testUpdateTypeRefreshesAutomaticSwatch() throws {
        context.insert(
            HobbyPaint(
                name: "Kantor Blue", type: "Base", swatchHex: "#7a7a7a",
                usesCustomSwatch: false, qty: 1, brand: "Citadel"
            )
        )
        try context.save()
        let paint = try XCTUnwrap((try? context.fetch(FetchDescriptor<HobbyPaint>()))?.first)

        XCTAssertTrue(
            PaintStore.update(
                paint, name: "Kantor Blue", type: "Base", brand: "Citadel",
                source: "", qty: 1, notes: "", low: false, in: context
            )
        )

        XCTAssertEqual(paint.swatchHex, "#002158")
    }

    func testUpdateRejectsDuplicateNameAndClampsMaximumQuantity() throws {
        context.insert(HobbyPaint(name: "Kantor Blue", type: "Base", qty: 1))
        context.insert(HobbyPaint(name: "Nuln Oil", type: "Shade", qty: 1))
        try context.save()
        let paints = try context.fetch(FetchDescriptor<HobbyPaint>())
        let kantor = try XCTUnwrap(paints.first { $0.name == "Kantor Blue" })
        let nulnOil = try XCTUnwrap(paints.first { $0.name == "Nuln Oil" })

        XCTAssertFalse(
            PaintStore.update(
                nulnOil, name: "kantor blue", type: "Shade", brand: "",
                source: "", qty: 10_000, notes: "", low: false, in: context
            )
        )
        XCTAssertTrue(
            PaintStore.update(
                nulnOil, name: "Nuln Oil", type: "Shade", brand: "",
                source: "", qty: 10_000, notes: "", low: false, in: context
            )
        )

        XCTAssertEqual(kantor.name, "Kantor Blue")
        XCTAssertEqual(nulnOil.qty, 9_999)
    }

    func testLinkedUnitCountMatchesSourceAcrossArmies() throws {
        let first = Army(name: "Stormcast", game: "AoS", faction: "Stormcast Eternals")
        first.units = [
            ArmyUnit(name: "Liberators (5)", source: "Spearhead Stormcast Box", state: "Primed"),
            ArmyUnit(name: "Prosecutors (3)", source: "Skaventide", state: "Primed"),
        ]
        let second = Army(name: "Skaven", game: "AoS", faction: "Skaven")
        second.units = [
            ArmyUnit(name: "Clanrats (20)", source: "Spearhead Skaven", state: "Unassembled")
        ]

        XCTAssertEqual(PaintStore.linkedUnitCount(source: "Spearhead Stormcast", armies: [first, second]), 1)
        XCTAssertEqual(PaintStore.linkedUnitCount(source: "Spearhead", armies: [first, second]), 2)
        XCTAssertEqual(PaintStore.linkedUnitCount(source: "", armies: [first, second]), 0)
    }

    func testRefreshCatalogColorsUpdatesStaleSwatches() throws {
        context.insert(
            HobbyPaint(
                name: "Kantor Blue", type: "Base", swatchHex: "#7a7a7a",
                usesCustomSwatch: false, qty: 1, brand: "Citadel"
            )
        )
        context.insert(
            HobbyPaint(
                name: "Custom Mix", type: "Base", swatchHex: "#ff00ff",
                usesCustomSwatch: true, qty: 1
            )
        )
        try context.save()

        let updated = PaintStore.refreshCatalogColors(in: context)
        XCTAssertEqual(updated, 1)

        let paints = try context.fetch(FetchDescriptor<HobbyPaint>())
        let kantor = try XCTUnwrap(paints.first { $0.name == "Kantor Blue" })
        let custom = try XCTUnwrap(paints.first { $0.name == "Custom Mix" })
        XCTAssertEqual(kantor.swatchHex, "#002158")
        XCTAssertEqual(custom.swatchHex, "#ff00ff")
    }
}
