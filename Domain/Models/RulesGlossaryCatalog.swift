import Foundation

public enum RulesGlossaryCatalog {
    public static func entries(
        gameSystemId: String,
        ruleSections: [RuleSection] = []
    ) -> [RulesGlossaryEntry] {
        let context = GameSystemPlayContext.context(for: gameSystemId)
        if context.isSpearhead {
            return SpearheadRulesGlossary.entries
        }
        if context.isCombatPatrol {
            return CombatPatrolRulesGlossary.entries
        }
        return ruleSections
            .filter { $0.category == .glossary }
            .map { RulesGlossaryEntry(id: $0.id, term: $0.title, definition: $0.content) }
    }

    public static func entriesReferenced(
        in text: String,
        gameSystemId: String,
        ruleSections: [RuleSection] = []
    ) -> [RulesGlossaryEntry] {
        let context = GameSystemPlayContext.context(for: gameSystemId)
        if context.isSpearhead {
            return SpearheadRulesGlossary.entriesReferenced(in: text)
        }
        let lower = text.lowercased()
        let allEntries = entries(gameSystemId: gameSystemId, ruleSections: ruleSections)
        var matched = allEntries.filter { lower.contains($0.term.lowercased()) }
        if context.isWh40k11e {
            for entryId in wh40k11eAliasEntryIdsMatching(text: lower) {
                guard let entry = allEntries.first(where: { $0.id == entryId }),
                      !matched.contains(where: { $0.id == entry.id }) else { continue }
                matched.append(entry)
            }
        }
        return matched.sorted { $0.term.localizedCaseInsensitiveCompare($1.term) == .orderedAscending }
    }

    public static func linkablePhrases(for entry: RulesGlossaryEntry, gameSystemId: String) -> [String] {
        var phrases = [entry.term]
        let context = GameSystemPlayContext.context(for: gameSystemId)
        if context.isSpearhead {
            phrases.append(contentsOf: SpearheadRulesGlossary.aliasPhrases(for: entry.id))
        }
        if context.isCombatPatrol {
            phrases.append(contentsOf: CombatPatrolRulesGlossary.aliasPhrases(for: entry.id))
        }
        var seen = Set<String>()
        return phrases
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .sorted { $0.count > $1.count }
            .filter { phrase in
                let key = phrase.lowercased()
                guard !seen.contains(key) else { return false }
                seen.insert(key)
                return true
            }
    }

    private static let wh40k11eAliasPatterns: [String: String] = [
        "strategic reserves": "glossary-strategic-reserves-11e",
        "deep strike": "glossary-deep-strike-11e",
        "ingress": "glossary-ingress-11e",
        "incursion": "glossary-incursion-11e",
        "force disposition": "glossary-force-disposition",
        "detachment points": "glossary-detachment-points",
        "coherency": "glossary-coherency-11e",
        "consolidation": "glossary-consolidation-11e",
        "fall back": "glossary-fall-back-11e",
        "indirect fire": "glossary-indirect-fire-11e"
    ]

    private static func wh40k11eAliasEntryIdsMatching(text lower: String) -> [String] {
        wh40k11eAliasPatterns.compactMap { pattern, entryId in
            lower.contains(pattern) ? entryId : nil
        }
    }
}
