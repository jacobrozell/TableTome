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
    public let editionMigrationSteps: [GuideStep]
    public let ruleSections: [RuleSection]
    public let externalLinks: [ExternalLink]?

    public init(
        id: String,
        name: String,
        tagline: String,
        edition: String,
        availability: GameSystemAvailability,
        gettingStartedSteps: [GuideStep],
        editionMigrationSteps: [GuideStep] = [],
        ruleSections: [RuleSection],
        externalLinks: [ExternalLink]? = nil
    ) {
        self.id = id
        self.name = name
        self.tagline = tagline
        self.edition = edition
        self.availability = availability
        self.gettingStartedSteps = gettingStartedSteps
        self.editionMigrationSteps = editionMigrationSteps
        self.ruleSections = ruleSections
        self.externalLinks = externalLinks
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, tagline, edition, availability
        case gettingStartedSteps, editionMigrationSteps, ruleSections, externalLinks
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        tagline = try container.decode(String.self, forKey: .tagline)
        edition = try container.decode(String.self, forKey: .edition)
        availability = try container.decode(GameSystemAvailability.self, forKey: .availability)
        gettingStartedSteps = try container.decode([GuideStep].self, forKey: .gettingStartedSteps)
        editionMigrationSteps = try container.decodeIfPresent([GuideStep].self, forKey: .editionMigrationSteps) ?? []
        ruleSections = try container.decode([RuleSection].self, forKey: .ruleSections)
        externalLinks = try container.decodeIfPresent([ExternalLink].self, forKey: .externalLinks)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(tagline, forKey: .tagline)
        try container.encode(edition, forKey: .edition)
        try container.encode(availability, forKey: .availability)
        try container.encode(gettingStartedSteps, forKey: .gettingStartedSteps)
        if !editionMigrationSteps.isEmpty {
            try container.encode(editionMigrationSteps, forKey: .editionMigrationSteps)
        }
        try container.encode(ruleSections, forKey: .ruleSections)
        try container.encodeIfPresent(externalLinks, forKey: .externalLinks)
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
