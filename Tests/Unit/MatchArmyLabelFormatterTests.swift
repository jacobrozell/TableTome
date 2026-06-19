import XCTest
@testable import TabletomeDomain

final class MatchArmyLabelFormatterTests: XCTestCase {
    private let catalog = SpearheadCatalog(
        schemaVersion: 1,
        factions: [
            SpearheadFaction(
                id: "stormcast",
                name: "Stormcast Eternals",
                alliance: .order,
                armies: [
                    SpearheadArmy(
                        id: "vigilant-brotherhood",
                        name: "Vigilant Brotherhood",
                        general: "Knight-Arcanum",
                        tagline: "Hold the line",
                        playstyle: "Defensive",
                        unitCount: 3
                    )
                ]
            )
        ],
        matchSteps: []
    )

    func testLabelFormatsFactionAndArmy() {
        let selection = PlayerArmySelection(
            playerName: "Player 1",
            factionId: "stormcast",
            armyId: "vigilant-brotherhood"
        )

        XCTAssertEqual(
            MatchArmyLabelFormatter.label(for: selection, in: catalog),
            "Stormcast Eternals — Vigilant Brotherhood"
        )
    }

    func testLabelFallsBackWhenSelectionMissing() {
        let selection = PlayerArmySelection(playerName: "Player 1", factionId: "unknown", armyId: "missing")

        let label = MatchArmyLabelFormatter.label(for: selection, in: catalog)

        XCTAssertFalse(label.isEmpty)
        XCTAssertNotEqual(label, "Stormcast Eternals — Vigilant Brotherhood")
    }
}
