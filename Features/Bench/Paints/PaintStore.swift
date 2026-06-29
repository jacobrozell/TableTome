import Foundation
import TabletomeHobbyData
import TabletomeDomain
import SwiftData

/// HobbyPaint CRUD. Ports `addPaint`, `updatePaint`, `removePaint` (`js/core/store.js`) and the
/// add/edit flows (`js/render/paints.js`). Name uniqueness is case-insensitive.
@MainActor
enum PaintStore {

    @discardableResult
    static func add(name: String, type: String, brand: String, source: String,
                    qty: Int, notes: String, low: Bool,
                    swatchHex: String? = nil, usesCustomSwatch: Bool = false,
                    in ctx: ModelContext) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        let all = (try? ctx.fetch(FetchDescriptor<HobbyPaint>())) ?? []
        guard !all.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) else { return false }
        let hex = resolvedSwatch(
            name: trimmed, brand: brand, type: type,
            usesCustomSwatch: usesCustomSwatch, swatchHex: swatchHex
        )
        let p = HobbyPaint(
            name: trimmed.hobbyCapped(HobbyLimits.maxStringLen),
            type: type,
            swatchHex: hex,
            usesCustomSwatch: usesCustomSwatch,
            qty: max(1, qty),
            brand: brand.hobbyCapped(HobbyLimits.maxStringLen),
            source: source.hobbyCapped(HobbyLimits.maxStringLen),
            notes: notes.hobbyCapped(HobbyLimits.maxNotesLen),
            low: low
        )
        ctx.insert(p)
        try? ctx.save()
        return true
    }

    @discardableResult
    static func update(_ paint: HobbyPaint, name: String, type: String, brand: String, source: String,
                       qty: Int, notes: String, low: Bool,
                       swatchHex: String? = nil, usesCustomSwatch: Bool? = nil,
                       in ctx: ModelContext) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        let all = (try? ctx.fetch(FetchDescriptor<HobbyPaint>())) ?? []
        if all.contains(where: { $0 !== paint && $0.name.lowercased() == trimmed.lowercased() }) {
            return false
        }
        let custom = usesCustomSwatch ?? paint.usesCustomSwatch
        paint.name = trimmed.hobbyCapped(HobbyLimits.maxStringLen)
        paint.type = type
        paint.brand = brand.hobbyCapped(HobbyLimits.maxStringLen)
        paint.source = source.hobbyCapped(HobbyLimits.maxStringLen)
        paint.qty = max(1, min(9999, qty))
        paint.notes = notes.hobbyCapped(HobbyLimits.maxNotesLen)
        paint.low = low
        paint.usesCustomSwatch = custom
        paint.swatchHex = resolvedSwatch(
            name: trimmed, brand: brand, type: type,
            usesCustomSwatch: custom, swatchHex: swatchHex ?? paint.swatchHex
        )
        try? ctx.save()
        return true
    }

    static func delete(_ paint: HobbyPaint, in ctx: ModelContext) {
        ctx.delete(paint)
        try? ctx.save()
    }

    /// Number of units across all armies whose source fuzzily matches this paint's source.
    /// Mirrors `unitsForSource`.
    static func linkedUnitCount(source: String, armies: [Army]) -> Int {
        guard !source.isEmpty else { return 0 }
        return armies.reduce(0) { acc, a in
            acc + a.units.filter { SourceMatch.matches(source, $0.source) }.count
        }
    }

    /// Re-apply catalog swatches for paints that are not using a custom colour.
    @discardableResult
    static func refreshCatalogColors(in ctx: ModelContext) -> Int {
        let paints = (try? ctx.fetch(FetchDescriptor<HobbyPaint>())) ?? []
        var updated = 0
        for paint in paints where !paint.usesCustomSwatch {
            let hex = PaintSwatchResolver.defaultSwatch(
                name: paint.name, brand: paint.brand, type: paint.type
            )
            if paint.swatchHex != hex {
                paint.swatchHex = hex
                updated += 1
            }
        }
        if updated > 0 { try? ctx.save() }
        return updated
    }

    private static func resolvedSwatch(
        name: String, brand: String, type: String,
        usesCustomSwatch: Bool, swatchHex: String?
    ) -> String {
        if usesCustomSwatch, let swatchHex {
            return safeColor(swatchHex)
        }
        return PaintSwatchResolver.defaultSwatch(name: name, brand: brand, type: type)
    }
}
