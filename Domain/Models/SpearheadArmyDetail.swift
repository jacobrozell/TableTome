import Foundation

/// Optional battle-tracker overlay shipped as `Resources/Rules/Spearhead/armies/{army-id}.json`.
/// The base roster lives in `spearhead-catalog-v1.json`; drop in a detail file to enable the tracker without editing the catalog.
public struct SpearheadArmyDetail: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let armyId: String
    public let battleTraits: [ArmyRuleOption]?
    public let units: [SpearheadUnit]?

    public init(
        schemaVersion: Int = 1,
        armyId: String,
        battleTraits: [ArmyRuleOption]? = nil,
        units: [SpearheadUnit]? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.armyId = armyId
        self.battleTraits = battleTraits
        self.units = units
    }
}

public enum SpearheadContentCoverage: String, Codable, Sendable, CaseIterable, Comparable {
    case roster
    case matchSetup
    case battleTracker
    case warscrolls

    private var rank: Int {
        switch self {
        case .roster: 0
        case .matchSetup: 1
        case .battleTracker: 2
        case .warscrolls: 3
        }
    }

    public static func < (lhs: SpearheadContentCoverage, rhs: SpearheadContentCoverage) -> Bool {
        lhs.rank < rhs.rank
    }

    public var title: String {
        switch self {
        case .roster: String(localized: "Roster")
        case .matchSetup: String(localized: "Match Setup")
        case .battleTracker: String(localized: "Battle Tracker")
        case .warscrolls: String(localized: "Warscrolls")
        }
    }

    public var playerFacingTitle: String {
        playerFacingTitle(gameSystemId: GameSystemRulesLabels.defaultGameSystemId)
    }

    public func playerFacingTitle(gameSystemId: String) -> String {
        switch self {
        case .roster:
            String(localized: "Army list only")
        case .matchSetup:
            String(localized: "Setup ready")
        case .battleTracker:
            String(localized: "Rules reminders ready")
        case .warscrolls:
            if GameSystemPlayContext.context(for: gameSystemId).isWh40k {
                String(localized: "Full unit support")
            } else {
                String(localized: "Full tabletop support")
            }
        }
    }

    public var systemImage: String {
        switch self {
        case .roster: "list.bullet"
        case .matchSetup: "flag.checkered"
        case .battleTracker: "checkmark.seal.fill"
        case .warscrolls: "star.fill"
        }
    }
}

extension SpearheadArmy {
    public var contentCoverage: SpearheadContentCoverage {
        let hasWarscrolls = units.contains { $0.hasWarscroll }
        if hasWarscrolls && hasBattleTrackerContent { return .warscrolls }
        if hasBattleTrackerContent { return .battleTracker }
        if !regimentAbilities.isEmpty && !enhancements.isEmpty { return .matchSetup }
        return .roster
    }

    public var supportsBattleTracker: Bool {
        hasBattleTrackerContent
    }

    private var hasBattleTrackerContent: Bool {
        let abilities = BattleAbilityCatalog.abilities(for: self)
        return !units.isEmpty
            || abilities.contains { ability in
                !ability.phases.isEmpty && (!ability.isPassive || ability.declare != nil)
            }
    }
}

extension SpearheadCatalog {
    public func army(factionId: String, armyId: String) -> SpearheadArmy? {
        factions
            .first { $0.id == factionId }?
            .armies
            .first { $0.id == armyId }
    }

    public var battleTrackerArmyCount: Int {
        factions.flatMap(\.armies).filter(\.supportsBattleTracker).count
    }
}
