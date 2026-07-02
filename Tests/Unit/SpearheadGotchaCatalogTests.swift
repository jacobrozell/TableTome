import XCTest
@testable import TabletomeDomain

final class SpearheadGotchaCatalogTests: XCTestCase {
    func testGnawfeastIncludesLurkingVermintideGotcha() {
        let gotchas = SpearheadGotchaCatalog.gotchas(for: "gnawfeast-clawpack")
        XCTAssertTrue(gotchas.contains { $0.id == "lurking-vermintide" })
    }

    func testStormcastOmitsLurkingVermintideGotcha() {
        let gotchas = SpearheadGotchaCatalog.gotchas(for: "vigilant-brotherhood")
        XCTAssertFalse(gotchas.contains { $0.id == "lurking-vermintide" })
    }

    func testFeaturedArmiesHaveGotchas() {
        XCTAssertFalse(SpearheadGotchaCatalog.gotchas(for: "vigilant-brotherhood").isEmpty)
        XCTAssertFalse(SpearheadGotchaCatalog.gotchas(for: "gnawfeast-clawpack").isEmpty)
        XCTAssertTrue(SpearheadGotchaCatalog.gotchas(for: "unknown").isEmpty)
    }

    func testVigilantBrotherhoodIncludesJudgementBladeGotcha() {
        let gotchas = SpearheadGotchaCatalog.gotchas(for: "vigilant-brotherhood")
        XCTAssertTrue(gotchas.contains { $0.id == "judgement-blade-anti" })
    }

    func testGnawfeastIncludesEnemyAntiWizardGotcha() {
        let gotchas = SpearheadGotchaCatalog.gotchas(for: "gnawfeast-clawpack")
        XCTAssertTrue(gotchas.contains { $0.id == "enemy-anti-wizard" })
    }
}
