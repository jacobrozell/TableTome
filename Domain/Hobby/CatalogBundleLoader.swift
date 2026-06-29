import Foundation

/// Shared JSON catalog loader for bundled `Resources/Catalogs` files.
enum CatalogBundleLoader {
    static func load<T: Decodable>(_ resourceName: String, as type: T.Type) -> T? {
        for bundle in [Bundle.main] + Bundle.allBundles {
            let url =
                bundle.url(forResource: resourceName, withExtension: "json", subdirectory: "Catalogs")
                ?? bundle.url(forResource: resourceName, withExtension: "json")
            guard let url, let data = try? Data(contentsOf: url) else { continue }
            if let decoded = try? JSONDecoder().decode(T.self, from: data) { return decoded }
        }
        return nil
    }
}
