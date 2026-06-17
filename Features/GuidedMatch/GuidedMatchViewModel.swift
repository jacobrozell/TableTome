import Foundation
import TabletomeDomain

@MainActor
final class GuidedMatchViewModel: ObservableObject {
    @Published private(set) var catalog: SpearheadCatalog?
    @Published private(set) var errorMessage: String?
    @Published var matchState: GuidedMatchState

    private let catalogRepository: any SpearheadCatalogRepository

    init(
        catalogRepository: any SpearheadCatalogRepository,
        initialState: GuidedMatchState = MatchSetupStore.load()
    ) {
        self.catalogRepository = catalogRepository
        self.matchState = initialState
    }

    var sortedFactions: [SpearheadFaction] {
        catalog?.factions.sorted { $0.name < $1.name } ?? []
    }

    var sortedMatchSteps: [MatchSetupStep] {
        catalog?.matchSteps.sorted { $0.order < $1.order } ?? []
    }

    var matchupSummary: String? {
        guard matchState.hasBothArmies, let catalog else { return nil }
        let p1 = armyLabel(for: matchState.playerOne, in: catalog)
        let p2 = armyLabel(for: matchState.playerTwo, in: catalog)
        return "\(matchState.playerOne.playerName) (\(p1)) vs. \(matchState.playerTwo.playerName) (\(p2))"
    }

    func load() async {
        do {
            catalog = try await catalogRepository.loadCatalog()
            errorMessage = nil
        } catch {
            errorMessage = String(localized: "Spearhead armies could not be loaded.")
        }
    }

    func updatePlayerOne(_ selection: PlayerArmySelection) {
        matchState.playerOne = selection
        persist()
    }

    func updatePlayerTwo(_ selection: PlayerArmySelection) {
        matchState.playerTwo = selection
        persist()
    }

    func setAttacker(isPlayerOne: Bool) {
        matchState.attackerIsPlayerOne = isPlayerOne
        persist()
    }

    func setRegimentAbility(playerIsOne: Bool, abilityId: String) {
        if playerIsOne {
            matchState.playerOne.regimentAbilityId = abilityId
        } else {
            matchState.playerTwo.regimentAbilityId = abilityId
        }
        persist()
    }

    func setEnhancement(playerIsOne: Bool, enhancementId: String) {
        if playerIsOne {
            matchState.playerOne.enhancementId = enhancementId
        } else {
            matchState.playerTwo.enhancementId = enhancementId
        }
        persist()
    }

    func setStepComplete(_ stepId: String, complete: Bool) {
        if complete {
            matchState.completedStepIds.insert(stepId)
        } else {
            matchState.completedStepIds.remove(stepId)
        }
        persist()
    }

    func resetMatch() {
        matchState = GuidedMatchState()
        MatchSetupStore.reset()
        BattleTrackerStore.reset()
    }

    func faction(id: String) -> SpearheadFaction? {
        catalog?.factions.first { $0.id == id }
    }

    func army(factionId: String, armyId: String) -> SpearheadArmy? {
        faction(id: factionId)?.armies.first { $0.id == armyId }
    }

    func armyLabel(for player: PlayerArmySelection, in catalog: SpearheadCatalog) -> String {
        guard let faction = catalog.factions.first(where: { $0.id == player.factionId }),
              let army = faction.armies.first(where: { $0.id == player.armyId }) else {
            return String(localized: "Not selected")
        }
        return "\(faction.name) — \(army.name)"
    }

    private func persist() {
        MatchSetupStore.save(matchState)
    }
}
