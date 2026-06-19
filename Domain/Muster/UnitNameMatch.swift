import Foundation

public enum UnitNameMatch {
    /// Normalize for comparison: lowercase, collapse whitespace, strip first "(...)" group.
    public static func normalize(_ name: String) -> String {
        var s = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let inner = ModelCount.firstParenGroup(name) {
            s = s.replacingOccurrences(of: "(\(inner))", with: "")
        }
        s = s.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        return s.trimmingCharacters(in: .whitespaces)
    }

    /// True if collection unit name matches catalog entry name or any alias.
    public static func matches(collectionUnitName: String, catalogName: String, aliases: [String]) -> Bool {
        let collection = normalize(collectionUnitName)
        guard !collection.isEmpty else { return false }
        let candidates = [catalogName] + aliases
        for raw in candidates {
            let normalized = normalize(raw)
            if collection == normalized { return true }
            if collection.contains(normalized) || normalized.contains(collection) { return true }
        }
        return false
    }
}
