import Foundation

public enum CombatPatrolRulesGlossary {
    public static let entries: [RulesGlossaryEntry] = [
        RulesGlossaryEntry(
            id: "secure",
            term: "Secure (Combat Patrol)",
            definition: """
            At the end of your Command phase, if you control an objective and one or more Battleline units \
            (not Battle-shocked) are within range, that objective is secured. While secured, you keep \
            control even without models in range until your opponent controls it at the end of a later Command phase.
            """
        ),
        RulesGlossaryEntry(
            id: "patrol-squads",
            term: "Patrol Squads",
            definition: """
            Some Combat Patrol datasheets let you split one roster entry into smaller units for the battle. \
            Declare splits during battle formations — follow the split rules on the datasheet.
            """
        ),
        RulesGlossaryEntry(
            id: "battle-ready",
            term: "Battle Ready",
            definition: """
            Every model in your army fully painted with a detailed or textured base. In Combat Patrol, \
            a Battle Ready army earns +10 VP at the end of the battle.
            """
        ),
        RulesGlossaryEntry(
            id: "attached-leaders",
            term: "Attached Leaders",
            definition: """
            Leader units can start attached to a Bodyguard unit. Declare which Leader attaches to which unit \
            before deployment. They move and fight as one unit until detached by rules.
            """
        ),
        RulesGlossaryEntry(
            id: "cp-reserves",
            term: "Reserves (Combat Patrol)",
            definition: """
            Reserves cannot arrive in battle round 1. Any unit not on the battlefield by the end of battle \
            round 3 is destroyed, including units embarked in a Transport that has not arrived.
            """
        ),
        RulesGlossaryEntry(
            id: "objective-control-10e",
            term: "Objective Control (OC)",
            definition: """
            Compare the total OC of your models within range of an objective to your opponent's. \
            The side with higher OC controls the marker; ties mean neither side controls it.
            """
        ),
    ]
}
