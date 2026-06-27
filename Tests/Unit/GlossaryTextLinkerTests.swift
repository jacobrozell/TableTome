import XCTest
@testable import TabletomeDomain

final class GlossaryTextLinkerTests: XCTestCase {
    func testLinksWarscrollAliasInSpearheadChecklistCopy() {
        let text = "A Spearhead starter box per player — miniatures, unit rules cards, and a personal battle tactic deck"
        let segments = GlossaryTextLinker.segments(
            in: text,
            gameSystemId: GameSystemId.aosSpearhead.rawValue
        )

        XCTAssertTrue(segments.contains { segment in
            if case .linked(let value, let entryId) = segment {
                return value.lowercased().contains("battle tactic") && entryId == "battle-tactic"
            }
            return false
        })
    }

    func testReturnsPlainTextWhenNoTermsMatch() {
        let text = "Bring snacks and a friend."
        let segments = GlossaryTextLinker.segments(
            in: text,
            gameSystemId: GameSystemId.aosSpearhead.rawValue
        )
        XCTAssertEqual(segments, [.plain(text)])
    }

    func testPrefersLongerNonOverlappingPhrase() {
        let text = "Draw a twist card from the twist deck at the start of the round."
        let segments = GlossaryTextLinker.segments(
            in: text,
            gameSystemId: GameSystemId.aosSpearhead.rawValue
        )

        let linkedTexts = segments.compactMap { segment -> String? in
            if case .linked(let value, _) = segment { return value.lowercased() }
            return nil
        }
        XCTAssertTrue(linkedTexts.contains(where: { $0.contains("twist") }))
    }
}
