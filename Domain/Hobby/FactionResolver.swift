import Foundation

/// Ported from MiniMuster `Domain/Factions/FactionResolver.swift`. The `Army`
/// extension is intentionally dropped — once SwiftData models land in Phase 4 they
/// conform to `ArmyLike` and the convenience extension comes with them.
public enum FactionResolver {
    public static let fallbackColor = "#888"

    public static func compositeKey(game: String, faction: String) -> String {
        let g = game.trimmingCharacters(in: .whitespaces)
        let f = faction.trimmingCharacters(in: .whitespaces)
        return (!g.isEmpty && !f.isEmpty) ? "\(g):\(f)" : f
    }

    private static let labelLC: [String: String] = {
        var map: [String: String] = [:]
        for d in FactionDefs.all {
            map[d.label.lowercased()] = d.label
            for a in d.aliases { map[a.lowercased()] = d.label }
        }
        for (alias, label) in FactionDefs.aliases {
            map[alias.lowercased()] = label
        }
        return map
    }()

    private static let compositeDefaults: [String: (String, String)] = {
        var map: [String: (String, String)] = [:]
        for d in FactionDefs.all {
            for game in d.games {
                map[compositeKey(game: game, faction: d.label)] = (d.crest, d.color)
            }
        }
        return map
    }()

    private static let flatDefaults: [String: (String, String)] = {
        var map: [String: (String, String)] = [:]
        for d in FactionDefs.all {
            map[d.label] = (d.crest, d.color)
            for a in d.aliases { map[a] = (d.crest, d.color) }
        }
        return map
    }()

    public static func normalize(_ faction: String) -> String {
        let raw = faction.trimmingCharacters(in: .whitespaces)
        if raw.isEmpty { return "" }
        return FactionDefs.aliases[raw] ?? labelLC[raw.lowercased()] ?? raw
    }

    public static let canonicalByGame: [String: [String]] = {
        var map: [String: [String]] = [:]
        for d in FactionDefs.all {
            for game in d.games { map[game, default: []].append(d.label) }
        }
        return map
    }()

    public static func resolve(faction: String,
                               game: String,
                               overrides: [FactionPresetOverride]) -> (crest: String, color: String) {
        let label = normalize(faction)
        let g = game.trimmingCharacters(in: .whitespaces)

        let overrideMap = Dictionary(overrides.map { ($0.key, ($0.crest, $0.hex)) },
                                     uniquingKeysWith: { _, new in new })
        if let o = overrideMap[compositeKey(game: g, faction: label)] {
            return (o.0, o.1)
        }

        if !g.isEmpty {
            if let hit = compositeDefaults[compositeKey(game: g, faction: label)] {
                return (hit.0, hit.1)
            }
        } else if let hit = flatDefaults[label] {
            return (hit.0, hit.1)
        }

        let abbr = label.isEmpty ? "??" : String(label.prefix(2)).uppercased()
        return (abbr, fallbackColor)
    }

    public static func isFallback(_ color: String) -> Bool { color == fallbackColor }
}
