import Foundation
import TabletomeDomain

extension SpearheadBattleViewModel {
    var underdogPlayerName: String? {
        guard let underdogIsPlayerOne = underdogIsPlayerOne else { return nil }
        return underdogIsPlayerOne ? playerOneName : playerTwoName
    }

    var needsStartOfRoundAbilitiesPrompt: Bool {
        guard playContext.capabilities.showsBattleTacticDecks else { return false }
        return !BattleRoundChecklist.isComplete(
            step: .startOfRoundAbilities,
            round: trackerState.battleRound,
            completedSteps: trackerState.completedRoundChecklistSteps
        )
    }

    var startOfRoundAbilities: [TriggeredAbility] {
        startOfRoundAbilities(for: playerOneArmy) + startOfRoundAbilities(for: playerTwoArmy)
    }

    func completeStartOfRoundAbilitiesStep() {
        setRoundChecklistStep(.startOfRoundAbilities, complete: true)
    }

    private func startOfRoundAbilities(for army: SpearheadArmy?) -> [TriggeredAbility] {
        guard let army else { return [] }
        return BattleAbilityCatalog.abilities(for: army).filter(\.isStartOfBattleRound)
    }
}
