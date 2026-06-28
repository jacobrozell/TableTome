import Foundation
import TabletomeDomain

/// Plain value drafts produced by parsing/import, before insertion into SwiftData.
public struct MemberDraft: Sendable, Equatable {
    public var state: String?
    public var notes: String?

    public init(state: String? = nil, notes: String? = nil) {
        self.state = state
        self.notes = notes
    }
}

public struct UnitDraft: Sendable, Equatable {
    public var name: String
    public var qty: Int
    public var source: String
    public var state: String
    public var spearhead: Bool?
    public var notes: String
    public var members: [MemberDraft]

    public init(
        name: String,
        qty: Int = 1,
        source: String = "",
        state: String,
        spearhead: Bool? = nil,
        notes: String = "",
        members: [MemberDraft] = []
    ) {
        self.name = name
        self.qty = qty
        self.source = source
        self.state = state
        self.spearhead = spearhead
        self.notes = notes
        self.members = members
    }
}

public struct ArmyDraft: Sendable, Equatable {
    public var name: String
    public var game: String
    public var faction: String
    public var crestOverride: String?
    public var colorOverrideHex: String?
    public var customPipeline: [PipelineStage]?
    public var units: [UnitDraft]
    public var isSample: Bool

    public init(
        name: String,
        game: String,
        faction: String,
        crestOverride: String? = nil,
        colorOverrideHex: String? = nil,
        customPipeline: [PipelineStage]? = nil,
        units: [UnitDraft] = [],
        isSample: Bool = false
    ) {
        self.name = name
        self.game = game
        self.faction = faction
        self.crestOverride = crestOverride
        self.colorOverrideHex = colorOverrideHex
        self.customPipeline = customPipeline
        self.units = units
        self.isSample = isSample
    }
}

public struct PaintDraft: Sendable, Equatable {
    public var name: String
    public var type: String
    public var swatchHex: String
    public var qty: Int
    public var brand: String
    public var source: String
    public var notes: String
    public var low: Bool
    public var isSample: Bool

    public init(
        name: String,
        type: String = "",
        swatchHex: String = "#777",
        qty: Int = 1,
        brand: String = "",
        source: String = "",
        notes: String = "",
        low: Bool = false,
        isSample: Bool = false
    ) {
        self.name = name
        self.type = type
        self.swatchHex = swatchHex
        self.qty = qty
        self.brand = brand
        self.source = source
        self.notes = notes
        self.low = low
        self.isSample = isSample
    }
}

/// Result of a CSV import. Mirrors the web `ImportResult`.
public struct ImportResult: Sendable {
    public var ok: Bool
    public var errors: [String]
    public var warnings: [String]
    public var stats: [String: Int]
    public var armies: [ArmyDraft]?
    public var paints: [PaintDraft]?

    public init(
        ok: Bool,
        errors: [String],
        warnings: [String],
        stats: [String: Int],
        armies: [ArmyDraft]?,
        paints: [PaintDraft]?
    ) {
        self.ok = ok
        self.errors = errors
        self.warnings = warnings
        self.stats = stats
        self.armies = armies
        self.paints = paints
    }

    public static func failure(_ errors: [String], warnings: [String] = []) -> ImportResult {
        ImportResult(ok: false, errors: errors, warnings: warnings, stats: [:], armies: nil, paints: nil)
    }
}
