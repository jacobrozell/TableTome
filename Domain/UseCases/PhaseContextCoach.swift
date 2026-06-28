import Foundation

/// Short, phase-specific reminders shown under the phase picker for new players.
public enum PhaseContextCoach {
    /// One-line “do this now” prompt shown when the battle tracker advances to a new phase.
    public static func phaseActionNudge(
        for phase: BattleTurnPhase,
        gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    ) -> String? {
        let context = GameSystemPlayContext.context(for: gameSystemId)
        if context.capabilities.deploymentChecklistStyle == .wh40k {
            return wh40k11ePhaseActionNudge(for: phase)
        }
        if context.capabilities.usesPatrolFormatRules {
            return combatPatrolPhaseActionNudge(for: phase)
        }
        if context.capabilities.showsActivationBar {
            return starCraftPhaseActionNudge(for: phase)
        }
        return spearheadPhaseActionNudge(for: phase)
    }

    public static func quickTips(
        for phase: BattleTurnPhase,
        gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    ) -> [String] {
        let context = GameSystemPlayContext.context(for: gameSystemId)
        if context.capabilities.deploymentChecklistStyle == .wh40k {
            return wh40k11eQuickTips(for: phase)
        }
        if context.capabilities.usesPatrolFormatRules {
            return combatPatrolQuickTips(for: phase)
        }
        if context.capabilities.showsActivationBar {
            return starCraftQuickTips(for: phase)
        }
        return spearheadQuickTips(for: phase)
    }

    private static func combatPatrolQuickTips(for phase: BattleTurnPhase) -> [String] {
        switch phase {
        case .command:
            [
                String(
                    localized: """
                    Hold objectives with troops on the board — open unit details in Guided Match to see which models can score.
                    """
                ),
                String(
                    localized: """
                    Mark secured objectives and any Command abilities you used on the Table State card.
                    """
                )
            ]
        case .movement:
            [
                String(localized: "Units that started off the board can arrive from battle round 2."),
                String(localized: "Reserves must arrive by end of battle round 3 or are destroyed.")
            ]
        case .endOfTurn:
            [
                String(localized: "Score bonus objectives and any end-of-turn mission points."),
                String(
                    localized: """
                    In round 5, the player who went second scores primary points here — not in Command.
                    """
                )
            ]
        case .shooting, .charge, .combat, .anyCombat:
            wh40k10eQuickTips(for: phase)
        case .deployment, .enemyMovement, .endOfAnyTurn, .assault, .scoring, .hero:
            []
        }
    }

    private static func wh40k11eQuickTips(for phase: BattleTurnPhase) -> [String] {
        switch phase {
        case .command:
            [
                String(localized: "Both players gain 1 Core Command Point at the start of the Command phase."),
                String(
                    localized: """
                    The active player tests Battle-shock for units at or below Half-strength and units already Battle-shocked.
                    """
                )
            ]
        case .movement:
            [
                String(localized: "Move up to the unit's Move characteristic — units must end in coherency."),
                String(localized: "Fall Back blocks shooting and charging this turn; Battle-shocked units may use Desperate Escape."),
                String(localized: "Overwatch happens at the end of the Movement phase — not during Charges.")
            ]
        case .shooting:
            [
                String(localized: "Cover imposes -1 Ballistic Skill when every target model has cover."),
                String(localized: "Indirect Fire needs 6+ to hit unless your unit stayed still and a friendly unit can see the target (4+).")
            ]
        case .charge:
            [
                String(localized: "Roll 2D6 first, then pick enemy unit(s) within 12 inches you can reach."),
                String(localized: "Engagement range is 2 inches horizontally and 5 inches vertically — a failed charge leaves the unit in place.")
            ]
        case .combat, .anyCombat:
            [
                String(localized: "All pile-ins resolve before any fights — you pick the first unit to fight."),
                String(localized: "After fights, consolidate up to 3 inches — Ongoing, Engaging, or Objective mode.")
            ]
        case .endOfTurn:
            [
                String(localized: "Remove models from out-of-coherency units until coherency is restored."),
                String(localized: "Track secondary VP scored this turn, then pass the device.")
            ]
        case .deployment, .enemyMovement, .endOfAnyTurn, .assault, .scoring, .hero:
            []
        }
    }

    private static func wh40k10eQuickTips(for phase: BattleTurnPhase) -> [String] {
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
                String(localized: "Resolve hit, wound, save, and damage using each unit's details in the app.")
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
        case .movement:
            [
                String(localized: "Activate one unit at a time — move up to its Move value, then tap Done."),
                String(localized: "Watch supply — you cannot deploy units that exceed your cap.")
            ]
        case .assault:
            [
                String(localized: "Fire ranged attacks with the active unit, then tap Done or Pass."),
                String(localized: "Units that moved usually cannot shoot unless a rule says otherwise.")
            ]
        case .combat:
            [
                String(localized: "Resolve melee attacks for the active unit — pick targets in range."),
                String(localized: "After combat, check if the unit can consolidate toward objectives.")
            ]
        case .scoring:
            [
                String(localized: "Add VP for Supply tokens near objective markers."),
                String(localized: "When scoring finishes, the next round begins with a new initiative roll.")
            ]
        case .deployment:
            [
                String(localized: "Place all three Supply objectives before deploying units."),
                String(localized: "Reserves arrive from the board edge — track which units started off the table.")
            ]
        default:
            []
        }
    }

    private static func spearheadPhaseActionNudge(for phase: BattleTurnPhase) -> String? {
        switch phase {
        case .hero:
            String(localized: "Hero phase — use abilities and spells, then tap Next when ready.")
        case .movement:
            String(localized: "Movement phase — move models up to their Move value. No dice yet.")
        case .shooting:
            String(localized: "Shooting phase — pick a target in range, then roll hit rolls at the table.")
        case .charge:
            String(localized: "Charge phase — pick a target within 12\", then roll 2D6 for charge distance.")
        case .combat, .anyCombat:
            String(localized: "Fight phase — roll hit rolls for attacking units, then wounds and saves.")
        case .endOfTurn:
            String(localized: "End phase — score objectives and battle tactics, then pass the phone.")
        case .deployment:
            String(localized: "Deployment — place terrain and objectives before any models.")
        default:
            nil
        }
    }

    private static func wh40k11ePhaseActionNudge(for phase: BattleTurnPhase) -> String? {
        switch phase {
        case .command:
            String(localized: "Command phase — gain CP, test Battle-shock, then use stratagems. No movement yet.")
        case .movement:
            String(localized: "Movement phase — move models. Roll nothing until Shooting unless you Advance.")
        case .shooting:
            String(localized: "Shooting phase — roll hit rolls for each shooting unit at the table.")
        case .charge:
            String(localized: "Charge phase — roll 2D6 first, then pick an enemy unit within 12\" you can reach.")
        case .combat, .anyCombat:
            String(localized: "Fight phase — resolve all pile-ins, then roll hit rolls for fighting units.")
        case .endOfTurn:
            String(localized: "End phase — score victory points, then pass the phone.")
        case .deployment:
            String(localized: "Deployment — set up terrain and objectives before placing models.")
        default:
            nil
        }
    }

    private static func combatPatrolPhaseActionNudge(for phase: BattleTurnPhase) -> String? {
        switch phase {
        case .command:
            String(localized: "Command phase — score objectives with troops on the board, then use abilities.")
        case .movement:
            String(localized: "Movement phase — move models up to their Move value. No dice yet.")
        case .shooting:
            String(localized: "Shooting phase — roll hit rolls at the table for each shooting unit.")
        case .charge:
            String(localized: "Charge phase — declare targets, then roll 2D6 for charge distance.")
        case .combat, .anyCombat:
            String(localized: "Fight phase — roll hit rolls for units in engagement range.")
        case .endOfTurn:
            String(localized: "End phase — score mission points, then pass the phone.")
        case .deployment:
            String(localized: "Deployment — place mission terrain and objectives first.")
        default:
            nil
        }
    }

    private static func starCraftPhaseActionNudge(for phase: BattleTurnPhase) -> String? {
        switch phase {
        case .movement:
            String(localized: "Movement phase — activate one unit, move it, then tap Done.")
        case .assault:
            String(localized: "Assault phase — fire ranged attacks, then tap Done or Pass.")
        case .combat:
            String(localized: "Combat phase — resolve melee attacks for the active unit.")
        case .scoring:
            String(localized: "Scoring phase — add VP for Supply near objectives, then start the next round.")
        case .deployment:
            String(localized: "Deployment — place objectives before deploying units.")
        default:
            nil
        }
    }

    /// Bundled rules section id for deep-linking from the battle tracker phase picker.
    public static func ruleSectionId(
        for phase: BattleTurnPhase,
        gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    ) -> String? {
        let context = GameSystemPlayContext.context(for: gameSystemId)
        if context.capabilities.deploymentChecklistStyle == .wh40k {
            return wh40k11eRuleSectionId(for: phase)
        }
        if context.capabilities.usesPatrolFormatRules {
            return combatPatrolRuleSectionId(for: phase)
        }
        if context.capabilities.showsActivationBar {
            return starCraftRuleSectionId(for: phase)
        }
        return spearheadRuleSectionId(for: phase)
    }

    private static func spearheadRuleSectionId(for phase: BattleTurnPhase) -> String? {
        switch phase {
        case .hero: "spearhead-battle-round"
        case .movement: "movement-phase"
        case .shooting: "combat-sequence"
        case .charge: "charge-phase"
        case .combat, .anyCombat: "combat-phase-fight"
        case .endOfTurn: "spearhead-scoring"
        case .deployment: "spearhead-deployment"
        default: nil
        }
    }

    private static func wh40k11eRuleSectionId(for phase: BattleTurnPhase) -> String? {
        switch phase {
        case .command: "11e-command-phase"
        case .movement: "11e-movement"
        case .shooting: "11e-shooting"
        case .charge, .combat, .anyCombat: "11e-charge-fight"
        case .endOfTurn: "11e-scoring-overview"
        case .deployment: "11e-terrain-objectives"
        default: nil
        }
    }

    private static func combatPatrolRuleSectionId(for phase: BattleTurnPhase) -> String? {
        switch phase {
        case .command: "10e-turn-overview"
        case .movement: "cp-reserves"
        case .shooting, .charge, .combat, .anyCombat: "combat-sequence"
        case .endOfTurn: "cp-scoring"
        case .deployment: "cp-pre-battle"
        default: nil
        }
    }

    private static func starCraftRuleSectionId(for phase: BattleTurnPhase) -> String? {
        switch phase {
        case .movement, .assault, .combat: "sc-combat"
        case .scoring: "sc-scoring"
        case .deployment: "sc-reserves"
        default: "sc-turn-overview"
        }
    }
}
