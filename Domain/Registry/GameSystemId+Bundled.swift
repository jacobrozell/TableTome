import Foundation

extension GameSystemId {
    /// Registry wiring for this mode — add new cases in `GameSystemId` and here.
    var bundledDescriptor: GameSystemDescriptor {
        switch self {
        case .aosSpearhead:
            GameSystemDescriptor(
                id: .aosSpearhead,
                publisher: "gw",
                playEngine: .phasedRound(
                    PhasedRoundEngineConfig(
                        battleRoundCount: 4,
                        mainPhases: BattleTurnPhase.mainTurnPhases,
                        initialPhase: .deployment,
                        turnStartPhase: .hero,
                        usesBattleRoundLabel: false
                    )
                ),
                capabilities: PlayCapabilities(
                    showsGuidedMatch: true,
                    showsCombatResolver: true,
                    showsVictoryPoints: true,
                    showsDeploymentChecklist: true,
                    showsRoundChecklist: true,
                    showsBattleTacticDecks: true,
                    deploymentChecklistStyle: .spearhead,
                    scoringRuleSectionId: "spearhead-scoring",
                    ruleCategories: [.core, .spearhead, .glossary]
                ),
                copy: GameSystemCopy(
                    shortLabel: String(localized: "AoS"),
                    rulesTitle: String(localized: "AoS Rules"),
                    glossaryTitle: String(localized: "AoS Glossary"),
                    searchPrompt: String(localized: "AoS rules, units, topics…"),
                    rulesSearchPrompt: String(localized: "Search AoS rules"),
                    browseIntro: String(
                        localized: """
                        Search Age of Sigmar Spearhead rules, glossary terms, unit profiles, setup steps, and phase tips.
                        """
                    ),
                    gameGuideBrowseTitle: String(localized: "Spearhead Guide"),
                    searchEmptyStateHint: String(
                        localized: "No matches — try fewer words, like “movement phase” or “victory points”."
                    ),
                    displayName: String(localized: "Age of Sigmar Spearhead"),
                    searchPickerLabel: String(localized: "Age of Sigmar: Spearhead"),
                    catalogLoadFailureMessage: String(localized: "Spearhead armies could not be loaded.")
                ),
                victoryPointsScoring: .spearheadDefault,
                catalogBundleName: "spearhead-catalog-v1",
                armyDetailsSubdirectories: ["Spearhead/armies", "Rules/Spearhead/armies"]
            )

        case .wh40k11e:
            GameSystemDescriptor(
                id: .wh40k11e,
                publisher: "gw",
                playEngine: .phasedRound(
                    PhasedRoundEngineConfig(
                        battleRoundCount: 5,
                        mainPhases: [
                            .deployment, .command, .movement, .shooting, .charge, .combat, .endOfTurn
                        ],
                        initialPhase: .command,
                        turnStartPhase: .command
                    )
                ),
                capabilities: PlayCapabilities(
                    showsGuidedMatch: true,
                    showsCombatResolver: true,
                    showsVictoryPoints: true,
                    showsDedicatedCombatTab: false,
                    combatRollEngineKind: .wh40k11e,
                    deploymentChecklistStyle: .wh40k,
                    ruleCategories: [.core, .glossary],
                    showsNewEditionBadge: true
                ),
                copy: GameSystemCopy(
                    shortLabel: String(localized: "40k"),
                    rulesTitle: String(localized: "40k Rules"),
                    glossaryTitle: String(localized: "40k Glossary"),
                    searchPrompt: String(localized: "40k rules, units, topics…"),
                    rulesSearchPrompt: String(localized: "Search 40k rules"),
                    browseIntro: String(
                        localized: """
                        Search Warhammer 40,000 11th Edition rules, glossary terms, and guide topics.
                        """
                    ),
                    gameGuideBrowseTitle: String(localized: "40k Guide"),
                    searchEmptyStateHint: String(
                        localized: "No matches — try fewer words or a term like \"objective control\" or \"AP\"."
                    ),
                    displayName: String(localized: "Warhammer 40,000"),
                    searchPickerLabel: String(localized: "Warhammer 40,000: 11th Edition"),
                    catalogLoadFailureMessage: String(localized: "40k armies could not be loaded.")
                ),
                victoryPointsScoring: .wh40k11e,
                catalogBundleName: "wh40k-catalog-v1",
                armyDetailsSubdirectories: ["Wh40k/armies", "Rules/Wh40k/armies"]
            )

        case .wh40k10eCp:
            GameSystemDescriptor(
                id: .wh40k10eCp,
                publisher: "gw",
                playEngine: .phasedRound(
                    PhasedRoundEngineConfig(
                        battleRoundCount: 5,
                        mainPhases: [
                            .command, .movement, .shooting, .charge, .combat, .endOfTurn
                        ],
                        initialPhase: .command,
                        turnStartPhase: .command
                    )
                ),
                capabilities: PlayCapabilities(
                    showsGuidedMatch: true,
                    showsCombatResolver: true,
                    showsVictoryPoints: true,
                    combatRollEngineKind: .wh40k10eCombatPatrol,
                    scoringRuleSectionId: "cp-scoring",
                    ruleCategories: [.core, .combatPatrol, .glossary]
                ),
                copy: GameSystemCopy(
                    shortLabel: String(localized: "CP"),
                    rulesTitle: String(localized: "Combat Patrol Rules"),
                    glossaryTitle: String(localized: "Combat Patrol Glossary"),
                    searchPrompt: String(localized: "Combat Patrol rules, missions, topics…"),
                    rulesSearchPrompt: String(localized: "Search Combat Patrol rules"),
                    browseIntro: String(
                        localized: """
                        Search Combat Patrol rules and missions. This mode uses 10th Edition patrol rules — not 11th Edition.
                        """
                    ),
                    gameGuideBrowseTitle: String(localized: "Combat Patrol Guide"),
                    searchEmptyStateHint: String(
                        localized: "No matches — try fewer words or a term like “secure” or “reserves”."
                    ),
                    displayName: String(localized: "Warhammer 40,000: Combat Patrol"),
                    searchPickerLabel: String(localized: "Combat Patrol (10th Edition rules)"),
                    catalogLoadFailureMessage: String(localized: "Combat Patrol armies could not be loaded.")
                ),
                victoryPointsScoring: .combatPatrol,
                catalogBundleName: "combat-patrol-catalog-v1",
                armyDetailsSubdirectories: ["CombatPatrol/armies", "Rules/CombatPatrol/armies"]
            )

        case .scTmg:
            GameSystemDescriptor(
                id: .scTmg,
                publisher: "amg",
                playEngine: .alternatingActivation(
                    AlternatingActivationEngineConfig(
                        battleRoundCount: 5,
                        mainPhases: [.movement, .assault, .combat, .scoring],
                        initialPhase: .movement
                    )
                ),
                capabilities: PlayCapabilities(
                    showsGuidedMatch: true,
                    showsVictoryPoints: true,
                    showsActivationBar: true,
                    showsSupplyPool: true,
                    deploymentChecklistStyle: .scTmg,
                    scoringRuleSectionId: "sc-scoring",
                    ruleCategories: [.core, .glossary],
                    requiresFullSurfaceFlag: true
                ),
                copy: GameSystemCopy(
                    shortLabel: String(localized: "SC"),
                    rulesTitle: String(localized: "StarCraft Rules"),
                    glossaryTitle: String(localized: "StarCraft Glossary"),
                    searchPrompt: String(localized: "StarCraft rules, units, topics…"),
                    rulesSearchPrompt: String(localized: "Search StarCraft rules"),
                    browseIntro: String(
                        localized: """
                        Search StarCraft tabletop rules, glossary terms, activations, and guide topics.
                        """
                    ),
                    gameGuideBrowseTitle: String(localized: "StarCraft Guide"),
                    searchEmptyStateHint: String(
                        localized: "No matches — try fewer words or a term like “supply” or “activation”."
                    ),
                    displayName: String(localized: "StarCraft: Tabletop Miniatures Game"),
                    searchPickerLabel: String(localized: "StarCraft: Tabletop Miniatures Game"),
                    catalogLoadFailureMessage: String(localized: "StarCraft armies could not be loaded.")
                ),
                victoryPointsScoring: .scTmg,
                catalogBundleName: "sc-tmg-catalog-v1",
                armyDetailsSubdirectories: ["ScTmg/armies", "Rules/ScTmg/armies"]
            )
        }
    }
}
