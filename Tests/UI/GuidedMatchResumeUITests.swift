import XCTest

/// Play tab → Return to battle lands on the embedded Spearhead battle surface.
@MainActor
final class GuidedMatchResumeUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        app = XCUIApplication()
    }

    func testContinueGuidedMatchOpensBattleTracker() {
        app.launchArguments = [
            "-skip_onboarding",
            "-reset_user_defaults",
            "-onboarding_choice",
            "aos-spearhead",
            "-open_guided_match",
            "-apply_starter_matchup",
            "-open_battle_tracker"
        ]
        app.launch()

        let battleMarker = app.descendants(matching: .any)["spearheadBattle.vpSummary"]
        XCTAssertTrue(battleMarker.waitForExistence(timeout: 30), "Battle tracker should open after setup automation")

        battleMarker.tap()
        let incrementVP = app.buttons["battleTracker.victoryPoints-Increment"].firstMatch
        XCTAssertTrue(incrementVP.waitForExistence(timeout: 8), "Victory points sheet should open from the header")
        incrementVP.tap()

        app.terminate()
        app.launchArguments = ["-skip_onboarding"]
        app.launch()

        let continueButton = app.buttons
            .matching(NSPredicate(format: "identifier == %@ AND label == %@", "home.continueCard", "Return to battle"))
            .firstMatch
        XCTAssertTrue(continueButton.waitForExistence(timeout: 12), "Play home should offer Return to battle")
        continueButton.tap()

        XCTAssertTrue(
            battleMarker.waitForExistence(timeout: 15),
            "Return to battle should land on the embedded battle tracker, not Setup or Armies"
        )
    }
}
