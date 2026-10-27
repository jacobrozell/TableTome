import XCTest
@testable import Tabletome
@testable import TabletomeDomain

@MainActor
final class SpearheadBattleViewModelWoundTrackingTests: XCTestCase {
    private func makeViewModel() -> SpearheadBattleViewModel {
        var match = GuidedMatchState()
        match.playerOne.armyId = "army-1"
        match.playerTwo.armyId = "army-2"
        let army = SpearheadArmy(
            id: "army-1",
            name: "Test Army",
            general: "General",
            tagline: "",
            playstyle: "",
            unitCount: 1,
            units: [
                SpearheadUnit(
                    id: "unit-1",
                    name: "Test Unit",
                    health: 3,
                    modelCount: 2
                )
            ]
        )
        let catalog = SpearheadCatalog(
            schemaVersion: 1,
            factions: [
                SpearheadFaction(
                    id: "faction",
                    name: "Faction",
                    alliance: .order,
                    armies: [army]
                )
            ],
            matchSteps: []
        )
        match.playerOne.factionId = "faction"
        match.playerOne.armyId = "army-1"
        return SpearheadBattleViewModel(
            gameSystemId: .aosSpearhead,
            matchState: match,
            catalog: catalog,
            initialState: BattleTrackerState()
        )
    }

    func testWoundCapacityUsesHealthOverride() {
        let viewModel = makeViewModel()
        guard let unit = viewModel.playerOneArmy?.units.first else {
            XCTFail("Missing test unit")
            return
        }
        let baseCapacity = viewModel.woundCapacity(for: "army-1", unit: unit)
        XCTAssertEqual(baseCapacity, 6)

        viewModel.setUnitHealthPerModelOverride(armyId: "army-1", unit: unit, healthPerModel: 2)
        XCTAssertEqual(viewModel.woundCapacity(for: "army-1", unit: unit), 4)
    }

    func testIsActivePlayerArmyReflectsTrackerState() {
        let viewModel = makeViewModel()
        XCTAssertTrue(viewModel.isActivePlayerArmy("army-1"))
        XCTAssertFalse(viewModel.isActivePlayerArmy("army-2"))
    }
}
