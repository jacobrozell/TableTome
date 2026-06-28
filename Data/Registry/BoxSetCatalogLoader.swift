import Foundation
import TabletomeDomain

/// Loads `Resources/Rules/<bundleName>.json` into a `BoxSetCatalog`.
/// Mirrors `GameSystemsManifestLoader`'s bundle-resolution strategy.
public enum BoxSetCatalogLoader {
    public static func load(
        bundleName: String,
        from bundle: Bundle = .main
    ) throws -> BoxSetCatalog {
        guard let url = resourceURL(bundleName, in: bundle) else {
            throw BoxSetCatalogError.bundleNotFound(bundleName)
        }
        return try JSONDecoder().decode(BoxSetCatalog.self, from: Data(contentsOf: url))
    }

    /// Convenience: load the box sets for a manifest entry, if it declares one.
    public static func load(
        for entry: GameSystemManifestEntry,
        from bundle: Bundle = .main
    ) throws -> BoxSetCatalog? {
        guard let bundleName = entry.boxSetBundleName else { return nil }
        return try load(bundleName: bundleName, from: bundle)
    }

    private static func resourceURL(_ name: String, in bundle: Bundle) -> URL? {
        for subdirectory in [nil as String?, "Rules"] {
            if let url = bundle.url(
                forResource: name,
                withExtension: "json",
                subdirectory: subdirectory
            ) {
                return url
            }
        }
        return nil
    }
}

public enum BoxSetCatalogError: Error, Equatable, Sendable {
    case bundleNotFound(String)
}
