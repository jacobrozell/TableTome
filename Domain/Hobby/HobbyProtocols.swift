import Foundation

/// Pure abstractions the hobby domain operates over so engines stay free of SwiftData.
/// SwiftData models in `TabletomeHobbyData` will conform to these once ported in Phase 4.

public protocol SquadMemberLike: AnyObject {
    var index: Int { get }
    var state: String? { get set }
    var notes: String? { get }
}

public protocol UnitLike: AnyObject {
    var state: String { get set }
    var notes: String { get }
    var modelCount: Int { get }
    var hasSquadMembers: Bool { get }
    var members: [any SquadMemberLike] { get }
    var orderedMembers: [any SquadMemberLike] { get }
}

extension UnitLike {
    /// Lookup helper used by member-aware engines. Ported from MiniMuster `unit.member(at:)`.
    public func member(at index: Int) -> (any SquadMemberLike)? {
        members.first { $0.index == index }
    }
}

public protocol ArmyLike: AnyObject {
    var faction: String { get }
    var game: String { get }
    var crestOverride: String? { get }
    var colorOverrideHex: String? { get }
    var customPipeline: [PipelineStage]? { get }
}

/// User-supplied override of a faction's crest/color. Ports `FactionPresetOverride`
/// from MiniMuster (`js/data/factions/types.ts`).
public struct FactionPresetOverride: Hashable, Sendable, Codable {
    public let key: String   // composite "Game:Faction"
    public let crest: String
    public let hex: String

    public init(key: String, crest: String, hex: String) {
        self.key = key
        self.crest = crest
        self.hex = hex
    }
}

/// Clamp a hex string to the `#rrggbb` / `#rgb` shapes the hobby UI expects.
/// Mirrors `safeColor` from `js/data/sanitize.js`.
public func safeColor(_ raw: String) -> String {
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    let pattern = /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/
    return trimmed.wholeMatch(of: pattern) != nil ? trimmed : "#888"
}
