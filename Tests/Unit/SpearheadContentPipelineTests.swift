import XCTest
@testable import TabletomeDomain

final class SpearheadArmyMergerTests: XCTestCase {
    func testDetailOverlayReplacesTrackerFields() {
        let base = SpearheadArmy(
            id: "test-army",
            name: "Test Army",
            general: "General",
            tagline: "Tagline",
            playstyle: "Playstyle",
            unitCount: 1,
            battleTraits: [
                ArmyRuleOption(id: "trait", name: "Trait", summary: "Summary only")
            ]
        )
        let detail = SpearheadArmyDetail(
            armyId: "test-army",
            battleTraits: [
                ArmyRuleOption(
                    id: "trait",
                    name: "Trait",
                    summary: "Summary",
                    declare: "Declare",
                    effect: "Effect",
                    phases: [.hero],
                    usageLimit: .eachTurn
                )
            ],
            units: [
                SpearheadUnit(id: "unit", name: "Unit", abilities: [])
            ]
        )

        let merged = SpearheadArmyMerger.merged(base: base, detail: detail)
        XCTAssertEqual(merged.units.count, 1)
        XCTAssertEqual(merged.battleTraits.first?.phases, [.hero])
        XCTAssertEqual(merged.contentCoverage, SpearheadContentCoverage.battleTracker)
    }

    func testMismatchedArmyIdIsIgnored() {
        let base = SpearheadArmy(
            id: "test-army",
            name: "Test Army",
            general: "General",
            tagline: "Tagline",
            playstyle: "Playstyle",
            unitCount: 1
        )
        let detail = SpearheadArmyDetail(armyId: "other-army", units: [SpearheadUnit(id: "u", name: "U")])
        let merged = SpearheadArmyMerger.merged(base: base, detail: detail)
        XCTAssertTrue(merged.units.isEmpty)
    }
}

final class SpearheadCatalogValidatorTests: XCTestCase {
    func testFlagsUnknownDetailArmy() {
        let catalog = SpearheadCatalog(schemaVersion: 1, factions: [], matchSteps: [])
        let issues = SpearheadCatalogValidator.validate(
            catalog: catalog,
            details: ["missing-army": SpearheadArmyDetail(armyId: "missing-army")]
        )
        XCTAssertTrue(issues.contains { $0.message.contains("unknown army") })
    }

    func testNamespacedAbilityIdsAreUnique() {
        let army = SpearheadArmy(
            id: "dup-army",
            name: "Dup",
            general: "G",
            tagline: "T",
            playstyle: "P",
            unitCount: 1,
            units: [
                SpearheadUnit(
                    id: "unit-a",
                    name: "A",
                    abilities: [
                        TriggeredAbility(
                            id: "same",
                            name: "One",
                            source: "A",
                            phases: [.hero],
                            usageLimit: .eachTurn,
                            effect: "E"
                        )
                    ]
                ),
                SpearheadUnit(
                    id: "unit-b",
                    name: "B",
                    abilities: [
                        TriggeredAbility(
                            id: "same",
                            name: "Two",
                            source: "B",
                            phases: [.hero],
                            usageLimit: .eachTurn,
                            effect: "E"
                        )
                    ]
                )
            ]
        )
        let catalog = SpearheadCatalog(
            schemaVersion: 1,
            factions: [SpearheadFaction(id: "f", name: "F", alliance: .order, armies: [army])],
            matchSteps: []
        )
        let issues = SpearheadCatalogValidator.validate(catalog: catalog)
        XCTAssertTrue(issues.isEmpty)
    }
}
