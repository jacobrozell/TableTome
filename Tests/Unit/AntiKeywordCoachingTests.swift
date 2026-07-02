import XCTest
@testable import TabletomeDomain

final class AntiKeywordCoachingTests: XCTestCase {
    private let judgementBlade = SpearheadWeapon(
        id: "judgement-blade",
        name: "Judgement Blade",
        attacks: "3",
        hit: 3,
        wound: 3,
        rend: 1,
        damage: "2",
        ability: "Anti-Wizard, Anti-Priest"
    )

    private let wizard = SpearheadUnit(
        id: "master-moulder",
        name: "Master Moulder",
        keywords: ["Wizard"]
    )

    private let priest = SpearheadUnit(
        id: "lord-veritant",
        name: "Lord-Veritant",
        keywords: ["Priest"]
    )

    private let clanrats = SpearheadUnit(
        id: "clanrats",
        name: "Clanrats",
        keywords: ["Infantry"]
    )

    func testCombinedAntiKeywordsMatchWizardOrPriest() {
        XCTAssertNotNil(AntiKeywordCoaching.coachingLine(weapon: judgementBlade, defender: wizard))
        XCTAssertNotNil(AntiKeywordCoaching.coachingLine(weapon: judgementBlade, defender: priest))
        let line = AntiKeywordCoaching.coachingLine(weapon: judgementBlade, defender: clanrats)
        XCTAssertTrue(line?.contains("cannot") == true)
    }

    func testGlossaryEntryIdsIncludeBothAntiKeywords() {
        let ids = AntiKeywordCoaching.glossaryEntryIds(for: judgementBlade)
        XCTAssertTrue(ids.contains("anti-wizard"))
        XCTAssertTrue(ids.contains("anti-priest"))
    }

    func testWeaponDetectsAntiKeywords() {
        XCTAssertTrue(judgementBlade.hasAntiWizard)
        XCTAssertTrue(judgementBlade.hasAntiPriest)
    }
}
