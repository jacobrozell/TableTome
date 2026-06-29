import Foundation

/// Unified lookup across liquid paint and basing material reference catalogs.
public enum PaintInventoryCatalog {
    public static var paintCount: Int { PaintSwatchCatalog.count }
    public static var basingCount: Int { BasingMaterialCatalog.count }
    public static var totalCount: Int { paintCount + basingCount }

    public static func lookup(name: String, brand: String = "") -> String? {
        lookupEntry(name: name, brand: brand)?.hex
    }

    public static func lookupEntry(name: String, brand: String = "") -> PaintCatalogEntry? {
        PaintSwatchCatalog.lookupEntry(name: name, brand: brand)
            ?? BasingMaterialCatalog.lookupEntry(name: name, brand: brand)
    }

    /// Search both catalogs. When `preferredType` is `Basing`, basing materials rank first.
    public static func search(_ query: String, preferredType: String = "", limit: Int = 10) -> [PaintCatalogEntry] {
        let paint = PaintSwatchCatalog.search(query, limit: limit)
        let basing = BasingMaterialCatalog.search(query, limit: limit)

        if preferredType == "Basing" {
            var seen = Set<String>()
            var merged: [PaintCatalogEntry] = []
            for entry in basing + paint.filter({ $0.type == "Basing" }) {
                guard seen.insert(entry.id).inserted else { continue }
                merged.append(entry)
                if merged.count >= limit { break }
            }
            return merged
        }

        if !preferredType.isEmpty {
            let filtered = paint.filter { ($0.type ?? "") == preferredType || $0.type == nil }
            if !filtered.isEmpty { return Array(filtered.prefix(limit)) }
        }

        var seen = Set<String>()
        var merged: [PaintCatalogEntry] = []
        for entry in paint + basing {
            guard seen.insert(entry.id).inserted else { continue }
            merged.append(entry)
            if merged.count >= limit { break }
        }
        return merged
    }
}
