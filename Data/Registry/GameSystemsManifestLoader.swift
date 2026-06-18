import Foundation
import TabletomeDomain

public struct GameSystemsManifest: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let systems: [GameSystemManifestEntry]
}

public struct GameSystemManifestEntry: Codable, Sendable, Equatable {
    public let id: String
    public let playEngine: PlayEngineId
    public let publisher: String
    public let catalogBundleName: String
    public let armyDetailsSubdirectories: [String]
}

public enum GameSystemsManifestLoader {
    public static func load(from bundle: Bundle = .main) throws -> GameSystemsManifest {
        guard let url = manifestURL(in: bundle) else {
            throw GameSystemsManifestError.bundleNotFound
        }
        return try JSONDecoder().decode(GameSystemsManifest.self, from: Data(contentsOf: url))
    }

    public static func validateAgainstRegistry(
        _ manifest: GameSystemsManifest,
        registry: GameSystemRegistry = .bundled
    ) -> [GameSystemsManifestValidationIssue] {
        var issues: [GameSystemsManifestValidationIssue] = []
        let manifestIds = Set(manifest.systems.map(\.id))
        let registryIds = Set(registry.allDescriptors.map(\.gameSystemId))

        for missing in registryIds.subtracting(manifestIds) {
            issues.append(.missingManifestEntry(gameSystemId: missing))
        }
        for extra in manifestIds.subtracting(registryIds) {
            issues.append(.unknownManifestEntry(gameSystemId: extra))
        }

        for entry in manifest.systems {
            guard let descriptor = registry.descriptor(for: entry.id) else { continue }
            if descriptor.playEngine.playEngineId != entry.playEngine {
                issues.append(.playEngineMismatch(
                    gameSystemId: entry.id,
                    manifest: entry.playEngine,
                    registry: descriptor.playEngine.playEngineId
                ))
            }
            if descriptor.catalogBundleName != entry.catalogBundleName {
                issues.append(.catalogBundleMismatch(
                    gameSystemId: entry.id,
                    manifest: entry.catalogBundleName,
                    registry: descriptor.catalogBundleName ?? ""
                ))
            }
            if descriptor.armyDetailsSubdirectories != entry.armyDetailsSubdirectories {
                issues.append(.armyPathsMismatch(gameSystemId: entry.id))
            }
        }
        return issues
    }

    private static func manifestURL(in bundle: Bundle) -> URL? {
        for subdirectory in [nil as String?, "Rules"] {
            if let url = bundle.url(
                forResource: "game-systems-manifest-v1",
                withExtension: "json",
                subdirectory: subdirectory
            ) {
                return url
            }
        }
        return nil
    }
}

public enum GameSystemsManifestError: Error, Equatable, Sendable {
    case bundleNotFound
}

public enum GameSystemsManifestValidationIssue: Equatable, Sendable {
    case missingManifestEntry(gameSystemId: String)
    case unknownManifestEntry(gameSystemId: String)
    case playEngineMismatch(gameSystemId: String, manifest: PlayEngineId, registry: PlayEngineId)
    case catalogBundleMismatch(gameSystemId: String, manifest: String, registry: String)
    case armyPathsMismatch(gameSystemId: String)
}
