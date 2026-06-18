import Foundation

public struct GameSystemDescriptor: Sendable, Equatable, Identifiable {
    public let id: GameSystemId
    public let publisher: String
    public let playEngine: PlayEngineConfig
    public let capabilities: PlayCapabilities
    public let copy: GameSystemCopy
    public let victoryPointsScoring: VictoryPointsScoring
    public let featuredArmies: FeaturedArmiesConfig?
    public let catalogBundleName: String?
    public let armyDetailsSubdirectories: [String]

    public var gameSystemId: String { id.rawValue }

    public init(
        id: GameSystemId,
        publisher: String,
        playEngine: PlayEngineConfig,
        capabilities: PlayCapabilities,
        copy: GameSystemCopy,
        victoryPointsScoring: VictoryPointsScoring = .spearheadDefault,
        featuredArmies: FeaturedArmiesConfig? = nil,
        catalogBundleName: String? = nil,
        armyDetailsSubdirectories: [String] = []
    ) {
        self.id = id
        self.publisher = publisher
        self.playEngine = playEngine
        self.capabilities = capabilities
        self.copy = copy
        self.victoryPointsScoring = victoryPointsScoring
        self.featuredArmies = featuredArmies
        self.catalogBundleName = catalogBundleName
        self.armyDetailsSubdirectories = armyDetailsSubdirectories
    }
}

public enum GameSystemRegistryError: Error, Equatable, Sendable {
    case systemNotFound(id: String)
}

public struct GameSystemRegistry: Sendable {
    private let descriptorsById: [String: GameSystemDescriptor]

    public init(descriptors: [GameSystemDescriptor]) {
        var map: [String: GameSystemDescriptor] = [:]
        for descriptor in descriptors {
            map[descriptor.id.rawValue] = descriptor
        }
        descriptorsById = map
    }

    public func descriptor(for id: GameSystemId) -> GameSystemDescriptor? {
        descriptorsById[id.rawValue]
    }

    public func descriptor(for id: String) -> GameSystemDescriptor? {
        descriptorsById[id]
    }

    public func requireDescriptor(for id: String) throws -> GameSystemDescriptor {
        guard let descriptor = descriptorsById[id] else {
            throw GameSystemRegistryError.systemNotFound(id: id)
        }
        return descriptor
    }

    public var allDescriptors: [GameSystemDescriptor] {
        descriptorsById.values.sorted { $0.id.rawValue < $1.id.rawValue }
    }

    public func playEngine(for id: String) -> PlayEngineConfig? {
        descriptor(for: id)?.playEngine
    }

    public func capabilities(for id: String) -> PlayCapabilities? {
        descriptor(for: id)?.capabilities
    }

    public func copy(for id: String) -> GameSystemCopy? {
        descriptor(for: id)?.copy
    }

    public func featuredArmies(for id: String) -> FeaturedArmiesConfig? {
        descriptor(for: id)?.featuredArmies
    }

    public func requireDescriptor(for id: GameSystemId) throws -> GameSystemDescriptor {
        try requireDescriptor(for: id.rawValue)
    }

    public func playEngine(for id: GameSystemId) -> PlayEngineConfig? {
        playEngine(for: id.rawValue)
    }

    public func capabilities(for id: GameSystemId) -> PlayCapabilities? {
        capabilities(for: id.rawValue)
    }

    public func copy(for id: GameSystemId) -> GameSystemCopy? {
        copy(for: id.rawValue)
    }

    public func featuredArmies(for id: GameSystemId) -> FeaturedArmiesConfig? {
        featuredArmies(for: id.rawValue)
    }

    public func isKnownSystem(_ id: GameSystemId) -> Bool {
        isKnownSystem(id.rawValue)
    }

    public func isKnownSystem(_ id: String) -> Bool {
        descriptorsById[id] != nil
    }
}
