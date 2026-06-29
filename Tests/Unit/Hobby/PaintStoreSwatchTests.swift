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
