import XCTest
import TabletomeDomain
@testable import Tabletome

final class BattleActionCopyTests: XCTestCase {
    func testDeploymentNextAndBeginRound() {
        let next = BattleActionCopy.presentation(
            step: step(.deployment(.chooseRealmSide), title: "t", action: "a"),
            activePlayerIsOne: true,
            activePlayerName: "Azure",
            otherPlayerName: "Gold",
            nextPhase: .hero
        )
        XCTAssertEqual(next.title, "Next")

        let begin = BattleActionCopy.presentation(
            step: step(.deployment(.deploymentAbilities), title: "t", action: "a"),
            activePlayerIsOne: true,
            activePlayerName: "Azure",
            otherPlayerName: "Gold",
            nextPhase: .hero
        )
        XCTAssertEqual(begin.title, "Begin Round 1")
        XCTAssertEqual(begin.systemImage, "flag.checkered")
    }

    func testEndOfTurnPassesToTheOtherPlayer() {
        let pass = BattleActionCopy.presentation(
            step: step(.turnPhase(.endOfTurn), title: "t", action: "a"),
            activePlayerIsOne: true,
            activePlayerName: "Azure",
            otherPlayerName: "Gold",
            nextPhase: nil
        )
        XCTAssertEqual(pass.title, "Pass to Gold")
        XCTAssertTrue(pass.usesPlayerStyle)
        XCTAssertFalse(pass.playerIsOne)

        let finish = BattleActionCopy.presentation(
            step: step(.turnPhase(.endOfTurn), title: "t", action: "a"),
            activePlayerIsOne: false,
            activePlayerName: "Gold",
            otherPlayerName: "Azure",
            nextPhase: nil,
            handsOff: false
        )
        XCTAssertEqual(finish.title, "End Turn")
        XCTAssertFalse(finish.usesPlayerStyle)
    }

    func testBattleCompleteUsesResultsIdentifier() {
        let done = BattleActionCopy.presentation(
            step: step(.battleComplete, title: "t", action: "a"),
            activePlayerIsOne: false,
            activePlayerName: "Gold",
            otherPlayerName: "Azure",
            nextPhase: nil
        )
        XCTAssertEqual(done.title, "See Results")
        XCTAssertTrue(done.usesCompleteIdentifier)
    }

    func testStartShootingAndEndTurnLabels() {
        let shoot = BattleActionCopy.presentation(
            step: step(.turnPhase(.movement), title: "t", action: "a"),
            activePlayerIsOne: true,
            activePlayerName: "Azure",
            otherPlayerName: "Gold",
            nextPhase: .shooting
        )
        XCTAssertEqual(shoot.title, "Start Shoot Phase")

        let end = BattleActionCopy.presentation(
            step: step(.turnPhase(.combat), title: "t", action: "a"),
            activePlayerIsOne: true,
            activePlayerName: "Azure",
            otherPlayerName: "Gold",
            nextPhase: .endOfTurn
        )
        XCTAssertEqual(end.title, "End Turn")
    }

    private func step(
        _ kind: BattleFlowGuideStep.Kind,
        title: String,
        action: String
    ) -> BattleFlowGuideStep {
        BattleFlowGuideStep(kind: kind, title: title, instruction: "i", actionLabel: action)
    }
}
