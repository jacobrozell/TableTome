import Foundation

/// Short, phase-specific reminders shown under the phase picker for new players.
public enum PhaseContextCoach {
    public static func quickTips(
        for phase: BattleTurnPhase,
        gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    ) -> [String] {
        let context = GameSystemPlayContext.context(for: gameSystemId)
        if context.isCombatPatrol {
            return combatPatrolQuickTips(for: phase)
        }
        if context.isWh40k11e {
            return wh40kQuickTips(for: phase)
        }
        if context.isStarCraft {
            return starCraftQuickTips(for: phase)
        }
        return spearheadQuickTips(for: phase)
    }

    private static func combatPatrolQuickTips(for phase: BattleTurnPhase) -> [String] {
        switch phase {
        case .command:
            [
                String(localized: "Secure objectives with Battleline units at the end of Command phase."),
                String(localized: "Mark secured markers and stratagems on the Table State card.")
            ]
        case .movement:
            [
                String(localized: "Deep Strike and Reserves arrive from battle round 2."),
                String(localized: "Reserves must arrive by end of battle round 3 or are destroyed.")
            ]
        case .endOfTurn:
            [
                String(localized: "Score secondaries and any end-of-turn mission VP."),
                String(localized: "Round 5: the second-turn player scores primary VP here, not in Command.")
            ]
        case .shooting, .charge, .combat, .anyCombat:
            wh40kQuickTips(for: phase)
        case .deployment, .enemyMovement, .endOfAnyTurn, .assault, .scoring, .hero:
            []
        }
    }

    private static func wh40kQuickTips(for phase: BattleTurnPhase) -> [String] {
        switch phase {
        case .command:
            [
                String(localized: "Gain Command Points at the start of your Command phase."),
                String(localized: "Test Battle-shock for units below half strength, then use stratagems.")
            ]
        case .movement:
            [
                String(localized: "Move up to the unit's Move characteristic."),
                String(localized: "Advancing adds distance but usually stops the unit from shooting.")
            ]
        case .shooting:
            [
                String(localized: "Measure range to the closest part of each target."),
                String(localized: "Resolve hit, wound, save, and damage on your datasheets.")
            ]
        case .charge:
            [
                String(localized: "Declare charges into engagement range, then roll 2D6."),
                String(localized: "Both dice must reach the target — a failed charge means the unit stays put.")
            ]
        case .combat, .anyCombat:
            [
                String(localized: "Fight with units in engagement range — alternate attacks."),
                String(localized: "After rolling, apply damage in the Army Health tracker.")
            ]
        case .endOfTurn:
            [
                String(localized: "Score primary and secondary objectives for this turn."),
                String(localized: "Use the quick-add buttons below, then pass the phone.")
            ]
        case .deployment, .enemyMovement, .endOfAnyTurn, .assault, .scoring, .hero:
            []
        }
    }

    private static func spearheadQuickTips(for phase: BattleTurnPhase) -> [String] {
        switch phase {
        case .hero:
            [
                String(localized: "Use heroic abilities, spells, and prayers before moving."),
                String(localized: "Most abilities can only be used once per turn unless noted.")
            ]
        case .movement:
            [
                String(localized: "Move up to the unit's Move characteristic, staying in coherency."),
                String(localized: "Running adds distance but usually stops the unit from shooting or charging.")
            ]
        case .shooting:
            [
                String(localized: "Measure range to the closest part of each target."),
                String(localized: "Open Resolve Combat below and enter the dice you rolled at the table.")
            ]
        case .charge:
            [
                String(localized: "Pick a target within 12\", then roll 2D6 for charge distance."),
                String(localized: "Both dice must reach the target — add 2\" when climbing up a ruin or hill."),
                String(localized: "A failed charge roll means the unit stays put.")
            ]
        case .combat, .anyCombat:
            [
                String(localized: "Fight with units in combat — pick targets and strike in order."),
                String(
                    localized: "Pile in: models not in base contact can move up to 3\" toward the enemy — only if they end closer to an enemy model."
                ),
                String(localized: "After rolling, apply damage to update the Army Health tracker.")
            ]
        case .endOfTurn:
            [
                String(localized: "Add victory points for objectives you hold and battle tactics you completed."),
                String(localized: "Use the quick-add buttons below, then pass the phone.")
            ]
        case .deployment:
            [
                String(localized: "Finish terrain and objectives before placing any models."),
                String(localized: "Defender picks a board side, then players alternate deploying.")
            ]
        case .command, .enemyMovement, .endOfAnyTurn, .assault, .scoring:
            []
        }
    }

    private static func starCraftQuickTips(for phase: BattleTurnPhase) -> [String] {
        switch phase {
        case .movement, .assault, .combat, .scoring:
            []
        default:
            []
        }
    }
}
