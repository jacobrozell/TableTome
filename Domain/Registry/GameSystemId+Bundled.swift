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
                featuredArmies: FeaturedArmiesConfig(
                    armyIds: ["vigilant-brotherhood", "gnawfeast-clawpack"],
                    starterMatchupTitle: "Vigilant Brotherhood vs Gnawfeast Clawpack",
                    starterSetDescription: String(
                        localized: "Fill both armies automatically for the Vigilant Brotherhood vs Gnawfeast Clawpack starter matchup — setup and battle tools included."
                    ),
                    starterSetBadge: String(localized: "Age of Sigmar starter box"),
                    playerOne: StarterArmySelection(
                        playerName: "Player 1",
                        factionId: "stormcast-eternals",
                        armyId: "vigilant-brotherhood"
                    ),
                    playerTwo: StarterArmySelection(
                        playerName: "Player 2",
                        factionId: "skaven",
                        armyId: "gnawfeast-clawpack"
                    )
                ),
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
                    showsWh40kDeploymentChecklist: true,
                    showsDedicatedCombatTab: false,
                    usesWh40k11eCombatRollEngine: true,
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
                featuredArmies: FeaturedArmiesConfig(
                    armyIds: ["operation-imperator", "waaagh-armageddon"],
                    starterMatchupTitle: "Operation Imperator vs Waaagh! Armageddon",
                    starterSetDescription: String(
                        localized: "Quick-start the Armageddon launch box with fixed rosters, datasheets, setup, and battle tools."
                    ),
                    starterSetBadge: String(localized: "Warhammer 40,000: Armageddon"),
                    playerOne: StarterArmySelection(
                        playerName: "Player 1",
                        factionId: "space-marines",
                        armyId: "operation-imperator"
                    ),
                    playerTwo: StarterArmySelection(
                        playerName: "Player 2",
                        factionId: "orks",
                        armyId: "waaagh-armageddon"
                    )
                ),
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
                        mainPhases: CombatPatrolBattleRules.mainPhases,
                        initialPhase: CombatPatrolBattleRules.initialPhase,
                        turnStartPhase: CombatPatrolBattleRules.initialPhase
                    )
                ),
                capabilities: PlayCapabilities(
                    showsGuidedMatch: true,
                    showsCombatResolver: true,
                    showsVictoryPoints: true,
                    showsCombatPatrolMode: true,
                    usesWh40k10eCombatRollEngine: true,
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
                featuredArmies: FeaturedArmiesConfig(
                    armyIds: ["space-marines-combat-patrol", "tyranids-combat-patrol"],
                    starterMatchupTitle: "Space Marines vs Tyranids",
                    starterSetDescription: String(
                        localized: "Quick-start the Space Marines vs Tyranids starter matchup — works with any Combat Patrol box."
                    ),
                    starterSetBadge: String(localized: "Combat Patrol starter box"),
                    playerOne: StarterArmySelection(
                        playerName: "Player 1",
                        factionId: "space-marines",
                        armyId: "space-marines-combat-patrol"
                    ),
                    playerTwo: StarterArmySelection(
                        playerName: "Player 2",
                        factionId: "tyranids",
                        armyId: "tyranids-combat-patrol"
                    ),
                    defaultMissionId: "clash-of-patrols"
                ),
                catalogBundleName: "combat-patrol-catalog-v1",
                armyDetailsSubdirectories: ["CombatPatrol/armies", "Rules/CombatPatrol/armies"]
            )

        case .scTmg:
            GameSystemDescriptor(
                id: .scTmg,
                publisher: "amg",
                playEngine: .alternatingActivation(
                    AlternatingActivationEngineConfig(
                        battleRoundCount: ScTmgBattleRules.battleRoundCount,
                        mainPhases: ScTmgBattleRules.mainPhases,
                        initialPhase: ScTmgBattleRules.initialPhase
                    )
                ),
                capabilities: PlayCapabilities(
                    showsGuidedMatch: true,
                    showsVictoryPoints: true,
                    showsActivationBar: true,
                    showsSupplyPool: true,
                    showsScTmgDeploymentChecklist: true,
                    scoringRuleSectionId: "sc-scoring",
                    ruleCategories: [.core, .glossary]
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
                featuredArmies: FeaturedArmiesConfig(
                    armyIds: ["raynors-raiders", "kerrigans-swarm"],
                    starterMatchupTitle: "Raynor's Raiders vs Kerrigan's Swarm",
                    starterSetDescription: String(
                        localized: "Quick-start the 2-Player Founders Edition with guided setup and a supply-aware battle tracker."
                    ),
                    starterSetBadge: String(localized: "2-Player Founders Edition"),
                    playerOne: StarterArmySelection(
                        playerName: "Player 1",
                        factionId: "terran",
                        armyId: "raynors-raiders"
                    ),
                    playerTwo: StarterArmySelection(
                        playerName: "Player 2",
                        factionId: "zerg",
                        armyId: "kerrigans-swarm"
                    )
                ),
                catalogBundleName: "sc-tmg-catalog-v1",
                armyDetailsSubdirectories: ["ScTmg/armies", "Rules/ScTmg/armies"]
            )
        }
    }
}
