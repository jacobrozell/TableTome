import Foundation

extension GameSystemRegistry {
    public static let bundled: GameSystemRegistry = GameSystemRegistry(
        descriptors: GameSystemId.allCases.map(\.bundledDescriptor)
    )
}
