import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

final class PlayerProfileStoreTests: XCTestCase {
    private var tempDirectory: URL!
    private var repository: JSONPlayerProfileRepository!
    private var store: PlayerProfileStore!

    override func setUp() async throws {
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        repository = JSONPlayerProfileRepository(baseDirectory: tempDirectory)
        store = PlayerProfileStore(repository: repository)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDirectory)
    }

    func testFirstLaunchSeedsJacobAndChris() async throws {
        let household = try await store.loadHousehold()
        XCTAssertEqual(household.profiles.count, 2)
        XCTAssertEqual(household.sortedProfiles.map(\.displayName), ["Jacob", "Chris"])
        XCTAssertNotNil(household.defaultPlayerOneProfileId)
        XCTAssertEqual(household.primaryProfile?.displayName, "Jacob")
    }

    func testHouseholdPersistsAcrossLoads() async throws {
        let first = try await store.loadHousehold()
        let jacob = try XCTUnwrap(first.primaryProfile)
        _ = try await store.toggleOwnedArmy(profileId: jacob.id, armyId: "skaven-spearhead")

        let reloaded = try await store.loadHousehold()
        XCTAssertTrue(reloaded.profile(id: jacob.id)?.ownedSpearheadArmyIds.contains("skaven-spearhead") == true)
    }

    func testToggleOwnedArmyOnAndOff() async throws {
        let household = try await store.loadHousehold()
        let jacob = try XCTUnwrap(household.primaryProfile)

        let owned = try await store.toggleOwnedArmy(profileId: jacob.id, armyId: "skaven-spearhead")
        XCTAssertTrue(owned)
        let unowned = try await store.toggleOwnedArmy(profileId: jacob.id, armyId: "skaven-spearhead")
        XCTAssertFalse(unowned)

        let updated = try await store.loadHousehold()
        XCTAssertFalse(updated.profile(id: jacob.id)?.ownedSpearheadArmyIds.contains("skaven-spearhead") == true)
    }

    func testLinkStarterBoxAddsArmies() async throws {
        let household = try await store.loadHousehold()
        let jacob = try XCTUnwrap(household.primaryProfile)

        try await store.linkStarterBox(
            profileId: jacob.id,
            boxId: "skaventide",
            armyIds: ["gnawfeast-clawpack", "vigilant-brotherhood"]
        )

        let updated = try await store.loadHousehold()
        let profile = try XCTUnwrap(updated.profile(id: jacob.id))
        XCTAssertTrue(profile.linkedStarterBoxIds.contains("skaventide"))
        XCTAssertTrue(profile.ownedSpearheadArmyIds.contains("gnawfeast-clawpack"))
        XCTAssertTrue(profile.ownedSpearheadArmyIds.contains("vigilant-brotherhood"))
    }

    func testCreateProfileAppendsAndTrimsName() async throws {
        let created = try await store.createProfile(displayName: "  Taylor  ")
        XCTAssertEqual(created.displayName, "Taylor")

        let household = try await store.loadHousehold()
        XCTAssertEqual(household.profiles.count, 3)
        XCTAssertTrue(household.profiles.contains { $0.id == created.id })
    }

    func testCreateProfileRejectsEmptyName() async throws {
        do {
            _ = try await store.createProfile(displayName: "   ")
            XCTFail("Expected invalid display name")
        } catch PlayerProfileRepositoryError.invalidDisplayName {
            // expected
        }
    }

    func testUpdateProfilePersistsChanges() async throws {
        let household = try await store.loadHousehold()
        var jacob = try XCTUnwrap(household.primaryProfile)
        jacob.displayName = "Jake"
        jacob.accentColorName = "purple"
        try await store.updateProfile(jacob)

        let updated = try await store.loadHousehold()
        let profile = try XCTUnwrap(updated.profile(id: jacob.id))
        XCTAssertEqual(profile.displayName, "Jake")
        XCTAssertEqual(profile.accentColorName, "purple")
    }

    func testCannotDeleteLastProfile() async throws {
        let household = try await store.loadHousehold()
        for profile in household.profiles.dropLast() {
            try await store.deleteProfile(id: profile.id)
        }
        let remaining = try await store.loadHousehold()
        XCTAssertEqual(remaining.profiles.count, 1)
        do {
            try await store.deleteProfile(id: remaining.profiles[0].id)
            XCTFail("Expected delete to throw")
        } catch PlayerProfileRepositoryError.cannotDeleteLastProfile {
            // expected
        }
    }

    func testDeletePrimaryProfileReassignsDefault() async throws {
        let household = try await store.loadHousehold()
        let jacob = try XCTUnwrap(household.primaryProfile)
        let chris = try XCTUnwrap(household.sortedProfiles.last)
        try await store.setPrimaryProfile(id: chris.id)
        try await store.deleteProfile(id: chris.id)

        let updated = try await store.loadHousehold()
        XCTAssertEqual(updated.profiles.count, 1)
        XCTAssertEqual(updated.defaultPlayerOneProfileId, jacob.id)
    }

    func testSetPrimaryProfile() async throws {
        let household = try await store.loadHousehold()
        let chris = try XCTUnwrap(household.sortedProfiles.last)
        try await store.setPrimaryProfile(id: chris.id)
        let updated = try await store.loadHousehold()
        XCTAssertEqual(updated.defaultPlayerOneProfileId, chris.id)
    }

    func testProfileLookupById() async throws {
        let household = try await store.loadHousehold()
        let jacob = try XCTUnwrap(household.primaryProfile)
        let fetched = try await repository.profile(id: jacob.id)
        XCTAssertEqual(fetched?.displayName, "Jacob")
    }
}

final class PlayerMatchStatsCalculatorTests: XCTestCase {
    func testStatsFromProfileLinkedRecords() {
        let jacobId = UUID()
        let profile = PlayerProfile(id: jacobId, displayName: "Jacob", sortOrder: 0)
        let record = sampleRecord(
            playerOneName: "Jacob",
            playerTwoName: "Chris",
            playerOneProfileId: jacobId,
            playerOneVP: 10,
            playerTwoVP: 6,
            winner: .playerOne
        )
        let stats = PlayerMatchStatsCalculator.stats(for: profile, records: [record])
        XCTAssertEqual(stats.wins, 1)
        XCTAssertEqual(stats.losses, 0)
        XCTAssertEqual(stats.lastOpponentName, "Chris")
    }

    func testLegacyNameFallback() {
        let profile = PlayerProfile(displayName: "Chris", sortOrder: 0)
        let record = sampleRecord(
            playerOneName: "Jacob",
            playerTwoName: "Chris",
            playerOneVP: 6,
            playerTwoVP: 10,
            winner: .playerTwo
        )
        let stats = PlayerMatchStatsCalculator.stats(for: profile, records: [record])
        XCTAssertEqual(stats.wins, 1)
    }

    func testProfileIdTakesPrecedenceOverRenamedDisplayName() {
        let jacobId = UUID()
        let profile = PlayerProfile(id: jacobId, displayName: "Jake", sortOrder: 0)
        let record = sampleRecord(
            playerOneName: "Jacob",
            playerTwoName: "Chris",
            playerOneProfileId: jacobId,
            playerOneVP: 12,
            playerTwoVP: 8,
            winner: .playerOne
        )
        let stats = PlayerMatchStatsCalculator.stats(for: profile, records: [record])
        XCTAssertEqual(stats.wins, 1)
    }

    func testLossAndTieCounted() {
        let chrisId = UUID()
        let profile = PlayerProfile(id: chrisId, displayName: "Chris", sortOrder: 0)
        let loss = sampleRecord(
            playerOneName: "Jacob",
            playerTwoName: "Chris",
            playerTwoProfileId: chrisId,
            playerOneVP: 12,
            playerTwoVP: 8,
            winner: .playerOne
        )
        let tie = sampleRecord(
            playerOneName: "Jacob",
            playerTwoName: "Chris",
            playerTwoProfileId: chrisId,
            playerOneVP: 10,
            playerTwoVP: 10,
            winner: .tie
        )
        let stats = PlayerMatchStatsCalculator.stats(for: profile, records: [loss, tie])
        XCTAssertEqual(stats.wins, 0)
        XCTAssertEqual(stats.losses, 1)
        XCTAssertEqual(stats.ties, 1)
        XCTAssertEqual(stats.recordLabel, "0W · 1L · 1T")
    }

    func testRecordsFilterIncludesLegacyNameMatches() {
        let profile = PlayerProfile(displayName: "Chris", sortOrder: 0)
        let matching = sampleRecord(playerOneName: "Jacob", playerTwoName: "Chris")
        let other = sampleRecord(playerOneName: "Alex", playerTwoName: "Sam")
        let filtered = PlayerMatchStatsCalculator.records(involving: profile, from: [matching, other])
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.id, matching.id)
    }

    func testPerspectiveOutcomeFromPlayerTwoSlot() {
        let chrisId = UUID()
        let profile = PlayerProfile(id: chrisId, displayName: "Chris", sortOrder: 0)
        let record = sampleRecord(
            playerOneName: "Jacob",
            playerTwoName: "Chris",
            playerTwoProfileId: chrisId,
            playerOneVP: 6,
            playerTwoVP: 10,
            winner: .playerTwo
        )
        XCTAssertEqual(
            PlayerMatchStatsCalculator.perspectiveOutcome(for: record, profile: profile),
            .win
        )
    }

    func testLatestOpponentUsesMostRecentEndedAt() {
        let jacobId = UUID()
        let profile = PlayerProfile(id: jacobId, displayName: "Jacob", sortOrder: 0)
        let older = sampleRecord(
            playerOneName: "Jacob",
            playerTwoName: "Chris",
            playerOneProfileId: jacobId,
            endedAt: Date(timeIntervalSince1970: 1_000),
            playerOneVP: 10,
            playerTwoVP: 8,
            winner: .playerOne
        )
        let newer = sampleRecord(
            playerOneName: "Jacob",
            playerTwoName: "Taylor",
            playerOneProfileId: jacobId,
            endedAt: Date(timeIntervalSince1970: 2_000),
            playerOneVP: 11,
            playerTwoVP: 9,
            winner: .playerOne
        )
        let stats = PlayerMatchStatsCalculator.stats(for: profile, records: [older, newer])
        XCTAssertEqual(stats.lastOpponentName, "Taylor")
    }

    private func sampleRecord(
        playerOneName: String,
        playerTwoName: String,
        playerOneProfileId: UUID? = nil,
        playerTwoProfileId: UUID? = nil,
        endedAt: Date = Date(),
        playerOneVP: Int = 10,
        playerTwoVP: Int = 10,
        winner: MatchWinner = .tie
    ) -> MatchRecord {
        MatchRecord(
            gameSystemId: "aos-spearhead",
            gameSystemName: "Spearhead",
            createdAt: endedAt,
            endedAt: endedAt,
            status: .completed,
            players: MatchPlayerSummary(
                playerOneName: playerOneName,
                playerTwoName: playerTwoName,
                playerOneArmyLabel: "A",
                playerTwoArmyLabel: "B",
                playerOneProfileId: playerOneProfileId,
                playerTwoProfileId: playerTwoProfileId
            ),
            setup: MatchSetupSummary(),
            result: MatchResultSummary(
                playerOneVictoryPoints: playerOneVP,
                playerTwoVictoryPoints: playerTwoVP,
                winner: winner,
                battleRound: 4
            )
        )
    }
}

final class OwnedArmyResolverTests: XCTestCase {
    func testFiltersOwnedAndOtherArmies() {
        let armies = [
            SpearheadArmy(id: "a", name: "A", general: "G", tagline: "", playstyle: "", unitCount: 1),
            SpearheadArmy(id: "b", name: "B", general: "G", tagline: "", playstyle: "", unitCount: 1),
            SpearheadArmy(id: "c", name: "C", general: "G", tagline: "", playstyle: "", unitCount: 1)
        ]
        let split = OwnedArmyResolver.filtersArmies(armies, ownedIds: ["a", "c"])
        XCTAssertEqual(split.owned.map(\.id), ["a", "c"])
        XCTAssertEqual(split.other.map(\.id), ["b"])
    }
}

final class PlayersHubCodableTests: XCTestCase {
    func testMatchPlayerSummaryDecodesLegacyJSONWithoutProfileIds() throws {
        let json = """
        {
          "playerOneName": "Jacob",
          "playerTwoName": "Chris",
          "playerOneArmyLabel": "Skaven",
          "playerTwoArmyLabel": "Stormcast"
        }
        """.data(using: .utf8)!
        let summary = try JSONDecoder().decode(MatchPlayerSummary.self, from: json)
        XCTAssertNil(summary.playerOneProfileId)
        XCTAssertNil(summary.playerTwoProfileId)
        XCTAssertEqual(summary.playerOneFactionId, "")
    }

    func testPlayerArmySelectionRoundTripsProfileId() throws {
        let profileId = UUID()
        let selection = PlayerArmySelection(
            playerName: "Jacob",
            factionId: "skaven",
            armyId: "gnawfeast-clawpack",
            profileId: profileId
        )
        let data = try JSONEncoder().encode(selection)
        let decoded = try JSONDecoder().decode(PlayerArmySelection.self, from: data)
        XCTAssertEqual(decoded.profileId, profileId)
    }

    func testHouseholdStateRoundTripsThroughJSON() throws {
        let household = PlayerProfileSeed.makeDefaultHousehold()
        let data = try JSONEncoder().encode(household)
        let decoded = try JSONDecoder().decode(HouseholdPlayersState.self, from: data)
        XCTAssertEqual(decoded.profiles.count, 2)
        XCTAssertEqual(decoded.defaultPlayerOneProfileId, household.defaultPlayerOneProfileId)
    }
}

final class PlayerCoachingPolicyTests: XCTestCase {
    func testTableRegularSuppressesTips() {
        var profile = PlayerProfile(displayName: "Chris", sortOrder: 0)
        profile.guidedMatchPreferences.experienceLevel = .tableRegular
        XCTAssertFalse(
            PlayerCoachingPolicy.shouldShowTip(
                tipKey: .battleTrackerCoach,
                profile: profile,
                globallyDismissed: false
            )
        )
    }

    func testBeginnerRespectsGlobalDismiss() {
        let profile = PlayerProfile(displayName: "Jacob", sortOrder: 0)
        XCTAssertFalse(
            PlayerCoachingPolicy.shouldShowTip(
                tipKey: .battleTrackerCoach,
                profile: profile,
                globallyDismissed: true
            )
        )
    }

    func testPerProfileDismissal() {
        var profile = PlayerProfile(displayName: "Jacob", sortOrder: 0)
        profile.guidedMatchPreferences.dismissedCoachTipKeys.insert(
            PlayerCoachingPolicy.TipKey.battleTrackerCoach.rawValue
        )
        XCTAssertFalse(
            PlayerCoachingPolicy.shouldShowTip(
                tipKey: .battleTrackerCoach,
                profile: profile,
                globallyDismissed: false
            )
        )
    }
}

final class PlayerLoadoutPreferencesApplicatorTests: XCTestCase {
    func testAppliesSavedRegimentAndEnhancement() {
        let armyId = "gnawfeast-clawpack"
        var profile = PlayerProfile(displayName: "Jacob", sortOrder: 0)
        profile.guidedMatchPreferences.defaultRegimentAbilityByArmyId[armyId] = "regiment-b"
        profile.guidedMatchPreferences.defaultEnhancementByArmyId[armyId] = "enhancement-c"

        let army = SpearheadArmy(
            id: armyId,
            name: "Gnawfeast",
            general: "General",
            tagline: "",
            playstyle: "",
            unitCount: 1,
            regimentAbilities: [
                ArmyRuleOption(id: "regiment-a", name: "A"),
                ArmyRuleOption(id: "regiment-b", name: "B")
            ],
            enhancements: [
                ArmyRuleOption(id: "enhancement-c", name: "C"),
                ArmyRuleOption(id: "enhancement-d", name: "D")
            ]
        )

        var player = PlayerArmySelection(playerName: "Jacob", factionId: "skaven", armyId: armyId)
        PlayerLoadoutPreferencesApplicator.apply(to: &player, profile: profile, army: army)

        XCTAssertEqual(player.regimentAbilityId, "regiment-b")
        XCTAssertEqual(player.enhancementId, "enhancement-c")
    }
}

final class StarterMatchupProfileAssignerTests: XCTestCase {
    func testAssignsBoxArmiesToMatchingOwners() {
        let jacobId = UUID()
        let chrisId = UUID()
        var jacob = PlayerProfile(id: jacobId, displayName: "Jacob", sortOrder: 0)
        jacob.ownedSpearheadArmyIds = ["gnawfeast-clawpack"]
        var chris = PlayerProfile(id: chrisId, displayName: "Chris", sortOrder: 1)
        chris.ownedSpearheadArmyIds = ["vigilant-brotherhood"]
        let household = HouseholdPlayersState(profiles: [jacob, chris])

        let config = FeaturedArmiesConfig(
            armyIds: ["gnawfeast-clawpack", "vigilant-brotherhood"],
            starterMatchupTitle: "Starter",
            starterSetDescription: "",
            starterSetBadge: "",
            playerOne: StarterArmySelection(
                playerName: "P1",
                factionId: "stormcast",
                armyId: "vigilant-brotherhood"
            ),
            playerTwo: StarterArmySelection(
                playerName: "P2",
                factionId: "skaven",
                armyId: "gnawfeast-clawpack"
            )
        )

        var state = GuidedMatchState()
        state.playerOne.profileId = jacobId
        state.playerTwo.profileId = chrisId

        let result = StarterMatchupProfileAssigner.assignBoxArmiesToProfiles(
            config: config,
            household: household,
            state: &state
        )

        XCTAssertEqual(result, .assigned)
        XCTAssertEqual(state.playerOne.armyId, "gnawfeast-clawpack")
        XCTAssertEqual(state.playerTwo.armyId, "vigilant-brotherhood")
        XCTAssertEqual(state.playerOne.playerName, "Jacob")
        XCTAssertEqual(state.playerTwo.playerName, "Chris")
    }

    func testReturnsAmbiguousWhenOwnersDoNotMatchBox() {
        let jacobId = UUID()
        let chrisId = UUID()
        let jacob = PlayerProfile(id: jacobId, displayName: "Jacob", sortOrder: 0)
        let chris = PlayerProfile(id: chrisId, displayName: "Chris", sortOrder: 1)
        let household = HouseholdPlayersState(profiles: [jacob, chris])
        let config = FeaturedArmiesConfig(
            armyIds: ["a", "b"],
            starterMatchupTitle: "Starter",
            starterSetDescription: "",
            starterSetBadge: "",
            playerOne: StarterArmySelection(playerName: "P1", factionId: "f1", armyId: "a"),
            playerTwo: StarterArmySelection(playerName: "P2", factionId: "f2", armyId: "b")
        )
        var state = GuidedMatchState()
        state.playerOne.profileId = jacobId
        state.playerTwo.profileId = chrisId

        let result = StarterMatchupProfileAssigner.assignBoxArmiesToProfiles(
            config: config,
            household: household,
            state: &state
        )
        XCTAssertEqual(result, .ambiguous)
    }
}

final class PlayerDiceInputResolverTests: XCTestCase {
    func testNilPreferenceUsesDeviceDefault() {
        let profile = PlayerProfile(displayName: "Jacob", sortOrder: 0)
        XCTAssertEqual(
            PlayerDiceInputResolver.effectiveMode(profile: profile, deviceMode: .simulated),
            .simulated
        )
    }

    func testProfilePreferenceOverridesDevice() {
        var profile = PlayerProfile(displayName: "Jacob", sortOrder: 0)
        profile.guidedMatchPreferences.defaultDiceInputMode = DiceInputMode.physical.rawValue
        XCTAssertEqual(
            PlayerDiceInputResolver.effectiveMode(profile: profile, deviceMode: .simulated),
            .physical
        )
    }
}

final class PlayerProfileStoreCoachingTests: XCTestCase {
    private var tempDirectory: URL!
    private var store: PlayerProfileStore!

    override func setUp() async throws {
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        store = PlayerProfileStore(repository: JSONPlayerProfileRepository(baseDirectory: tempDirectory))
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDirectory)
    }

    func testResetCoachingTipsClearsDismissedKeys() async throws {
        let household = try await store.loadHousehold()
        var jacob = try XCTUnwrap(household.primaryProfile)
        jacob.guidedMatchPreferences.dismissedCoachTipKeys.insert("battle_tracker_coach")
        try await store.updateProfile(jacob)
        try await store.resetCoachingTips(profileId: jacob.id)
        let updated = try await store.loadHousehold()
        XCTAssertTrue(updated.profile(id: jacob.id)?.guidedMatchPreferences.dismissedCoachTipKeys.isEmpty == true)
    }
}
