import Foundation
import TabletomeHobbyData
import TabletomeDomain
import SwiftData
import TabletomeDomain

/// HobbyPaint CRUD. Ports `addPaint`, `updatePaint`, `removePaint` (`js/core/store.js`) and the
/// add/edit flows (`js/render/paints.js`). Name uniqueness is case-insensitive.
@MainActor
enum PaintStore {

    @discardableResult
    static func add(name: String, type: String, brand: String, source: String,
                    qty: Int, notes: String, low: Bool, in ctx: ModelContext) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        let all = (try? ctx.fetch(FetchDescriptor<HobbyPaint>())) ?? []
        guard !all.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) else { return false }
        let p = HobbyPaint(name: trimmed.hobbyCapped(HobbyLimits.maxStringLen), type: type,
                      swatchHex: PaintType.swatchHex(for: type), qty: max(1, qty),
                      brand: brand.hobbyCapped(HobbyLimits.maxStringLen), source: source.hobbyCapped(HobbyLimits.maxStringLen),
                      notes: notes.hobbyCapped(HobbyLimits.maxNotesLen), low: low)
        ctx.insert(p)
        try? ctx.save()
        return true
    }

    @discardableResult
    static func update(_ paint: HobbyPaint, name: String, type: String, brand: String, source: String,
                       qty: Int, notes: String, low: Bool, in ctx: ModelContext) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }
        let all = (try? ctx.fetch(FetchDescriptor<HobbyPaint>())) ?? []
        if all.contains(where: { $0 !== paint && $0.name.lowercased() == trimmed.lowercased() }) {
            return false
        }
        paint.name = trimmed.hobbyCapped(HobbyLimits.maxStringLen)
        paint.type = type
        paint.swatchHex = PaintType.swatchHex(for: type)
        paint.brand = brand.hobbyCapped(HobbyLimits.maxStringLen)
        paint.source = source.hobbyCapped(HobbyLimits.maxStringLen)
        paint.qty = max(1, min(9999, qty))
        paint.notes = notes.hobbyCapped(HobbyLimits.maxNotesLen)
        paint.low = low
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
}
