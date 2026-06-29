import Foundation

private struct BasingMaterialCatalogFile: Decodable {
    let version: Int?
    let materials: [BasingMaterialDTO]
}

private struct BasingMaterialDTO: Decodable {
    let name: String
    let brand: String?
    let category: String?
    let line: String?
    let hex: String
}

/// Basing flock, tufts, texture paste, and gel products. Loads `basing_material_catalog.json`.
public enum BasingMaterialCatalog {
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
        if let file = CatalogBundleLoader.load("basing_material_catalog", as: BasingMaterialCatalogFile.self) {
            let cleaned = file.materials
                .filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
                .map { dto in
                    PaintCatalogEntry(
                        name: dto.name,
                        brand: dto.brand,
                        type: "Basing",
                        hex: dto.hex,
                        category: dto.category ?? dto.line
                    )
                }
            if !cleaned.isEmpty { return cleaned }
        }
        return fallbackEntries
    }

    private static let fallbackEntries: [PaintCatalogEntry] = [
        .init(
            name: "Battlefield Grass Green",
            brand: "Army Painter",
            type: "Basing",
            hex: "#4a7040",
            category: "Static Grass"
        ),
        .init(
            name: "Stirland Mud",
            brand: "Citadel",
            type: "Basing",
            hex: "#3e3226",
            category: "Texture Paste"
        ),
    ]
}
