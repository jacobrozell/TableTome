import Foundation

// swiftlint:disable file_length type_body_length function_body_length cyclomatic_complexity

public enum AppSearchResultKind: String, Sendable, CaseIterable {
    case ruleSection
    case glossary
    case gettingStarted
    case editionMigration
    case matchSetup
    case deployment
    case battleTactics
    case cardDeck
    case warscroll
    case armyRule
    case phaseTip
    case appFeature

    public func sectionLabel(gameSystemId: GameSystemId) -> String {
        sectionLabel(gameSystemId: gameSystemId.rawValue)
    }

    public func sectionLabel(gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId) -> String {
        let playContext = GameSystemPlayContext.context(for: gameSystemId)
        switch self {
        case .ruleSection:
            return GameSystemRulesLabels.searchResultRulesSectionTitle(gameSystemId: gameSystemId)
        case .glossary:
            return GameSystemRulesLabels.glossaryTitle(gameSystemId: gameSystemId)
        case .gettingStarted:
            return String(localized: "Getting Started")
        case .editionMigration:
            if playContext.isStarCraft {
                return String(localized: "RTS → Tabletop")
            }
            return String(localized: "What's New in 11e")
        case .matchSetup:
            return String(localized: "Match Setup")
        case .deployment:
            if playContext.capabilities.showsActivationBar {
                return String(localized: "Battlefield Setup")
            } else {
                return String(localized: "Deployment")
            }
        case .battleTactics:
            return String(localized: "Card Decks")
        case .cardDeck:
            return String(localized: "Decks")
        case .warscroll:
            if playContext.usesGuidedBattleTracker {
                return String(localized: "Units")
            } else {
                return String(localized: "Warscrolls")
            }
        case .armyRule:
            return String(localized: "Army Rules")
        case .phaseTip:
            return String(localized: "Phase Tips")
        case .appFeature:
            return String(localized: "Features & Armies")
        }
    }

    public static func visibleKinds(for gameSystemId: GameSystemId) -> [AppSearchResultKind] {
        visibleKinds(for: gameSystemId.rawValue)
    }

    public static func visibleKinds(for gameSystemId: String) -> [AppSearchResultKind] {
        let capabilities = GameSystemPlayContext.context(for: gameSystemId).capabilities
        var kinds: [AppSearchResultKind] = [
            .ruleSection, .glossary, .gettingStarted, .editionMigration, .matchSetup, .deployment,
            .warscroll, .armyRule, .phaseTip, .appFeature
        ]
        if capabilities.showsBattleTacticDecks {
            kinds.insert(contentsOf: [.battleTactics, .cardDeck], at: 5)
        }
        return kinds
    }
}

public struct AppSearchResult: Identifiable, Sendable, Equatable {
    public let id: String
    public let kind: AppSearchResultKind
    public let title: String
    public let subtitle: String
    public let snippet: String
    public let detailBody: String
    public let referenceId: String
    public let secondaryReferenceId: String?

    public init(
        id: String,
        kind: AppSearchResultKind,
        title: String,
        subtitle: String,
        snippet: String,
        detailBody: String,
        referenceId: String,
        secondaryReferenceId: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.snippet = snippet
        self.detailBody = detailBody
        self.referenceId = referenceId
        self.secondaryReferenceId = secondaryReferenceId
    }
}

struct AppSearchIndexItem: Sendable {
    let id: String
    let kind: AppSearchResultKind
    let title: String
    let subtitle: String
    let detailBody: String
    let referenceId: String
    let secondaryReferenceId: String?
    let searchableText: String

    func result(snippet: String) -> AppSearchResult {
        AppSearchResult(
            id: id,
            kind: kind,
            title: title,
            subtitle: subtitle,
            snippet: snippet,
            detailBody: detailBody,
            referenceId: referenceId,
            secondaryReferenceId: secondaryReferenceId
        )
    }
}

public enum AppSearchIndexBuilder {
    public static func build(gameSystem: GameSystem, catalog: SpearheadCatalog?) -> [AppSearchResult] {
        let gameSystemId = gameSystem.id
        var items: [AppSearchIndexItem] = []
        items.append(contentsOf: ruleSectionItems(from: gameSystem.ruleSections))
        items.append(contentsOf: glossaryItems(gameSystemId: gameSystemId, ruleSections: gameSystem.ruleSections))
        items.append(contentsOf: guideStepItems(
            from: gameSystem.gettingStartedSteps,
            kind: .gettingStarted,
            subtitle: String(localized: "Getting Started")
        ))
        items.append(contentsOf: guideStepItems(
            from: gameSystem.editionMigrationSteps,
            kind: .editionMigration,
            subtitle: editionMigrationSubtitle(for: gameSystemId)
        ))
        if let catalog {
            items.append(contentsOf: matchSetupItems(from: catalog.matchSteps))
            items.append(contentsOf: armyItems(from: catalog, gameSystemId: gameSystemId))
            let capabilities = GameSystemPlayContext.context(for: gameSystemId).capabilities
            if capabilities.showsCombatPatrolMode {
                items.append(contentsOf: combatPatrolMissionItems(from: catalog.missions))
            }
        }
        items.append(contentsOf: deploymentItems(gameSystemId: gameSystemId))
        if GameSystemPlayContext.context(for: gameSystemId).capabilities.showsBattleTacticDecks {
            items.append(contentsOf: battleTacticsItems())
        }
        items.append(contentsOf: phaseTipItems(gameSystemId: gameSystemId))
        items.append(contentsOf: appFeatureItems(gameSystemId: gameSystemId))

        return items.map { item in
            item.result(snippet: AppSearchEngine.makeSnippet(from: item.detailBody))
        }
    }

    private static func ruleSectionItems(from sections: [RuleSection]) -> [AppSearchIndexItem] {
        sections.map { section in
            AppSearchIndexItem(
                id: "rule:\(section.id)",
                kind: .ruleSection,
                title: section.title,
                subtitle: ruleSectionSubtitle(section.category),
                detailBody: section.content,
                referenceId: section.id,
                secondaryReferenceId: nil,
                searchableText: joined([section.title, section.content])
            )
        }
    }

    private static func glossaryItems(
        gameSystemId: String,
        ruleSections: [RuleSection]
    ) -> [AppSearchIndexItem] {
        let capabilities = GameSystemPlayContext.context(for: gameSystemId).capabilities
        if capabilities.showsBattleTacticDecks {
            return SpearheadRulesGlossary.entries.map { glossaryEntryItem($0) }
        }
        if capabilities.showsCombatPatrolMode {
            return CombatPatrolRulesGlossary.entries.map { glossaryEntryItem($0) }
        }
        return ruleSections
            .filter { $0.category == .glossary }
            .map { glossarySectionItem($0) }
    }

    private static func glossaryEntryItem(_ entry: RulesGlossaryEntry) -> AppSearchIndexItem {
        AppSearchIndexItem(
            id: "glossary:\(entry.id)",
            kind: .glossary,
            title: entry.term,
            subtitle: String(localized: "Glossary"),
            detailBody: entry.definition,
            referenceId: entry.id,
            secondaryReferenceId: nil,
            searchableText: joined([entry.term, entry.definition] + glossaryAliases(for: entry.id))
        )
    }

    private static func glossarySectionItem(_ section: RuleSection) -> AppSearchIndexItem {
        AppSearchIndexItem(
            id: "glossary:\(section.id)",
            kind: .glossary,
            title: section.title,
            subtitle: String(localized: "Glossary"),
            detailBody: section.content,
            referenceId: section.id,
            secondaryReferenceId: nil,
            searchableText: joined([section.title, section.content])
        )
    }

    private static func editionMigrationSubtitle(for gameSystemId: String) -> String {
        GameSystemPlayContext.context(for: gameSystemId).isStarCraft
            ? String(localized: "RTS → Tabletop")
            : String(localized: "What's New in 11e")
    }

    private static func guideStepItems(
        from steps: [GuideStep],
        kind: AppSearchResultKind,
        subtitle: String
    ) -> [AppSearchIndexItem] {
        steps.map { step in
            AppSearchIndexItem(
                id: "\(kind.rawValue):\(step.id)",
                kind: kind,
                title: step.title,
                subtitle: subtitle,
                detailBody: joined([step.summary, step.body] + step.tips),
                referenceId: step.id,
                secondaryReferenceId: nil,
                searchableText: joined([step.title, step.summary, step.body] + step.tips)
            )
        }
    }

    private static func matchSetupItems(from steps: [MatchSetupStep]) -> [AppSearchIndexItem] {
        steps.map { step in
            AppSearchIndexItem(
                id: "match:\(step.id)",
                kind: .matchSetup,
                title: step.title,
                subtitle: String(localized: "Match Setup"),
                detailBody: joined([step.summary, step.body] + step.tips),
                referenceId: step.id,
                secondaryReferenceId: nil,
                searchableText: joined([step.title, step.summary, step.body] + step.tips)
            )
        }
    }

    private static func deploymentItems(gameSystemId: String) -> [AppSearchIndexItem] {
        switch gameSystemId {
        case "aos-spearhead":
            return spearheadDeploymentItems()
        case "wh40k-11e":
            return checklistDeploymentItems(
                prefix: "wh40kDeployment",
                subtitle: String(localized: "Deployment"),
                steps: Wh40kDeploymentChecklistStep.allCases.map { ($0.id, $0.title, $0.detail) }
            )
        case "wh40k-10e-cp":
            return checklistDeploymentItems(
                prefix: "cpDeployment",
                subtitle: String(localized: "Deployment"),
                steps: CombatPatrolDeploymentChecklistStep.allCases.map { ($0.id, $0.title, $0.detail) }
            )
        case "sc-tmg":
            return checklistDeploymentItems(
                prefix: "scDeployment",
                subtitle: String(localized: "Battlefield Setup"),
                steps: ScTmgDeploymentChecklistStep.allCases.map { ($0.id, $0.title, $0.detail) }
            )
        default:
            return []
        }
    }

    private static func spearheadDeploymentItems() -> [AppSearchIndexItem] {
        var items = [
            AppSearchIndexItem(
                id: "deployment:overview",
                kind: .deployment,
                title: String(localized: "Deployment overview"),
                subtitle: String(localized: "Battle Tracker"),
                detailBody: DeploymentChecklist.overview,
                referenceId: "overview",
                secondaryReferenceId: nil,
                searchableText: joined([
                    String(localized: "Deployment"),
                    DeploymentChecklist.overview
                ])
            )
        ]
        items.append(contentsOf: DeploymentChecklistStep.allCases.map { step in
            AppSearchIndexItem(
                id: "deployment:\(step.id)",
                kind: .deployment,
                title: step.title,
                subtitle: String(localized: "Deployment"),
                detailBody: step.detail,
                referenceId: step.id,
                secondaryReferenceId: nil,
                searchableText: joined([step.title, step.detail])
            )
        })
        return items
    }

    private static func checklistDeploymentItems(
        prefix: String,
        subtitle: String,
        steps: [(id: String, title: String, detail: String)]
    ) -> [AppSearchIndexItem] {
        steps.map { step in
            AppSearchIndexItem(
                id: "\(prefix):\(step.id)",
                kind: .deployment,
                title: step.title,
                subtitle: subtitle,
                detailBody: step.detail,
                referenceId: step.id,
                secondaryReferenceId: nil,
                searchableText: joined([step.title, step.detail])
            )
        }
    }

    private static func combatPatrolMissionItems(from missions: [CombatPatrolMission]) -> [AppSearchIndexItem] {
        missions.map { mission in
            AppSearchIndexItem(
                id: "mission:\(mission.id)",
                kind: .matchSetup,
                title: mission.name,
                subtitle: String(localized: "Mission"),
                detailBody: joined([mission.missionRuleSummary, mission.primaryObjectiveSummary, mission.scoringNotes]),
                referenceId: mission.id,
                secondaryReferenceId: nil,
                searchableText: joined([
                    mission.name,
                    mission.missionRuleSummary,
                    mission.primaryObjectiveSummary,
                    mission.scoringNotes
                ])
            )
        }
    }

    private static func battleTacticsItems() -> [AppSearchIndexItem] {
        var items = SpearheadBattleTacticsReference.sections.map { section in
            AppSearchIndexItem(
                id: "battleTactics:\(section.id)",
                kind: .battleTactics,
                title: section.title,
                subtitle: String(localized: "Card Decks Guide"),
                detailBody: joined([section.body] + section.bullets + section.examples),
                referenceId: section.id,
                secondaryReferenceId: nil,
                searchableText: joined([section.title, section.body] + section.bullets + section.examples)
            )
        }
        items.append(contentsOf: SpearheadBattleTacticsReference.deckGuides.map { deck in
            AppSearchIndexItem(
                id: "cardDeck:\(deck.id)",
                kind: .cardDeck,
                title: deck.name,
                subtitle: String(localized: "Card Deck"),
                detailBody: joined([deck.comesFrom, deck.whoUsesIt, deck.whenUsed, deck.lookFor]),
                referenceId: deck.id,
                secondaryReferenceId: nil,
                searchableText: joined([deck.name, deck.comesFrom, deck.whoUsesIt, deck.whenUsed, deck.lookFor])
            )
        })
        return items
    }

    private static func phaseTipItems(gameSystemId: String) -> [AppSearchIndexItem] {
        GameSystemPlayContext.context(for: gameSystemId).playEngine.mainPhases().compactMap { phase in
            let tips = PhaseContextCoach.quickTips(for: phase, gameSystemId: gameSystemId)
            guard !tips.isEmpty else { return nil }
            return AppSearchIndexItem(
                id: "phase:\(phase.id)",
                kind: .phaseTip,
                title: phase.title,
                subtitle: String(localized: "Phase Tips"),
                detailBody: tips.joined(separator: "\n\n"),
                referenceId: phase.id,
                secondaryReferenceId: nil,
                searchableText: joined([phase.title] + tips)
            )
        }
    }

    private static func armyItems(from catalog: SpearheadCatalog, gameSystemId: String) -> [AppSearchIndexItem] {
        catalog.factions.flatMap(\.armies).flatMap { army in
            var items = [
                AppSearchIndexItem(
                    id: "army:\(army.id)",
                    kind: .appFeature,
                    title: army.name,
                    subtitle: String(localized: "Starter Army"),
                    detailBody: joined([army.tagline, army.playstyle, army.general] + army.roster),
                    referenceId: army.id,
                    secondaryReferenceId: nil,
                    searchableText: joined([army.name, army.tagline, army.playstyle, army.general] + army.roster)
                )
            ]
            items.append(contentsOf: (army.battleTraits + army.regimentAbilities + army.enhancements).map {
                armyRuleItem($0, army: army)
            })
            if gameSystemId == "wh40k-10e-cp" {
                items.append(contentsOf: army.secondaryObjectives.map { secondaryObjectiveItem($0, army: army) })
                items.append(contentsOf: army.stratagems.map { stratagemItem($0, army: army) })
            }
            items.append(contentsOf: army.units.map { unitItem($0, army: army, gameSystemId: gameSystemId) })
            return items
        }
    }

    private static func armyRuleItem(_ rule: ArmyRuleOption, army: SpearheadArmy) -> AppSearchIndexItem {
        AppSearchIndexItem(
            id: "armyRule:\(army.id):\(rule.id)",
            kind: .armyRule,
            title: rule.name,
            subtitle: "\(army.name) · \(String(localized: "Army Rule"))",
            detailBody: joined([rule.summary, rule.newPlayerHint, rule.timing, rule.declare, rule.effect, rule.flavor]),
            referenceId: rule.id,
            secondaryReferenceId: army.id,
            searchableText: joined([rule.name, rule.summary, rule.newPlayerHint, rule.timing, rule.declare, rule.effect, army.name])
        )
    }

    private static func secondaryObjectiveItem(_ objective: ArmyRuleOption, army: SpearheadArmy) -> AppSearchIndexItem {
        AppSearchIndexItem(
            id: "secondary:\(army.id):\(objective.id)",
            kind: .armyRule,
            title: objective.name,
            subtitle: "\(army.name) · \(String(localized: "Secondary Objective"))",
            detailBody: joined([objective.summary, objective.newPlayerHint, objective.timing]),
            referenceId: objective.id,
            secondaryReferenceId: army.id,
            searchableText: joined([objective.name, objective.summary, objective.newPlayerHint, objective.timing, army.name, "secondary"])
        )
    }

    private static func stratagemItem(_ stratagem: CombatPatrolStratagem, army: SpearheadArmy) -> AppSearchIndexItem {
        AppSearchIndexItem(
            id: "stratagem:\(army.id):\(stratagem.id)",
            kind: .armyRule,
            title: stratagem.name,
            subtitle: "\(army.name) · \(String(localized: "Stratagem"))",
            detailBody: joined([
                stratagem.summary,
                stratagem.phase,
                stratagem.isReactive == true ? String(localized: "Reactive") : nil,
                "\(stratagem.cpCost)CP"
            ]),
            referenceId: stratagem.id,
            secondaryReferenceId: army.id,
            searchableText: joined([
                stratagem.name,
                stratagem.summary,
                stratagem.phase,
                army.name,
                "stratagem",
                "CP"
            ])
        )
    }

    private static func unitItem(
        _ unit: SpearheadUnit,
        army: SpearheadArmy,
        gameSystemId: String
    ) -> AppSearchIndexItem {
        let weaponLines = unit.weapons.map { weapon in
            var parts = [weapon.name, weapon.attacks, weapon.ability]
            if let range = weapon.rangeInches {
                parts.insert("\(range)\"", at: 1)
            }
            return parts.compactMap { $0 }.joined(separator: " · ")
        }
        let abilityLines = unit.abilities.map { joined([$0.name, $0.effect, $0.declare]) }
        let statLine = [
            unit.move.map { "Move \($0)" },
            unit.save.map { "Save \($0)+" },
            unit.health.map { "Health \($0)" },
            unit.control.map { "Control \($0)" }
        ].compactMap { $0 }

        let detailBody = joined(
            [statLine.joined(separator: " · "), unit.notes] + weaponLines + abilityLines
        )

        let playContext = GameSystemPlayContext.context(for: gameSystemId)
        let unitKindLabel = playContext.usesGuidedBattleTracker
            ? String(localized: "Unit")
            : String(localized: "Warscroll")

        return AppSearchIndexItem(
            id: "unit:\(army.id):\(unit.id)",
            kind: .warscroll,
            title: unit.name,
            subtitle: "\(army.name) · \(unitKindLabel)",
            detailBody: detailBody,
            referenceId: unit.id,
            secondaryReferenceId: army.id,
            searchableText: joined(
                [unit.name, army.name, unit.notes] + unit.keywords + weaponLines + abilityLines + statLine
            )
        )
    }

    private static func appFeatureItems(gameSystemId: String) -> [AppSearchIndexItem] {
        guard showsGuidedMatchSearchFeature(for: gameSystemId) else { return [] }

        var items: [AppSearchIndexItem] = [
            AppSearchIndexItem(
                id: "feature:guidedMatch",
                kind: .appFeature,
                title: String(localized: "Guided Match"),
                subtitle: String(localized: "App Feature"),
                detailBody: guidedMatchFeatureBody(gameSystemId: gameSystemId),
                referenceId: "guidedMatch",
                secondaryReferenceId: nil,
                searchableText: joined([
                    String(localized: "Guided Match"),
                    String(localized: "battle tracker"),
                    String(localized: "sync"),
                    String(localized: "setup")
                ])
            )
        ]

        if showsCombatResolverSearchFeature(for: gameSystemId) {
            items.append(
                AppSearchIndexItem(
                    id: "feature:combatResolver",
                    kind: .appFeature,
                    title: String(localized: "Combat Resolver"),
                    subtitle: String(localized: "App Feature"),
                    detailBody: String(
                        localized: """
                        Step-by-step hit, wound, and save math for practice rolls or resolving attacks at the table.
                        """
                    ),
                    referenceId: "combatResolver",
                    secondaryReferenceId: nil,
                    searchableText: joined([
                        String(localized: "Combat Resolver"),
                        String(localized: "dice"),
                        String(localized: "hits"),
                        String(localized: "wounds"),
                        String(localized: "saves")
                    ])
                )
            )
        }

        return items
    }

    private static func guidedMatchFeatureBody(gameSystemId: String) -> String {
        let playContext = GameSystemPlayContext.context(for: gameSystemId)
        if playContext.isWh40k11e {
            return String(
                localized: """
                Interactive match setup and battle tracker with Command-phase flow, army health, and optional two-phone sync.
                """
            )
        }
        if playContext.capabilities.showsActivationBar {
            return String(
                localized: """
                Interactive match setup and battle tracker with alternating activations, Supply scoring, and optional sync.
                """
            )
        }
        return String(
            localized: """
            Interactive match setup and battle tracker with phase flow, army health, combat resolver, and optional two-phone sync.
            """
        )
    }

    private static func showsGuidedMatchSearchFeature(for gameSystemId: String) -> Bool {
        GameSystemPlayContext.context(for: gameSystemId).capabilities.showsGuidedMatch
    }

    private static func showsCombatResolverSearchFeature(for gameSystemId: String) -> Bool {
        GameSystemPlayContext.context(for: gameSystemId).capabilities.showsCombatResolver
    }

    private static func ruleSectionSubtitle(_ category: RuleSectionCategory) -> String {
        switch category {
        case .core: String(localized: "Core Rules")
        case .spearhead: String(localized: "Spearhead Rules")
        case .combatPatrol: String(localized: "Combat Patrol Rules")
        case .glossary: String(localized: "Rules Reference")
        }
    }

    private static let glossaryAliasLookup: [String: [String]] = [
        "wholly-within": ["wholly within"],
        "warscroll": ["warscroll"],
        "regiment-ability": ["regiment ability"],
        "twist-card": ["twist card", "twist deck"],
        "battle-tactic": ["battle tactic"],
        "victory-points": ["victory point", "vp"],
        "priority-roll": ["priority roll"],
        "seizing-initiative": ["seizing initiative", "seize initiative"],
        "pile-in": ["pile in", "pile-in"],
        "run": ["running"],
        "battle-round": ["battle round"],
        "objective": ["objective", "objectives"],
        "coherency": ["coherency", "coherence"],
        "d6": ["d6"],
        "enhancement": ["enhancement"],
        "general": ["general"],
        "spearhead": ["spearhead"],
        "underdog": ["underdog"],
        "mortal-damage": ["mortal damage"],
        "rend": ["rend"],
        "shoot-in-combat": ["shoot in combat"],
        "crit-auto-wound": ["auto-wound", "auto wound", "crit"],
        "variable-attacks": ["variable attacks", "d6 attacks", "2d6 attacks"],
        "ward": ["ward"],
        "visible": ["visible"],
        "contest": ["contest"],
        "combat-range": ["combat range", "in combat"],
        "retreat": ["retreat", "retreating"],
        "charge": ["charge", "charging", "charge roll"],
        "fight": ["fight", "fighting"],
        "strike-first": ["strike-first", "strike first", "strikes first"],
        "strike-last": ["strike-last", "strike last", "strikes last"],
        "critical-hit": ["critical hit", "crit hit"],
        "crit-mortal": ["crit (mortal)", "crit mortal"],
        "damaged": ["damaged"],
        "heal": ["heal", "healing"],
        "reinforcements": ["reinforcements", "call for reinforcements"],
        "rules-of-one": ["rules of one", "one core ability"],
        "objective-control": ["objective control", "control characteristic"],
        "normal-move": ["normal move"]
    ]

    private static func glossaryAliases(for entryId: String) -> [String] {
        glossaryAliasLookup[entryId] ?? []
    }

    private static func joined(_ parts: some Sequence<String?>) -> String {
        parts.compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private static func joined(_ parts: [String]) -> String {
        parts.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private static func joined(_ parts: String...) -> String {
        joined(parts)
    }
}

public enum AppSearchEngine {
    public static func suggestedTopics(for gameSystemId: String) -> [String] {
        switch gameSystemId {
        case "wh40k-11e":
            return [
                "movement phase",
                "shooting phase",
                "objective control",
                "deployment",
                "charge roll",
                "command phase",
                "battle-shock"
            ]
        case "wh40k-10e-cp":
            return [
                "secure objective",
                "command phase",
                "deployment",
                "mission",
                "move and shoot",
                "stratagem",
                "battle ready"
            ]
        case "sc-tmg":
            return [
                "activation",
                "supply",
                "objective",
                "movement",
                "surge",
                "assault"
            ]
        default:
            return [
                "movement phase",
                "shooting phase",
                "victory points",
                "deployment",
                "charge roll",
                "battle rounds",
                "coherency"
            ]
        }
    }

    public static let suggestedTopics = suggestedTopics(for: GameSystemRulesLabels.defaultGameSystemId)

    public static func search(query: String, in index: [AppSearchResult]) -> [AppSearchResult] {
        let tokens = tokenize(query)
        guard !tokens.isEmpty else { return [] }

        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return index.compactMap { result -> (AppSearchResult, Int)? in
            let haystack = joined(result.title, result.subtitle, result.detailBody).lowercased()
            let score = score(haystack: haystack, title: result.title.lowercased(), tokens: tokens, query: normalizedQuery)
            guard score > 0 else { return nil }
            let snippet = makeSnippet(from: result.detailBody, matching: tokens)
            let scored = AppSearchResult(
                id: result.id,
                kind: result.kind,
                title: result.title,
                subtitle: result.subtitle,
                snippet: snippet,
                detailBody: result.detailBody,
                referenceId: result.referenceId,
                secondaryReferenceId: result.secondaryReferenceId
            )
            return (scored, score)
        }
        .sorted { lhs, rhs in
            if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
            return lhs.0.title.localizedCaseInsensitiveCompare(rhs.0.title) == .orderedAscending
        }
        .map(\.0)
    }

    static func tokenize(_ query: String) -> [String] {
        query.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 2 }
    }

    static func makeSnippet(from text: String, matching tokens: [String] = []) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }

        if let matchIndex = tokens.compactMap({ token in
            trimmed.range(of: token, options: .caseInsensitive)?.lowerBound
        }).min(by: { trimmed.distance(from: trimmed.startIndex, to: $0) < trimmed.distance(from: trimmed.startIndex, to: $1) }) {
            let start = trimmed.index(matchIndex, offsetBy: -40, limitedBy: trimmed.startIndex) ?? trimmed.startIndex
            let end = trimmed.index(matchIndex, offsetBy: 100, limitedBy: trimmed.endIndex) ?? trimmed.endIndex
            var snippet = String(trimmed[start..<end]).trimmingCharacters(in: .whitespacesAndNewlines)
            if start > trimmed.startIndex { snippet = "…" + snippet }
            if end < trimmed.endIndex { snippet += "…" }
            return snippet
        }

        if trimmed.count <= 120 { return trimmed }
        let end = trimmed.index(trimmed.startIndex, offsetBy: 117)
        return String(trimmed[..<end]).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }

    private static func score(haystack: String, title: String, tokens: [String], query: String) -> Int {
        var score = 0

        if title.contains(query) { score += 120 }
        if haystack.contains(query) { score += 80 }

        let matchingTokens = tokens.filter { haystack.contains($0) }
        guard !matchingTokens.isEmpty else { return 0 }

        if tokens.allSatisfy({ title.contains($0) }) { score += 60 }
        if tokens.allSatisfy({ haystack.contains($0) }) { score += 40 }
        score += matchingTokens.count * 10

        if resultKindBoost(title: title, haystack: haystack, tokens: tokens) {
            score += 15
        }

        return score
    }

    private static func resultKindBoost(title: String, haystack: String, tokens: [String]) -> Bool {
        tokens.contains { token in
            title == token || title.hasPrefix(token + " ")
        }
    }

    private static func joined(_ parts: String...) -> String {
        parts.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
