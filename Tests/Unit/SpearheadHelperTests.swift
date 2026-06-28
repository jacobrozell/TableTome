import XCTest
@testable import TabletomeDomain

final class BattleRoundChecklistTests: XCTestCase {
    func testRoundOneFirstTurnTitle() {
        let step = BattleRoundChecklistStep.firstTurnOrPriority
        XCTAssertTrue(step.title(round: 1).contains("Attacker"))
        XCTAssertTrue(step.title(round: 2).contains("Priority"))
    }

    func testRoundOneDrawBattleTacticsDetail() {
        let step = BattleRoundChecklistStep.drawBattleTactics
        XCTAssertTrue(step.title(round: 1).contains("Draw"))
        XCTAssertTrue(step.title(round: 2).contains("Refresh"))
        XCTAssertTrue(step.detail(round: 1).contains("no mulligan"))
        XCTAssertTrue(step.detail(round: 2).contains("Discard"))
    }

    func testCompletionTracking() {
        var completed: [String: Set<String>] = [:]
        let round = 1
        let key = BattleRoundChecklist.storageKey(round: round)
        completed[key] = [BattleRoundChecklistStep.drawTwistCard.rawValue]
        XCTAssertTrue(BattleRoundChecklist.isComplete(step: .drawTwistCard, round: round, completedSteps: completed))
        XCTAssertFalse(BattleRoundChecklist.isComplete(step: .identifyUnderdog, round: round, completedSteps: completed))
        XCTAssertEqual(BattleRoundChecklist.completionCount(round: round, completedSteps: completed).done, 1)
    }
}

final class UnitWoundCapacityTests: XCTestCase {
    func testCapacityUsesModelCount() {
        let unit = SpearheadUnit(id: "liberators", name: "Liberators", health: 2, modelCount: 5)
        XCTAssertEqual(UnitWoundCapacity.capacity(for: unit), 10)
    }

    func testHeroDefaultsToSingleModel() {
        let unit = SpearheadUnit(id: "grey-seer", name: "Grey Seer", health: 5)
        XCTAssertEqual(UnitWoundCapacity.capacity(for: unit), 5)
    }
}

final class MatchSyncCodecTests: XCTestCase {
    func testEncodeDecodeRoundTrip() throws {
        var tracker = BattleTrackerState()
        tracker.battleRound = 2
        let snapshot = MatchSyncSnapshot(
            matchState: GuidedMatchState(
                playerOne: PlayerArmySelection(playerName: "Alice", armyId: "gnawfeast-clawpack"),
                playerTwo: PlayerArmySelection(playerName: "Bob", armyId: "vigilant-brotherhood")
            ),
            trackerState: tracker
        )
        let code = try XCTUnwrap(MatchSyncCodec.encode(snapshot))
        let decoded = try XCTUnwrap(MatchSyncCodec.decode(code))
        XCTAssertEqual(decoded.schemaVersion, MatchSyncSchemaPolicy.version)
        XCTAssertEqual(decoded.matchState.playerOne.playerName, "Alice")
        XCTAssertEqual(decoded.trackerState.battleRound, 2)
    }

    func testCombatPatrolSyncRoundTripUsesGameSystemId() throws {
        var tracker = BattleTrackerState()
        tracker.securedObjectiveIds = ["A", "B"]
        tracker.usedStratagemIds = ["space-marines-combat-patrol:duty-and-honour"]
        let snapshot = MatchSyncSnapshot(
            gameSystemId: "wh40k-10e-cp",
            matchState: GuidedMatchState(selectedMissionId: "clash-of-patrols"),
            trackerState: tracker
        )

        MatchSetupStore.save(snapshot.matchState, gameSystemId: "wh40k-10e-cp", notifySync: false)
        BattleTrackerStore.save(snapshot.trackerState, gameSystemId: "wh40k-10e-cp", notifySync: false)
        defer {
            MatchSetupStore.reset(gameSystemId: "wh40k-10e-cp")
            BattleTrackerStore.reset(gameSystemId: "wh40k-10e-cp")
        }

        let code = try XCTUnwrap(MatchSyncCodec.encode(snapshot))
        MatchSetupStore.reset(gameSystemId: "wh40k-10e-cp")
        BattleTrackerStore.reset(gameSystemId: "wh40k-10e-cp")

        let decoded = try XCTUnwrap(MatchSyncCodec.decode(code))
        MatchSyncCodec.apply(decoded)

        XCTAssertEqual(MatchSetupStore.load(gameSystemId: "wh40k-10e-cp").selectedMissionId, "clash-of-patrols")
        let loaded = BattleTrackerStore.load(gameSystemId: "wh40k-10e-cp")
        XCTAssertEqual(loaded.securedObjectiveIds, ["A", "B"])
        XCTAssertTrue(loaded.usedStratagemIds.contains("space-marines-combat-patrol:duty-and-honour"))
    }

    func testStarCraftSyncRoundTripPreservesMarkerFields() throws {
        var tracker = BattleTrackerState(
            currentPhase: .movement,
            scFirstPlayerMarkerIsPlayerOne: true,
            scPhasePassClaimedByPlayerOne: false
        )
        tracker.activePlayerIsOne = false
        let snapshot = MatchSyncSnapshot(
            gameSystemId: "sc-tmg",
            matchState: GuidedMatchState(
                playerOne: PlayerArmySelection(playerName: "Raynor", factionId: "terran", armyId: "raynors-raiders"),
                playerTwo: PlayerArmySelection(playerName: "Kerrigan", factionId: "zerg", armyId: "kerrigans-swarm")
            ),
            trackerState: tracker
        )

        let code = try XCTUnwrap(MatchSyncCodec.encode(snapshot))
        let decoded = try XCTUnwrap(MatchSyncCodec.decode(code))
        XCTAssertEqual(decoded.gameSystemId, "sc-tmg")
        XCTAssertEqual(decoded.matchState.playerOne.playerName, "Raynor")
        XCTAssertEqual(decoded.trackerState.scFirstPlayerMarkerIsPlayerOne, true)
        XCTAssertEqual(decoded.trackerState.scPhasePassClaimedByPlayerOne, false)
        XCTAssertFalse(decoded.trackerState.activePlayerIsOne)
    }
}

final class WeaponAttackRollCountTests: XCTestCase {
    func testClanratsSplitUnitDiceCount() {
        let weapon = SpearheadWeapon(
            id: "rusty-blade",
            name: "Rusty Blade",
            attacks: "2",
            hit: 4,
            wound: 5,
            rend: 0,
            damage: "1"
        )
        XCTAssertEqual(
            WeaponAttackRollCount.totalAttacks(weapon: weapon, deployedModelCount: 10),
            20
        )
        XCTAssertTrue(
            WeaponAttackRollCount.hitDiceSummary(weapon: weapon, deployedModelCount: 10)
                .contains("20")
        )
    }

    func testSingleModelSingleAttackSummary() {
        let weapon = SpearheadWeapon(
            id: "blade",
            name: "Blade",
            attacks: "1",
            hit: 4,
            wound: 4,
            rend: 0,
            damage: "1"
        )
        XCTAssertEqual(
            WeaponAttackRollCount.hitDiceSummary(weapon: weapon, deployedModelCount: 1),
            String(localized: "Roll 1 hit dice")
        )
    }

    func testVariableAttacksSingleModelSummary() {
        let weapon = SpearheadWeapon(
            id: "warpfire-gun",
            name: "Warpfire Gun",
            rangeInches: 10,
            attacks: "2D6",
            hit: 2,
            wound: 4,
            rend: 2,
            damage: "1"
        )
        let plan = WeaponAttackRollCount.hitDicePlan(weapon: weapon, deployedModelCount: 1)
        XCTAssertNil(plan.fixedTotalHitDice)
        XCTAssertEqual(plan.variableAttackExpression, "2D6")
        XCTAssertTrue(plan.summary.contains("2D6"))
        XCTAssertTrue(plan.detail?.contains("2D6") == true)
    }

    func testVariableAttacksMultipleModelsWarnsAboutPerModelRolls() {
        let weapon = SpearheadWeapon(
            id: "ratling-pistol",
            name: "Ratling Pistol",
            rangeInches: 10,
            attacks: "D6",
            hit: 3,
            wound: 3,
            rend: 1,
            damage: "1"
        )
        let plan = WeaponAttackRollCount.hitDicePlan(weapon: weapon, deployedModelCount: 3)
        XCTAssertEqual(plan.variableAttackExpression, "D6")
        XCTAssertTrue(plan.summary.contains("3"))
        XCTAssertTrue(plan.detail?.localizedCaseInsensitiveContains("warpfire") == true
            || plan.detail?.localizedCaseInsensitiveContains("separately") == true)
    }

    func testStartOfBattleRoundDetection() {
        let ability = TriggeredAbility(
            id: "test",
            name: "Rally",
            source: "Unit",
            phases: [.hero],
            usageLimit: .eachTurn,
            effect: "At the start of the battle round, heal 1 wound."
        )
        XCTAssertTrue(ability.isStartOfBattleRound)
    }

    func testUnitCanShootWhenRangedWeaponPresent() {
        let unit = SpearheadUnit(
            id: "shooters",
            name: "Shootas",
            weapons: [
                SpearheadWeapon(
                    id: "bow",
                    name: "Bow",
                    rangeInches: 18,
                    attacks: "2",
                    hit: 4,
                    wound: 4,
                    rend: 0,
                    damage: "1"
                )
            ]
        )
        XCTAssertTrue(unit.canShoot)
        XCTAssertEqual(unit.shootingWeapons.count, 1)
    }
}

final class SpearheadGotchaCatalogTests: XCTestCase {
    func testFeaturedArmiesHaveGotchas() {
        XCTAssertFalse(SpearheadGotchaCatalog.gotchas(for: "vigilant-brotherhood").isEmpty)
        XCTAssertFalse(SpearheadGotchaCatalog.gotchas(for: "gnawfeast-clawpack").isEmpty)
        XCTAssertTrue(SpearheadGotchaCatalog.gotchas(for: "unknown").isEmpty)
    }
}

final class CombatPatrolGotchaCatalogTests: XCTestCase {
    func testLeviathanArmiesHaveGotchas() {
        XCTAssertEqual(CombatPatrolGotchaCatalog.gotchas(for: "space-marines-combat-patrol").count, 3)
        XCTAssertEqual(CombatPatrolGotchaCatalog.gotchas(for: "tyranids-combat-patrol").count, 3)
        XCTAssertEqual(CombatPatrolGotchaCatalog.gotchas(for: "orks-combat-patrol").count, 3)
        XCTAssertEqual(CombatPatrolGotchaCatalog.gotchas(for: "necrons-combat-patrol").count, 3)
        XCTAssertEqual(CombatPatrolGotchaCatalog.gotchas(for: "adeptus-custodes-combat-patrol").count, 3)
        XCTAssertEqual(CombatPatrolGotchaCatalog.gotchas(for: "astra-militarum-combat-patrol").count, 3)
        XCTAssertTrue(CombatPatrolGotchaCatalog.gotchas(for: "unknown").isEmpty)
    }

    func testCatalogDerivedGotchasWhenNoCuratedEntry() {
        let army = SpearheadArmy(
            id: "adepta-sororitas-combat-patrol",
            name: "The Penitent Host",
            general: "Canoness Ellyrine",
            tagline: "Test",
            playstyle: "Test",
            unitCount: 7,
            battleTraits: [
                ArmyRuleOption(id: "act-of-faith", name: "Act of Faith", summary: "Miracle dice each turn.")
            ],
            enhancements: [
                ArmyRuleOption(id: "armour-of-faith", name: "Armour of Faith", summary: "Feel No Pain on Ellyrine.")
            ],
            stratagems: [
                CombatPatrolStratagem(id: "divine-protection", name: "Divine Protection", summary: "5+ invulnerable.", cpCost: 1, phase: "Fight", isReactive: true)
            ]
        )
        XCTAssertEqual(CombatPatrolGotchaCatalog.gotchas(for: army.id, army: army).count, 3)
    }
}

final class DeploymentChecklistTests: XCTestCase {
    func testDeploymentStepsComplete() {
        var completed: Set<String> = [DeploymentChecklistStep.setupTerrain.rawValue]
        XCTAssertTrue(DeploymentChecklist.isComplete(step: .setupTerrain, completedSteps: completed))
        XCTAssertEqual(DeploymentChecklist.completionCount(completedSteps: completed).done, 1)
    }
}

final class SpearheadRulesGlossaryTests: XCTestCase {
    func testFindsReferencedTerms() {
        let entries = SpearheadRulesGlossary.entriesReferenced(
            in: "Pick a visible enemy wholly within 12\" contesting an objective."
        )
        XCTAssertTrue(entries.contains { $0.id == "visible" })
        XCTAssertTrue(entries.contains { $0.id == "wholly-within" })
        XCTAssertTrue(entries.contains { $0.id == "contest" })
    }

    func testFindsNewPlayerTerms() {
        let entries = SpearheadRulesGlossary.entriesReferenced(
            in: "Review your warscroll, pick a regiment ability, and draw a twist card for victory points."
        )
        XCTAssertTrue(entries.contains { $0.id == "warscroll" })
        XCTAssertTrue(entries.contains { $0.id == "regiment-ability" })
        XCTAssertTrue(entries.contains { $0.id == "twist-card" })
        XCTAssertTrue(entries.contains { $0.id == "victory-points" })
    }

    func testGlossaryHasNewcomerEntries() {
        XCTAssertGreaterThanOrEqual(SpearheadRulesGlossary.entries.count, 16)
    }

    func testBattleTacticsReferenceHasSections() {
        XCTAssertFalse(SpearheadBattleTacticsReference.sections.isEmpty)
        XCTAssertEqual(SpearheadBattleTacticsReference.deckGuides.count, 2)
        XCTAssertTrue(SpearheadBattleTacticsReference.sections.contains { $0.id == "first-hand" })
        XCTAssertTrue(SpearheadBattleTacticsReference.sections.contains { $0.id == "refresh-hand" })
        XCTAssertFalse(SpearheadBattleTacticsReference.sections.first { $0.id == "refresh-hand" }?.examples.isEmpty ?? true)
    }
}

final class CombatRollOptionsTests: XCTestCase {
    func testWeaponParsesCritMortal() {
        let weapon = SpearheadWeapon(
            id: "warhammer",
            name: "Warhammer",
            attacks: "2",
            hit: 3,
            wound: 3,
            rend: 1,
            damage: "1",
            ability: "Crit (Mortal)"
        )
        XCTAssertTrue(weapon.hasCritMortal)
        XCTAssertEqual(CombatRollOptions.from(weapon: weapon).critMortal, true)
    }

    func testCritMortalSkipsSave() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 3, saveTarget: 4, rend: 0, damage: 2,
            hitRoll: 4, woundRoll: 6, saveRoll: 6,
            critMortal: true
        )
        let result = CombatRollEngine.evaluate(input)
        XCTAssertEqual(result.damageDealt, 2)
        XCTAssertTrue(result.steps.contains { $0.id == "save" && $0.explanation.contains("Mortal") })
    }

    func testCritAutoWoundOnHitSix() {
        let input = AttackRollInput(
            hitTarget: 3, woundTarget: 4, saveTarget: 4, rend: 0, damage: 1,
            hitRoll: 6, woundRoll: 1, saveRoll: 3,
            critAutoWound: true
        )
        let result = CombatRollEngine.evaluate(input)
        XCTAssertGreaterThan(result.damageDealt, 0)
    }
}
