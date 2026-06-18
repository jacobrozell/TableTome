import Foundation

/// Short, phase-specific reminders shown under the phase picker for new players.
public enum PhaseContextCoach {
    public static func quickTips(for phase: BattleTurnPhase) -> [String] {
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
        case .enemyMovement, .endOfAnyTurn:
            []
        }
    }
}
