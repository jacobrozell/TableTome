import Foundation

/// SF Symbol for a bundled catalog unit category (Characters, Infantry, etc.).
enum CatalogCategorySymbol {
    static func systemImage(for category: String) -> String {
        switch category.lowercased() {
        case "character", "characters":
            "person.fill"
        case "infantry", "battleline":
            "figure.stand"
        case "vehicle", "vehicles":
            "car.fill"
        case "monster", "monsters", "beast", "beasts":
            "pawprint.fill"
        case "mounted":
            "figure.equestrian.sports"
        case "fortification", "fortifications":
            "building.columns.fill"
        default:
            "square.grid.2x2"
        }
    }
}
