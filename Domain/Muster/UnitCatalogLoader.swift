import Foundation

public enum UnitCatalogLoader {
    private(set) nonisolated(unsafe) static var manifest: UnitCatalogManifest?
    nonisolated(unsafe) private static var cache: [String: [CatalogUnit]] = [:]
    nonisolated(unsafe) private static var byId: [String: CatalogUnit] = [:]

    /// Call once from MusterTab.onAppear or app init (idempotent).
    public static func loadIfNeeded() {
        guard manifest == nil else { return }
        manifest = decode("manifest", UnitCatalogManifest.self)
        let index = decode("index", UnitCatalogIndex.self)
        for (_, path) in index?.factions ?? [:] {
            let file = decodePath(path, FactionCatalogFile.self)
            let key = factionKey(game: file?.game ?? "", faction: file?.faction ?? "")
            let units = file?.units ?? []
            cache[key] = units
            for unit in units { byId[unit.id] = unit }
        }
    }

    public static var version: String { manifest?.version ?? "0" }

    public static func units(game: String, faction: String) -> [CatalogUnit] {
        loadIfNeeded()
        return cache[factionKey(game: game, faction: faction)] ?? []
    }

    public static func unit(id: String) -> CatalogUnit? {
        loadIfNeeded()
        return byId[id]
    }

    public static func search(game: String, faction: String, query: String) -> [CatalogUnit] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        let all = units(game: game, faction: faction)
        guard !q.isEmpty else { return all }
        return all.filter { unit in
            unit.name.lowercased().contains(q)
            || unit.category.lowercased().contains(q)
            || unit.keywords.contains { $0.lowercased().contains(q) }
            || unit.aliases.contains { $0.lowercased().contains(q) }
        }
    }

    private static func factionKey(game: String, faction: String) -> String {
        "\(game):\(FactionResolver.normalize(faction))"
    }

    private static func decode<T: Decodable>(_ name: String, _ type: T.Type) -> T? {
        let candidates: [URL?] = [
            Bundle.main.url(forResource: name, withExtension: "json", subdirectory: "Catalogs"),
            Bundle.main.url(forResource: name, withExtension: "json"),
        ]
        for url in candidates.compactMap({ $0 }) {
            if let value = try? JSONDecoder().decode(T.self, from: Data(contentsOf: url)) {
                return value
            }
        }
        return nil
    }

    private static func decodePath<T: Decodable>(_ path: String, _ type: T.Type) -> T? {
        let parts = path.split(separator: "/")
        guard parts.count == 2 else { return nil }
        let fileName = String(parts[1].dropLast(5))
        let candidates: [URL?] = [
            Bundle.main.url(forResource: fileName, withExtension: "json",
                            subdirectory: "Catalogs/\(parts[0])"),
            Bundle.main.url(forResource: fileName, withExtension: "json"),
        ]
        for url in candidates.compactMap({ $0 }) {
            if let value = try? JSONDecoder().decode(T.self, from: Data(contentsOf: url)) {
                return value
            }
        }
        return nil
    }
}
