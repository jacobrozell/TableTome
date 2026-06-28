import Foundation
import TabletomeDomain

extension BattlePhaseTrackerViewModel {
    func refreshAbilities() {
        playerOneName = matchState.playerOne.playerName
        playerTwoName = matchState.playerTwo.playerName
        playerOneArmy = army(for: matchState.playerOne)
        playerTwoArmy = army(for: matchState.playerTwo)
        playerOneRegimentAbility = playerOneArmy?.regimentAbilities.first {
            $0.id == matchState.playerOne.regimentAbilityId
        }
        playerTwoRegimentAbility = playerTwoArmy?.regimentAbilities.first {
            $0.id == matchState.playerTwo.regimentAbilityId
        }
        playerOneEnhancement = playerOneArmy?.enhancements.first {
            $0.id == matchState.playerOne.enhancementId
        }
        playerTwoEnhancement = playerTwoArmy?.enhancements.first {
            $0.id == matchState.playerTwo.enhancementId
        }
        playerOneSecondary = playerOneArmy?.secondaryObjectives.first {
            $0.id == matchState.playerOne.secondaryObjectiveId
        }
        playerTwoSecondary = playerTwoArmy?.secondaryObjectives.first {
            $0.id == matchState.playerTwo.secondaryObjectiveId
        }
        ensureWoundTrackingInitialized()

        guard let army = activeArmySelection else {
            activeAbilities = []
            passiveAbilities = []
            contentCoverage = playContext.usesGuidedBattleTracker ? .battleTracker : .roster
            armyName = ""
            activeRegimentAbility = nil
            activeEnhancement = nil
            activeArmy = nil
            activeGotchas = []
            return
        }

        let player = activePlayerSelection
        activeArmy = army
        armyName = army.name
        contentCoverage = army.contentCoverage
        activeRegimentAbility = army.regimentAbilities.first { $0.id == player.regimentAbilityId }
        activeEnhancement = army.enhancements.first { $0.id == player.enhancementId }
        activeGotchas = Self.gotchas(for: army.id, gameSystemId: gameSystemId, army: army)
        if playContext.usesGuidedBattleTracker {
            contentCoverage = .battleTracker
        }
        let all = BattleAbilityCatalog.abilities(for: army)

        if trackerState.showAllAbilities {
            activeAbilities = all.filter { !$0.isPassive }.sorted { $0.source < $1.source }
            passiveAbilities = all.filter(\.isPassive)
            return
        }

        let phase = trackerState.currentPhase
        let actionable = all.filter { ability in
            !ability.isPassive && ability.isAvailableIn(phase: phase, usedOncePerBattle: trackerState.usedOncePerBattleAbilityIds)
        }
        activeAbilities = actionable.sorted { $0.source < $1.source }
        passiveAbilities = all.filter(\.isPassive)
    }

    func army(for player: PlayerArmySelection) -> SpearheadArmy? {
        guard let faction = catalog.factions.first(where: { $0.id == player.factionId }) else { return nil }
        return faction.armies.first { $0.id == player.armyId }
    }

    func army(withId armyId: String) -> SpearheadArmy? {
        if playerOneArmy?.id == armyId { return playerOneArmy }
        if playerTwoArmy?.id == armyId { return playerTwoArmy }
        return nil
    }

    func playerName(forArmyId armyId: String) -> String {
        if matchState.playerOne.armyId == armyId { return playerOneName }
        if matchState.playerTwo.armyId == armyId { return playerTwoName }
        return ""
    }

    var playerOneArmyLabel: String {
        MatchArmyLabelFormatter.label(for: matchState.playerOne, in: catalog)
    }

    var playerTwoArmyLabel: String {
        MatchArmyLabelFormatter.label(for: matchState.playerTwo, in: catalog)
    }

    func reloadFromPersistedStores() {
        matchState = MatchSetupStore.load(gameSystemId: gameSystemId)
        trackerState = BattleTrackerStore.load(gameSystemId: gameSystemId)
        syncAutoCompletions()
        refreshAbilities()
    }

    var allAbilities: [TriggeredAbility] {
        guard let army = activeArmy else { return [] }
        return BattleAbilityCatalog.abilities(for: army)
    }
}
