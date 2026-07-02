import Foundation

public extension GuidedMatchState {
    /// True when the user has changed anything beyond a fresh Guided Match.
    var hasGuidedMatchProgress: Bool {
        hasBothArmies
            || !completedStepIds.isEmpty
            || !playerOne.armyId.isEmpty
            || !playerTwo.armyId.isEmpty
            || !playerOne.factionId.isEmpty
            || !playerTwo.factionId.isEmpty
            || selectedMissionId != nil
            || attackerIsPlayerOne != nil
            || firstTurnIsPlayerOne != nil
    }
}

public extension BattleTrackerState {
    /// True when battle tracking has moved past a pristine default state.
    var hasBattleProgress: Bool {
        battleRound > 1
            || currentPhase != .deployment
            || playerOneVictoryPoints > 0
            || playerTwoVictoryPoints > 0
            || !unitWoundsRemaining.isEmpty
            || !usedOncePerBattleAbilityIds.isEmpty
            || !calledReinforcementUnitKeys.isEmpty
    }
}
