import Foundation

/// One row in a bundled inventory reference catalog (paint or basing material).
public struct PaintCatalogEntry: Sendable, Hashable, Codable, Identifiable {
    public let name: String
    public let brand: String?
    public let type: String?
    public let hex: String
    /// Basing-only subcategory, e.g. Static Grass, Tuft, Texture Paste.
    public let category: String?

    public var id: String { "\(name.lowercased())|\(brand?.lowercased() ?? "")" }

    public init(
        name: String,
        brand: String?,
        type: String?,
        hex: String,
        category: String? = nil
    ) {
        self.name = name
        self.brand = brand
        self.type = type
        self.hex = safeColor(hex)
        self.category = category
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        brand = try container.decodeIfPresent(String.self, forKey: .brand)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        hex = safeColor(try container.decode(String.self, forKey: .hex))
        category = try container.decodeIfPresent(String.self, forKey: .category)
    }
}

enum CatalogSearch {
    static func normalize(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func search(_ entries: [PaintCatalogEntry], query: String, limit: Int) -> [PaintCatalogEntry] {
        let q = normalize(query)
        guard q.count >= 2 else { return [] }
        let matches = entries.filter { entry in
            normalize(entry.name).contains(q)
                || (entry.brand.map { normalize($0).contains(q) } ?? false)
                || (entry.category.map { normalize($0).contains(q) } ?? false)
        }
        return matches
            .sorted { lhs, rhs in
                let lStart = normalize(lhs.name).hasPrefix(q)
                let rStart = normalize(rhs.name).hasPrefix(q)
                if lStart != rStart { return lStart }
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
            .prefix(max(1, limit))
            .map { $0 }
    }

    static func index(
        _ entries: [PaintCatalogEntry]
    ) -> (byName: [String: PaintCatalogEntry], byNameAndBrand: [String: PaintCatalogEntry]) {
        var byName: [String: PaintCatalogEntry] = [:]
        var byNameAndBrand: [String: PaintCatalogEntry] = [:]
        for entry in entries {
            let nameKey = normalize(entry.name)
            if byName[nameKey] == nil { byName[nameKey] = entry }
            if let brand = entry.brand {
                byNameAndBrand["\(nameKey)|\(normalize(brand))"] = entry
            }
        }
        return (byName, byNameAndBrand)
    }

    static func lookup(
        name: String,
        brand: String,
        in byName: [String: PaintCatalogEntry],
        byNameAndBrand: [String: PaintCatalogEntry]
    ) -> PaintCatalogEntry? {
        let normalizedName = normalize(name)
        guard !normalizedName.isEmpty else { return nil }
        let normalizedBrand = normalize(brand)
        if !normalizedBrand.isEmpty,
           let entry = byNameAndBrand["\(normalizedName)|\(normalizedBrand)"] {
            return entry
        }
        return byName[normalizedName]
    }
}
