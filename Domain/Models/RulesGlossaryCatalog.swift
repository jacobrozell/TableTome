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
        return entries(gameSystemId: gameSystemId, ruleSections: ruleSections).filter { entry in
            lower.contains(entry.term.lowercased())
        }
    }
}
