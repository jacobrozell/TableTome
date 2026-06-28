import Foundation

extension GameSystemRegistry {
    /// Descriptor seed without box-set JSON — used before the app installs the live registry.
    public static let seeded: GameSystemRegistry = GameSystemRegistry(
        descriptors: GameSystemId.allCases.map(\.bundledDescriptor)
    )

    nonisolated(unsafe) private static var installed: GameSystemRegistry?

    /// Production registry (box-set featured armies installed by the app at launch).
    public static var bundled: GameSystemRegistry {
        installed ?? seeded
    }

    /// Installs the registry the app and tests should treat as authoritative.
    public static func installBundled(_ registry: GameSystemRegistry) {
        installed = registry
    }
}
