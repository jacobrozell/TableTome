import Foundation

public enum MatchSetupCompletionEvaluator {
    public static func autoCompletedStepIds(
        state: GuidedMatchState,
        catalog: SpearheadCatalog,
        deploymentSteps: Set<String>
    ) -> Set<String> {
        var completed = Set<String>()

        if state.hasBothArmies {
            completed.insert("choose-armies")
        }

        if state.attackerIsPlayerOne != nil {
            completed.insert("roll-attacker")
        }

        if regimentAbilitiesSatisfied(state: state, catalog: catalog) {
            completed.insert("regiment-abilities")
        }

        if enhancementsSatisfied(state: state, catalog: catalog) {
            completed.insert("enhancements")
        }

        let deploymentTotal = DeploymentChecklistStep.allCases.count
        if DeploymentChecklist.completionCount(completedSteps: deploymentSteps).done == deploymentTotal {
            completed.insert("realm-battlefield")
        }

        let setupStepIds = Set(catalog.matchSteps.map(\.id))
        let prerequisiteSteps = setupStepIds.subtracting(["fight-battle"])
        if prerequisiteSteps.isSubset(of: completed.union(state.completedStepIds)) {
            completed.insert("fight-battle")
        }

        return completed.intersection(setupStepIds)
    }

    private static func regimentAbilitiesSatisfied(state: GuidedMatchState, catalog: SpearheadCatalog) -> Bool {
        playerRuleSelectionSatisfied(
            player: state.playerOne,
            catalog: catalog,
            options: \.regimentAbilities,
            selection: \.regimentAbilityId
        ) && playerRuleSelectionSatisfied(
            player: state.playerTwo,
            catalog: catalog,
            options: \.regimentAbilities,
            selection: \.regimentAbilityId
        )
    }

    private static func enhancementsSatisfied(state: GuidedMatchState, catalog: SpearheadCatalog) -> Bool {
        playerRuleSelectionSatisfied(
            player: state.playerOne,
            catalog: catalog,
            options: \.enhancements,
            selection: \.enhancementId
        ) && playerRuleSelectionSatisfied(
            player: state.playerTwo,
            catalog: catalog,
            options: \.enhancements,
            selection: \.enhancementId
        )
    }

    private static func playerRuleSelectionSatisfied(
        player: PlayerArmySelection,
        catalog: SpearheadCatalog,
        options: KeyPath<SpearheadArmy, [ArmyRuleOption]>,
        selection: KeyPath<PlayerArmySelection, String?>
    ) -> Bool {
        guard let army = army(for: player, catalog: catalog) else { return false }
        let choices = army[keyPath: options]
        if choices.isEmpty { return true }
        return player[keyPath: selection] != nil
    }

    private static func army(for player: PlayerArmySelection, catalog: SpearheadCatalog) -> SpearheadArmy? {
        guard let faction = catalog.factions.first(where: { $0.id == player.factionId }) else { return nil }
        return faction.armies.first { $0.id == player.armyId }
    }
}
