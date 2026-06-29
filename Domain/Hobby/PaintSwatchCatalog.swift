import Foundation

private struct PaintSwatchCatalogFile: Decodable {
    let version: Int?
    let paints: [PaintCatalogEntry]
}

/// Liquid hobby paint name → swatch hex. Loads `paint_swatch_catalog.json`.
public enum PaintSwatchCatalog {
    private static let entries: [PaintCatalogEntry] = loadEntries()
    private static let indexes = CatalogSearch.index(entries)

    public static var allEntries: [PaintCatalogEntry] { entries }
    public static var count: Int { entries.count }

    public static func lookup(name: String, brand: String = "") -> String? {
        lookupEntry(name: name, brand: brand)?.hex
    }

    public static func lookupEntry(name: String, brand: String = "") -> PaintCatalogEntry? {
        CatalogSearch.lookup(
            name: name, brand: brand,
            in: indexes.byName, byNameAndBrand: indexes.byNameAndBrand
        )
    }

    public static func search(_ query: String, limit: Int = 10) -> [PaintCatalogEntry] {
        CatalogSearch.search(entries, query: query, limit: limit)
    }

    private static func loadEntries() -> [PaintCatalogEntry] {
        if let file = CatalogBundleLoader.load("paint_swatch_catalog", as: PaintSwatchCatalogFile.self) {
            let cleaned = file.paints.filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
            if !cleaned.isEmpty { return cleaned }
        }
        return fallbackEntries
    }

    private static let fallbackEntries: [PaintCatalogEntry] = [
        .init(name: "Macragge Blue", brand: "Citadel", type: "Base", hex: "#1c4fa0"),
        .init(name: "Kantor Blue", brand: "Citadel", type: "Base", hex: "#002158"),
        .init(name: "Leadbelcher", brand: "Citadel", type: "Base", hex: "#888c8d"),
        .init(name: "Slaughter Red", brand: "Army Painter", type: "Speedpaint", hex: "#8b0000"),
        .init(name: "Gravelord Grey", brand: "Army Painter", type: "Speedpaint", hex: "#808080"),
    ]
}
