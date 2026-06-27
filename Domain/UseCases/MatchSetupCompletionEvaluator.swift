import Foundation

public enum MatchSetupCompletionEvaluator {
    public static func autoCompletedStepIds(
        state: GuidedMatchState,
        catalog: SpearheadCatalog,
        deploymentSteps: Set<String>,
        gameSystemId: GameSystemId
    ) -> Set<String> {
        autoCompletedStepIds(
            state: state,
            catalog: catalog,
            deploymentSteps: deploymentSteps,
            gameSystemId: gameSystemId.rawValue
        )
    }

    public static func autoCompletedStepIds(
        state: GuidedMatchState,
        catalog: SpearheadCatalog,
        deploymentSteps: Set<String>,
        gameSystemId: String = GameSystemId.default.rawValue
    ) -> Set<String> {
        var completed = Set<String>()
        let setupStepIds = Set(catalog.matchSteps.map(\.id))
        let context = GameSystemPlayContext.context(for: gameSystemId)

        if state.hasBothArmies {
            completed.insert("choose-armies")
        }

        if state.attackerIsPlayerOne != nil {
            completed.insert("roll-attacker")

            if regimentAbilitiesSatisfied(state: state, catalog: catalog) {
                completed.insert("regiment-abilities")
                completed.insert("force-disposition")
            }

            if enhancementsSatisfied(state: state, catalog: catalog) {
                completed.insert("enhancements")
            }
        }

        if context.isCombatPatrol {
            if loadoutSatisfied(state: state, catalog: catalog) {
                completed.insert("pick-enhancement")
            }
            if state.selectedMissionId != nil {
                completed.insert("determine-mission")
            }
            if CombatPatrolDeploymentChecklist.setupBattlefieldComplete(
                completedSteps: deploymentSteps,
                attackerIsPlayerOne: state.attackerIsPlayerOne
            ) {
                completed.insert("setup-battlefield")
            }
            if CombatPatrolDeploymentChecklist.declareFormationsComplete(completedSteps: deploymentSteps) {
                completed.insert("declare-formations")
            }
            if CombatPatrolDeploymentChecklist.deployArmiesComplete(completedSteps: deploymentSteps) {
                completed.insert("deploy-armies")
            }
            if CombatPatrolDeploymentChecklist.rollFirstTurnComplete(
                completedSteps: deploymentSteps,
                firstTurnIsPlayerOne: state.firstTurnIsPlayerOne
            ) {
                completed.insert("roll-first-turn")
            }
        }

        let deploymentComplete: Bool
        if context.isWh40k11e {
            deploymentComplete = Wh40kDeploymentChecklist.completionCount(completedSteps: deploymentSteps).done
                == Wh40kDeploymentChecklistStep.allCases.count
        } else if context.isStarCraft {
            deploymentComplete = ScTmgDeploymentChecklist.completionCount(completedSteps: deploymentSteps).done
                == ScTmgDeploymentChecklistStep.allCases.count
        } else if context.isCombatPatrol {
            deploymentComplete = CombatPatrolDeploymentChecklist.completionCount(completedSteps: deploymentSteps).done
                == CombatPatrolDeploymentChecklistStep.allCases.count
                && state.attackerIsPlayerOne != nil
                && state.firstTurnIsPlayerOne != nil
        } else {
            deploymentComplete = DeploymentChecklist.completionCount(completedSteps: deploymentSteps).done
                == DeploymentChecklistStep.allCases.count
        }

        if deploymentComplete {
            if setupStepIds.contains("realm-battlefield") {
                completed.insert("realm-battlefield")
            }
            if setupStepIds.contains("deploy-battlefield") {
                completed.insert("deploy-battlefield")
            }
            if setupStepIds.contains("battlefield-setup") {
                completed.insert("battlefield-setup")
            }
        }

        let prerequisiteSteps = setupStepIds.subtracting(["fight-battle"])
        if prerequisiteSteps.isSubset(of: completed.union(state.completedStepIds)) {
            completed.insert("fight-battle")
        }

        return completed.intersection(setupStepIds)
    }

    private static func loadoutSatisfied(state: GuidedMatchState, catalog: SpearheadCatalog) -> Bool {
        enhancementsSatisfied(state: state, catalog: catalog)
            && secondariesSatisfied(state: state, catalog: catalog)
    }

    private static func secondariesSatisfied(state: GuidedMatchState, catalog: SpearheadCatalog) -> Bool {
        playerRuleSelectionSatisfied(
            player: state.playerOne,
            catalog: catalog,
            options: \.secondaryObjectives,
            selection: \.secondaryObjectiveId
        ) && playerRuleSelectionSatisfied(
            player: state.playerTwo,
            catalog: catalog,
            options: \.secondaryObjectives,
            selection: \.secondaryObjectiveId
        )
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
