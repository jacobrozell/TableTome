import XCTest
@testable import TabletomeDomain

final class ArmyHealthSummaryTests: XCTestCase {
    private let liberators = SpearheadUnit(
        id: "liberators",
        name: "Liberators",
        health: 2,
        modelCount: 5
    )
    private let lord = SpearheadUnit(
        id: "lord-vigilant",
        name: "Lord-Vigilant",
        health: 6
    )

    func testSummaryAggregatesWoundsAndAliveUnits() {
        let army = SpearheadArmy(
            id: "vigilant-brotherhood",
            name: "Vigilant Brotherhood",
            general: "Test",
            tagline: "Test",
            playstyle: "Test",
            unitCount: 2,
            units: [liberators, lord]
        )
        let wounds: [String: Int] = [
            UnitWoundTracker.unitKey(armyId: army.id, unitId: liberators.id): 0,
            UnitWoundTracker.unitKey(armyId: army.id, unitId: lord.id): 4
        ]

        let summary = ArmyHealthCatalog.summary(
            army: army,
            playerName: "Alex",
            woundsRemaining: wounds
        )

        XCTAssertEqual(summary?.aliveUnitCount, 1)
        XCTAssertEqual(summary?.trackableUnitCount, 2)
        XCTAssertEqual(summary?.totalWoundsRemaining, 4)
        XCTAssertEqual(summary?.totalWoundCapacity, 16)
        XCTAssertEqual(summary?.units.first?.isDestroyed, false)
    }

    func testSummaryDefaultsToFullHealthWhenMissingKeys() {
        let army = SpearheadArmy(
            id: "vigilant-brotherhood",
            name: "Vigilant Brotherhood",
            general: "Test",
            tagline: "Test",
            playstyle: "Test",
            unitCount: 1,
            units: [liberators]
        )

        let summary = ArmyHealthCatalog.summary(
            army: army,
            playerName: "Alex",
            woundsRemaining: [:]
        )

        XCTAssertEqual(summary?.units.first?.woundsRemaining, 10)
        XCTAssertEqual(summary?.units.first?.woundCapacity, 10)
    }

    func testSummaryReturnsNilWithoutTrackableUnits() {
        let army = SpearheadArmy(
            id: "empty",
            name: "Empty",
            general: "Test",
            tagline: "Test",
            playstyle: "Test",
            unitCount: 1,
            units: [SpearheadUnit(id: "banner", name: "Banner", health: nil)]
        )

        XCTAssertNil(
            ArmyHealthCatalog.summary(army: army, playerName: "Alex", woundsRemaining: [:])
        )
    }

    func testVisibleUnitsCanHideDestroyed() {
        let army = SpearheadArmy(
            id: "vigilant-brotherhood",
            name: "Vigilant Brotherhood",
            general: "Test",
            tagline: "Test",
            playstyle: "Test",
            unitCount: 2,
            units: [liberators, lord]
        )
        let wounds: [String: Int] = [
            UnitWoundTracker.unitKey(armyId: army.id, unitId: liberators.id): 0,
            UnitWoundTracker.unitKey(armyId: army.id, unitId: lord.id): 4
        ]
        guard let summary = ArmyHealthCatalog.summary(
            army: army,
            playerName: "Alex",
            woundsRemaining: wounds
        ) else {
            return XCTFail("Expected army summary")
        }

        XCTAssertEqual(summary.visibleUnits(hidingDestroyed: true).count, 1)
        XCTAssertEqual(summary.fractionRemaining, 0.25, accuracy: 0.001)
    }

    func testSummaryExcludesReinforcementUnitsNotOnTable() {
        let reserve = SpearheadUnit(
            id: "liberators",
            name: "Liberators",
            health: 2,
            keywords: ["Reinforcements"],
            modelCount: 5
        )
        let deployed = SpearheadUnit(
            id: "lord-vigilant",
            name: "Lord-Vigilant",
            health: 6
        )
        let army = SpearheadArmy(
            id: "vigilant-brotherhood",
            name: "Vigilant Brotherhood",
            general: "Test",
            tagline: "Test",
            playstyle: "Test",
            unitCount: 2,
            units: [reserve, deployed]
        )

        let hidden = ArmyHealthCatalog.summary(
            army: army,
            playerName: "Alex",
            woundsRemaining: [:],
            calledReinforcementUnitKeys: []
        )
        let visible = ArmyHealthCatalog.summary(
            army: army,
            playerName: "Alex",
            woundsRemaining: [:],
            calledReinforcementUnitKeys: [
                UnitWoundTracker.unitKey(armyId: army.id, unitId: reserve.id)
            ]
        )

        XCTAssertEqual(hidden?.trackableUnitCount, 1)
        XCTAssertEqual(hidden?.units.first?.unitId, deployed.id)
        XCTAssertEqual(visible?.trackableUnitCount, 2)
    }

    func testSummaryIncludesMoveLabelWhenPresent() {
        let unit = SpearheadUnit(
            id: "liberators",
            name: "Liberators",
            move: "5",
            health: 2,
            modelCount: 5
        )
        let army = SpearheadArmy(
            id: "vigilant-brotherhood",
            name: "Vigilant Brotherhood",
            general: "Test",
            tagline: "Test",
            playstyle: "Test",
            unitCount: 1,
            units: [unit]
        )

        let summary = ArmyHealthCatalog.summary(
            army: army,
            playerName: "Alex",
            woundsRemaining: [:]
        )

        XCTAssertEqual(summary?.units.first?.moveLabel, "5")
    }
}
