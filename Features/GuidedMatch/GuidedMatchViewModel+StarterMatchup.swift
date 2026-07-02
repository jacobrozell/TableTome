import Foundation
import TabletomeDomain

extension GuidedMatchViewModel {
    func applyStarterMatchup(boxSet: BoxSet? = nil, household: HouseholdPlayersState? = nil) {
        BattleTrackerStore.reset(gameSystemId: gameSystemId)
        let context = GameSystemPlayContext.context(for: gameSystemId)
        let armies = boxSet.map { GuidedMatchFeaturedArmies(config: $0.featuredArmiesConfig()) } ?? featuredArmies
        let config = boxSet?.featuredArmiesConfig() ?? featuredArmies.featuredConfig
        starterMatchupProfileNote = nil
        mutateMatchState(persist: true, syncCompletions: false) {
            armies.applyStarterMatchup(to: &$0)
            if let household {
                switch StarterMatchupProfileAssigner.assignBoxArmiesToProfiles(
                    config: config,
                    household: household,
                    state: &$0
                ) {
                case .assigned:
                    break
                case .ambiguous:
                    starterMatchupProfileNote = String(
                        localized: "Assign both players in Guided Match to auto-fill armies from your starter boxes."
                    )
                case .notApplicable:
                    break
                }
            }
            $0.attackerIsPlayerOne = true
            if context.capabilities.deploymentChecklistStyle == .wh40k || context.capabilities.usesPatrolFormatRules {
                $0.firstTurnIsPlayerOne = true
            }
        }
        applyRecommendedLoadouts(household: household)
        syncAutoCompletions()
    }

    func applyRecommendedLoadouts(household: HouseholdPlayersState? = nil) {
        guard let catalog else { return }
        mutateMatchState {
            applyRecommendedLoadout(
                for: &$0.playerOne,
                catalog: catalog,
                household: household
            )
            applyRecommendedLoadout(
                for: &$0.playerTwo,
                catalog: catalog,
                household: household
            )
        }
    }

    func applyRecommendedLoadout(
        for player: inout PlayerArmySelection,
        catalog: SpearheadCatalog,
        household: HouseholdPlayersState?
    ) {
        guard let army = army(factionId: player.factionId, armyId: player.armyId) else { return }
        let profile = player.profileId.flatMap { household?.profile(id: $0) }
        PlayerLoadoutPreferencesApplicator.apply(to: &player, profile: profile, army: army)
    }
}
