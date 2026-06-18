import Foundation

/// Canonical ids for bundled play modes. Add new game modes here only.
public enum GameSystemId: String, Codable, Sendable, CaseIterable, Identifiable, Hashable {
    case aosSpearhead = "aos-spearhead"
    case wh40k11e = "wh40k-11e"
    case wh40k10eCp = "wh40k-10e-cp"
    case scTmg = "sc-tmg"

    public var id: String { rawValue }

    public static let `default` = aosSpearhead

    /// Resolves a rules-bundle or persisted id. Returns nil for unregistered modes (e.g. legacy `wh40k-10e`).
    public init?(knownRawValue: String) {
        self.init(rawValue: knownRawValue)
    }

    /// For navigation and persisted strings where a fallback is acceptable.
    public init(resolving rawValue: String) {
        self = GameSystemId(rawValue: rawValue) ?? .default
    }
}
