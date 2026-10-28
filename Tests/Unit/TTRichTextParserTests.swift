import XCTest
@testable import Tabletome

final class TTRichTextParserTests: XCTestCase {
    func testTurnStructureRendersSevenNumberedPhases() {
        let blocks = TTRichTextParser.blocks(from: turnStructure)

        let numbered = blocks.compactMap { block -> [TTRichTextListItem]? in
            if case .numberedList(let items) = block { return items }
            return nil
        }.flatMap { $0 }

        XCTAssertEqual(
            numbered.map(\.number),
            ["1", "2", "3", "4", "5", "6", "7"]
        )
        XCTAssertEqual(numbered.map(\.text), [
            "Start of Turn",
            "Hero Phase",
            "Movement Phase",
            "Shooting Phase",
            "Charge Phase",
            "Combat Phase",
            "End of Turn"
        ])
        XCTAssertFalse(numbered.contains { $0.text.contains("1.") })
    }

    func testBulletLinesAndShortColonBlocks() {
        let blocks = TTRichTextParser.blocks(from: """
        At the end of your turn, score:
        • 1 VP if you hold any objective.
        • 1 VP if you hold two or more objectives.
        """)

        XCTAssertEqual(blocks.count, 2)
        guard case .subheading(let heading) = blocks[0] else {
            return XCTFail("Expected a subheading")
        }
        XCTAssertEqual(heading, "At the end of your turn, score:")
        guard case .bulletList(let items) = blocks[1] else {
            return XCTFail("Expected a bullet list")
        }
        XCTAssertEqual(items.count, 2)
        XCTAssertTrue(items[0].hasPrefix("1 VP"))
    }

    func testDashBulletsAndParagraphSplit() {
        let blocks = TTRichTextParser.blocks(from: "Bring both boxes.\n\n- Place the board.\n- Roll for first turn.")

        XCTAssertEqual(blocks.count, 2)
        guard case .paragraph(let paragraph) = blocks[0] else {
            return XCTFail("Expected a paragraph")
        }
        XCTAssertEqual(paragraph, "Bring both boxes.")
        guard case .bulletList(let items) = blocks[1] else {
            return XCTFail("Expected a bullet list")
        }
        XCTAssertEqual(items, ["Place the board.", "Roll for first turn."])
    }

    func testInlineBoldStaysInTheParagraphForTheView() {
        let blocks = TTRichTextParser.blocks(from: "Each unit uses **one** Core ability.")
        XCTAssertEqual(blocks, [.paragraph("Each unit uses **one** Core ability.")])
    }

    func testMixedLineFallsBackToParagraphSoTextIsKept() {
        let source = "Read this first.\n1. Then this, but the block is mixed."
        let blocks = TTRichTextParser.blocks(from: source)
        let words = words(in: blocks)
        XCTAssertEqual(words, words(in: source))
    }

    func testSpearheadSamplesDoNotDropWords() {
        for sample in [turnStructure, weaponAbilities, attackModifiers] {
            let blocks = TTRichTextParser.blocks(from: sample)
            XCTAssertEqual(words(in: blocks), words(in: sample))
        }
    }

    private func words(in blocks: [TTRichTextBlock]) -> [String] {
        words(in: blocks.map(plainText).joined(separator: "\n"))
    }

    private func plainText(_ block: TTRichTextBlock) -> String {
        switch block {
        case .paragraph(let text), .subheading(let text):
            text
        case .numberedList(let items):
            items.map { "\($0.number) \($0.text)" }.joined(separator: "\n")
        case .bulletList(let items):
            items.joined(separator: "\n")
        }
    }

    private func words(in text: String) -> [String] {
        text
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .map { $0.lowercased() }
    }

    private let turnStructure = """
    Each battle round has two player turns. On your turn you are the active player and run these phases in order:

    1. Start of Turn
    2. Hero Phase
    3. Movement Phase
    4. Shooting Phase
    5. Charge Phase
    6. Combat Phase
    7. End of Turn

    In each phase (except the special Combat Phase fight sequence), the active player uses all of their phase abilities in any order, \
    then the opponent uses Enemy/Any phase abilities. Each unit can use at most one Core ability per phase \
    (Normal Move, Run, Shoot, Charge, Fight, or Retreat).

    Spearhead battles last exactly four battle rounds. Score victory points at the end of your turn in the End of Turn phase.
    """

    private let weaponAbilities = """
    Common weapon abilities in Spearhead:

    • Crit (Auto-wound) — unmodified hit 6 auto-wounds; defender still saves.
    • Crit (Mortal) — unmodified hit 6 inflicts mortal damage equal to the weapon's Damage; attack sequence ends.
    """

    private let attackModifiers = """
    Hit and wound roll modifiers are capped at +1 and -1 after summing all bonuses and penalties.

    Save rolls: add save modifiers (capped at +1), subtract the weapon's Rend from the roll, then compare to the Save characteristic.
    """
}

final class RuleSectionSnippetTests: XCTestCase {
    func testFirstSentenceStaysWithinSeventyCharacters() {
        let sentence = RuleSectionSnippet.firstSentence(of: """
        Each battle round has two player turns. On your turn you are the active player.
        """)
        XCTAssertEqual(sentence, "Each battle round has two player turns.")
        XCTAssertLessThanOrEqual(sentence.count, 70)
    }

    func testLongSentenceClipsWithEllipsis() {
        let sentence = RuleSectionSnippet.firstSentence(
            of: "Hit and wound roll modifiers are capped at +1 and -1 after summing all bonuses and penalties from every source."
        )
        XCTAssertLessThanOrEqual(sentence.count, 70)
        XCTAssertTrue(sentence.hasSuffix("…"))
    }

    func testSearchWindowHighlightsRend() {
        let content = """
        Hit and wound roll modifiers are capped at +1 and -1 after summing all bonuses and penalties.

        Save rolls: add save modifiers (capped at +1), subtract the weapon's Rend from the roll, then compare to the Save characteristic.
        """
        let match = RuleSectionSnippet.match(in: content, query: "rend")
        XCTAssertNotNil(match)
        XCTAssertLessThanOrEqual(match?.text.count ?? 99, 70)
        XCTAssertEqual(match?.highlightedText?.lowercased(), "rend")
        XCTAssertTrue(match?.text.localizedCaseInsensitiveContains("rend") == true)
    }
}
