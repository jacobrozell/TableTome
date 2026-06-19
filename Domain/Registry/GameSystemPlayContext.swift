import Foundation

/// Resolved play metadata for a game system — prefer this over raw `gameSystemId` switches.
public struct GameSystemPlayContext: Sendable, Equatable {
    public let descriptor: GameSystemDescriptor

    public init(descriptor: GameSystemDescriptor) {
        self.descriptor = descriptor
    }

    public init(gameSystemId: GameSystemId, registry: GameSystemRegistry = .bundled) {
        descriptor = registry.descriptor(for: gameSystemId) ?? Self.fallbackDescriptor(for: gameSystemId)
    }

    public init(gameSystemId: String, registry: GameSystemRegistry = .bundled) {
        self.init(gameSystemId: GameSystemId(resolving: gameSystemId), registry: registry)
    }

    public var gameSystemId: GameSystemId { descriptor.id }
    public var capabilities: PlayCapabilities { descriptor.capabilities }
    public var playEngine: PlayEngineConfig { descriptor.playEngine }
    public var copy: GameSystemCopy { descriptor.copy }
    public var victoryPointsScoring: VictoryPointsScoring { descriptor.victoryPointsScoring }

    public var isSpearhead: Bool { capabilities.showsBattleTacticDecks }
    public var isStarCraft: Bool { capabilities.showsActivationBar }
    public var isCombatPatrol: Bool { capabilities.showsCombatPatrolMode }
    public var isWh40k11e: Bool { capabilities.showsWh40kDeploymentChecklist }
    public var isWh40k: Bool { isWh40k11e || isCombatPatrol }
    public var usesAlternatingActivation: Bool { playEngine.playEngineId == .alternatingActivation }
    public var usesPhasedRounds: Bool { playEngine.playEngineId == .phasedRound }
    public var usesGuidedBattleTracker: Bool { isStarCraft || isWh40k }

    /// Toolbar / sheet title for a single unit's rules reference.
    public var unitRulesDetailTitle: String {
        if isWh40k { return String(localized: "Unit details") }
        if isStarCraft { return String(localized: "Unit card") }
        return String(localized: "Unit rules card")
    }

    /// Link to browse all units in an army roster during setup or battle.
    public var armyUnitRosterLinkTitle: String {
        if isSpearhead { return String(localized: "View unit rules cards") }
        return String(localized: "View unit roster")
    }

    /// Army picker link to unit reference content.
    public var unitReferenceLinkTitle: String {
        if isWh40k { return String(localized: "Units & abilities") }
        if isStarCraft { return String(localized: "Unit cards & abilities") }
        return String(localized: "Unit rules cards & abilities")
    }

    public var unitFocusAccessibilityHint: String {
        if isWh40k { return String(localized: "Opens unit focus with unit details.") }
        if isStarCraft { return String(localized: "Opens unit focus with unit card details.") }
        return String(localized: "Opens unit focus with unit rules and combat options.")
    }

    public var armyTabBrowseRulesHint: String {
        if isStarCraft { return String(localized: "Track unit health and browse unit cards here.") }
        if isWh40k { return String(localized: "Track wounds and browse unit details here.") }
        return String(localized: "Track wounds and browse unit rules cards here.")
    }

    public var bundledUnitSourceAttribution: String {
        if isWh40k {
            return String(localized: "Source: bundled unit notes — verify stats in the app or on your unit card.")
        }
        if isStarCraft {
            return String(localized: "Source: bundled unit card notes — verify stats in Command Center.")
        }
        return String(localized: "Source: bundled unit rules card — verify stats on your physical card.")
    }

    public func unitRulesInfoAccessibilityLabel(unitName: String) -> String {
        if isWh40k { return String(localized: "View \(unitName) unit details") }
        if isStarCraft { return String(localized: "View \(unitName) unit card") }
        return String(localized: "View \(unitName) unit rules card")
    }

    /// Label for bundled health value in unit focus (vs match override).
    public var catalogHealthValueLabel: String {
        if isWh40k { return String(localized: "Bundled value") }
        if isStarCraft { return String(localized: "Unit card") }
        return String(localized: "Spearhead app")
    }

    public var useCatalogHealthValueLabel: String {
        if isWh40k { return String(localized: "Use bundled value") }
        if isStarCraft { return String(localized: "Use unit card value") }
        return String(localized: "Use Spearhead value")
    }

    public static func context(
        for gameSystemId: GameSystemId,
        registry: GameSystemRegistry = .bundled
    ) -> GameSystemPlayContext {
        GameSystemPlayContext(gameSystemId: gameSystemId, registry: registry)
    }

    public static func context(
        for gameSystemId: String,
        registry: GameSystemRegistry = .bundled
    ) -> GameSystemPlayContext {
        context(for: GameSystemId(resolving: gameSystemId), registry: registry)
    }

    public static func capabilities(
        for gameSystemId: GameSystemId,
        registry: GameSystemRegistry = .bundled
    ) -> PlayCapabilities {
        context(for: gameSystemId, registry: registry).capabilities
    }

    public static func capabilities(
        for gameSystemId: String,
        registry: GameSystemRegistry = .bundled
    ) -> PlayCapabilities {
        capabilities(for: GameSystemId(resolving: gameSystemId), registry: registry)
    }

    private static func fallbackDescriptor(for gameSystemId: GameSystemId) -> GameSystemDescriptor {
        GameSystemDescriptor(
            id: gameSystemId,
            publisher: "unknown",
            playEngine: .phasedRound(
                PhasedRoundEngineConfig(
                    battleRoundCount: SpearheadBattleRules.battleRoundCount,
                    mainPhases: BattleTurnPhase.mainTurnPhases,
                    initialPhase: .deployment,
                    turnStartPhase: .hero,
                    usesBattleRoundLabel: false
                )
            ),
            capabilities: PlayCapabilities(),
            copy: GameSystemCopy(
                shortLabel: String(localized: "Rules"),
                rulesTitle: String(localized: "Rules"),
                glossaryTitle: String(localized: "Glossary"),
                searchPrompt: String(localized: "Rules, units, topics…"),
                rulesSearchPrompt: String(localized: "Search rules"),
                browseIntro: String(localized: "Search rules, glossary terms, and guide topics."),
                gameGuideBrowseTitle: String(localized: "Game Guide"),
                searchEmptyStateHint: String(
                    localized: "No matches — try fewer words or a glossary term like “rend” or “pile in”."
                ),
                displayName: String(localized: "Guided Match"),
                searchPickerLabel: String(localized: "Game System")
            ),
            victoryPointsScoring: .spearheadDefault
        )
    }
}

public struct VictoryPointsScoring: Sendable, Equatable {
    public let highlightText: String
    public let primaryQuickAddLabel: String
    public let primaryQuickAddAmount: Int
    public let secondaryQuickAddLabel: String
    public let secondaryQuickAddAmount: Int

    public init(
        highlightText: String,
        primaryQuickAddLabel: String,
        primaryQuickAddAmount: Int,
        secondaryQuickAddLabel: String,
        secondaryQuickAddAmount: Int
    ) {
        self.highlightText = highlightText
        self.primaryQuickAddLabel = primaryQuickAddLabel
        self.primaryQuickAddAmount = primaryQuickAddAmount
        self.secondaryQuickAddLabel = secondaryQuickAddLabel
        self.secondaryQuickAddAmount = secondaryQuickAddAmount
    }

    public static let spearheadDefault = VictoryPointsScoring(
        highlightText: String(
            localized: "Score objectives and battle tactics for the active player before ending the turn."
        ),
        primaryQuickAddLabel: String(localized: "+1 objective"),
        primaryQuickAddAmount: 1,
        secondaryQuickAddLabel: String(localized: "+1 tactic"),
        secondaryQuickAddAmount: 1
    )

    public static let wh40k11e = VictoryPointsScoring(
        highlightText: String(
            localized: "Score primary and secondary objectives for the active player before ending the turn."
        ),
        primaryQuickAddLabel: String(localized: "+1 primary"),
        primaryQuickAddAmount: 1,
        secondaryQuickAddLabel: String(localized: "+1 secondary"),
        secondaryQuickAddAmount: 1
    )

    public static let combatPatrol = VictoryPointsScoring(
        highlightText: String(
            localized: "Score primary (+5 per objective), secondaries, and Battle Ready before ending the turn."
        ),
        primaryQuickAddLabel: String(localized: "+5 objective"),
        primaryQuickAddAmount: 5,
        secondaryQuickAddLabel: String(localized: "+10 Battle Ready"),
        secondaryQuickAddAmount: 10
    )

    public static let scTmg = VictoryPointsScoring(
        highlightText: String(
            localized: "Score mission victory points for Supply held within 3\" of objectives."
        ),
        primaryQuickAddLabel: String(localized: "+1 objective"),
        primaryQuickAddAmount: 1,
        secondaryQuickAddLabel: String(localized: "+1 bonus"),
        secondaryQuickAddAmount: 1
    )
}
