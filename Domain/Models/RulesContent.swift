import Foundation

public enum GameSystemAvailability: String, Codable, Sendable {
    case available
    case comingSoon
}

public struct RulesBundle: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let gameSystems: [GameSystem]

    public init(schemaVersion: Int, gameSystems: [GameSystem]) {
        self.schemaVersion = schemaVersion
        self.gameSystems = gameSystems
    }
}

public struct GameSystem: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let tagline: String
    public let edition: String
    public let availability: GameSystemAvailability
    public let gettingStartedSteps: [GuideStep]
    public let ruleSections: [RuleSection]
    public let externalLinks: [ExternalLink]?

    public init(
        id: String,
        name: String,
        tagline: String,
        edition: String,
        availability: GameSystemAvailability,
        gettingStartedSteps: [GuideStep],
        ruleSections: [RuleSection],
        externalLinks: [ExternalLink]? = nil
    ) {
        self.id = id
        self.name = name
        self.tagline = tagline
        self.edition = edition
        self.availability = availability
        self.gettingStartedSteps = gettingStartedSteps
        self.ruleSections = ruleSections
        self.externalLinks = externalLinks
    }
}

public struct GuideStep: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let order: Int
    public let title: String
    public let summary: String
    public let body: String
    public let tips: [String]
    public let relatedRuleSectionId: String?

    public init(
        id: String,
        order: Int,
        title: String,
        summary: String,
        body: String,
        tips: [String],
        relatedRuleSectionId: String? = nil
    ) {
        self.id = id
        self.order = order
        self.title = title
        self.summary = summary
        self.body = body
        self.tips = tips
        self.relatedRuleSectionId = relatedRuleSectionId
    }
}

public enum RuleSectionCategory: String, Codable, Sendable, CaseIterable {
    case core
    case spearhead
    case glossary
}

public struct RuleSection: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let category: RuleSectionCategory
    public let order: Int
    public let content: String
    public let relatedSectionIds: [String]

    public init(
        id: String,
        title: String,
        category: RuleSectionCategory,
        order: Int,
        content: String,
        relatedSectionIds: [String] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.order = order
        self.content = content
        self.relatedSectionIds = relatedSectionIds
    }
}

public struct ExternalLink: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let url: URL

    public init(id: String, title: String, url: URL) {
        self.id = id
        self.title = title
        self.url = url
    }
}
