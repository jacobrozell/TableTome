import Foundation
import TabletomeDomain
import SwiftData
import TabletomeDomain

/// Applies parsed drafts and restore payloads to the SwiftData context. Ports the relevant
/// mutations from `js/core/store.js` (`setCollection`, `appendCollection`, `setPaints`,
/// `appendPaints`, `clearAllData`).
@MainActor
public enum CollectionStore {

    // MARK: Build models from drafts

    private static func makeUnit(_ d: UnitDraft, order: Int, into ctx: ModelContext) -> ArmyUnit {
        let u = ArmyUnit(name: d.name.hobbyCapped(HobbyLimits.maxStringLen), qty: d.qty,
                     source: d.source.hobbyCapped(HobbyLimits.maxStringLen), state: d.state,
                     notes: d.notes.hobbyCapped(HobbyLimits.maxNotesLen), spearhead: d.spearhead, order: order)
        ctx.insert(u)
        for (i, m) in d.members.prefix(HobbyLimits.maxSquadMembers).enumerated() {
            let sm = SquadMember(index: i,
                                 state: m.state,
                                 notes: m.notes)
            sm.unit = u
            ctx.insert(sm)
        }
        return u
    }

    private static func makeArmy(_ d: ArmyDraft, sortIndex: Int, into ctx: ModelContext) -> Army {
        let a = Army(name: d.name.hobbyCapped(HobbyLimits.maxStringLen),
                     game: d.game.hobbyCapped(HobbyLimits.maxStringLen),
                     faction: d.faction.hobbyCapped(HobbyLimits.maxStringLen),
                     sortIndex: sortIndex)
        a.isSample = d.isSample
        a.crestOverride = d.crestOverride.map { String($0.prefix(8)) }
        a.colorOverrideHex = d.colorOverrideHex.map(safeColor)
        if let pipe = d.customPipeline, !pipe.isEmpty {
            a.customPipeline = pipe.map { PipelineStage(key: $0.key, hex: safeColor($0.hex)) }
        }
        ctx.insert(a)
        for (i, ud) in d.units.prefix(HobbyLimits.maxUnitsPerArmy).enumerated() {
            let u = makeUnit(ud, order: i, into: ctx)
            u.army = a
        }
        return a
    }

    private static func makePaint(_ d: PaintDraft, into ctx: ModelContext) -> HobbyPaint {
        let hex = safeColor(d.swatchHex)
        let custom = d.usesCustomSwatch
            || PaintSwatchResolver.inferUsesCustom(
                storedHex: hex, name: d.name, brand: d.brand, type: d.type
            )
        let p = HobbyPaint(name: d.name.hobbyCapped(HobbyLimits.maxStringLen),
                      type: d.type.hobbyCapped(HobbyLimits.maxStringLen),
                      swatchHex: hex,
                      usesCustomSwatch: custom,
                      qty: d.qty,
                      brand: d.brand.hobbyCapped(HobbyLimits.maxStringLen),
                      source: d.source.hobbyCapped(HobbyLimits.maxStringLen),
                      notes: d.notes.hobbyCapped(HobbyLimits.maxNotesLen), low: d.low)
        p.isSample = d.isSample
        ctx.insert(p)
        return p
    }

    // MARK: Armies

    public static func replaceArmies(_ drafts: [ArmyDraft], in ctx: ModelContext) {
        for a in (try? ctx.fetch(FetchDescriptor<Army>())) ?? [] { ctx.delete(a) }
        for (i, d) in drafts.prefix(HobbyLimits.maxArmies).enumerated() {
            _ = makeArmy(d, sortIndex: i, into: ctx)
        }
        try? ctx.save()
    }

    /// Append: incoming armies with an existing name have their units appended; else inserted.
    /// Mirrors `appendCollection`.
    public static func appendArmies(_ drafts: [ArmyDraft], in ctx: ModelContext) {
        var existing = ((try? ctx.fetch(FetchDescriptor<Army>())) ?? [])
        var nextSort = (existing.map(\.sortIndex).max() ?? -1) + 1
        for d in drafts {
            if let target = existing.first(where: { $0.name == d.name }) {
                var order = (target.units.map(\.order).max() ?? -1) + 1
                for ud in d.units {
                    let u = makeUnit(ud, order: order, into: ctx)
                    u.army = target
                    order += 1
                }
            } else {
                let a = makeArmy(d, sortIndex: nextSort, into: ctx)
                nextSort += 1
                existing.append(a)
            }
        }
        try? ctx.save()
    }

    // MARK: Paints

    public static func replacePaints(_ drafts: [PaintDraft], in ctx: ModelContext) {
        for p in (try? ctx.fetch(FetchDescriptor<HobbyPaint>())) ?? [] { ctx.delete(p) }
        for d in drafts.prefix(HobbyLimits.maxPaints) { _ = makePaint(d, into: ctx) }
        try? ctx.save()
    }

    /// Append: merge by lowercased name (sum qty, adopt notes if target had none).
    /// Mirrors `appendPaints`.
    public static func appendPaints(_ drafts: [PaintDraft], in ctx: ModelContext) {
        var byName: [String: HobbyPaint] = [:]
        for p in (try? ctx.fetch(FetchDescriptor<HobbyPaint>())) ?? [] { byName[p.name.lowercased()] = p }
        for d in drafts {
            let k = d.name.lowercased()
            if let existing = byName[k] {
                existing.qty += d.qty
                if existing.notes.isEmpty && !d.notes.isEmpty { existing.notes = d.notes }
            } else {
                let p = makePaint(d, into: ctx)
                byName[k] = p
            }
        }
        try? ctx.save()
    }

    // MARK: Sample data

    public static func hasSampleData(in ctx: ModelContext) -> Bool {
        let armies = (try? ctx.fetch(FetchDescriptor<Army>())) ?? []
        if armies.contains(where: \.isSample) { return true }
        let paints = (try? ctx.fetch(FetchDescriptor<HobbyPaint>())) ?? []
        return paints.contains(where: \.isSample)
    }

    /// Insert bundled sample armies without removing or merging into user-created armies.
    @discardableResult
    public static func insertSampleArmies(_ drafts: [ArmyDraft], in ctx: ModelContext) -> Int {
        removeSampleArmies(in: ctx)
        let existing = (try? ctx.fetch(FetchDescriptor<Army>())) ?? []
        let reservedNames = Set(existing.filter { !$0.isSample }.map(\.name))
        var nextSort = (existing.map(\.sortIndex).max() ?? -1) + 1
        var inserted = 0
        for d in drafts {
            guard !reservedNames.contains(d.name) else { continue }
            var sampleDraft = d
            sampleDraft.isSample = true
            _ = makeArmy(sampleDraft, sortIndex: nextSort, into: ctx)
            nextSort += 1
            inserted += 1
        }
        try? ctx.save()
        return inserted
    }

    /// Insert bundled sample paints; skips names already used by user paints.
    @discardableResult
    public static func insertSamplePaints(_ drafts: [PaintDraft], in ctx: ModelContext) -> Int {
        removeSamplePaints(in: ctx)
        var byName: [String: HobbyPaint] = [:]
        for p in (try? ctx.fetch(FetchDescriptor<HobbyPaint>())) ?? [] { byName[p.name.lowercased()] = p }
        var inserted = 0
        for d in drafts {
            let key = d.name.lowercased()
            if let existing = byName[key], !existing.isSample { continue }
            var sampleDraft = d
            sampleDraft.isSample = true
            let paint = makePaint(sampleDraft, into: ctx)
            byName[key] = paint
            inserted += 1
        }
        try? ctx.save()
        return inserted
    }

    @discardableResult
    public static func removeSampleData(in ctx: ModelContext) -> (armies: Int, paints: Int) {
        let armyCount = removeSampleArmies(in: ctx)
        let paintCount = removeSamplePaints(in: ctx)
        try? ctx.save()
        return (armyCount, paintCount)
    }

    @discardableResult
    private static func removeSampleArmies(in ctx: ModelContext) -> Int {
        let sampleArmies = ((try? ctx.fetch(FetchDescriptor<Army>())) ?? []).filter(\.isSample)
        for army in sampleArmies { ctx.delete(army) }
        return sampleArmies.count
    }

    @discardableResult
    private static func removeSamplePaints(in ctx: ModelContext) -> Int {
        let samplePaints = ((try? ctx.fetch(FetchDescriptor<HobbyPaint>())) ?? []).filter(\.isSample)
        for paint in samplePaints { ctx.delete(paint) }
        return samplePaints.count
    }

    // MARK: Clear

    public static func clearAll(in ctx: ModelContext) {
        for a in (try? ctx.fetch(FetchDescriptor<Army>())) ?? [] { ctx.delete(a) }
        for p in (try? ctx.fetch(FetchDescriptor<HobbyPaint>())) ?? [] { ctx.delete(p) }
        // Reset configuration to defaults.
        for c in (try? ctx.fetch(FetchDescriptor<AppConfiguration>())) ?? [] { ctx.delete(c) }
        ctx.insert(AppConfiguration())
        try? ctx.save()
    }
}
