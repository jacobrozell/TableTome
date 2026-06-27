import Foundation

public enum GlossaryTextSegment: Equatable, Sendable {
    case plain(String)
    case linked(text: String, entryId: String)
}

private struct GlossaryTextMatchCandidate: Equatable {
    let entryId: String
    let range: Range<String.Index>
    let matchedText: String
}

public enum GlossaryTextLinker {
    public static func segments(
        in text: String,
        gameSystemId: String,
        ruleSections: [RuleSection] = []
    ) -> [GlossaryTextSegment] {
        let entries = RulesGlossaryCatalog.entriesReferenced(
            in: text,
            gameSystemId: gameSystemId,
            ruleSections: ruleSections
        )
        guard !entries.isEmpty else { return [.plain(text)] }

        var candidates: [GlossaryTextMatchCandidate] = []
        for entry in entries {
            for phrase in RulesGlossaryCatalog.linkablePhrases(for: entry, gameSystemId: gameSystemId) {
                guard !phrase.isEmpty else { continue }
                var searchStart = text.startIndex
                while searchStart < text.endIndex,
                      let range = text.range(
                          of: phrase,
                          options: [.caseInsensitive, .diacriticInsensitive],
                          range: searchStart..<text.endIndex
                      ) {
                    candidates.append(
                        GlossaryTextMatchCandidate(
                            entryId: entry.id,
                            range: range,
                            matchedText: String(text[range])
                        )
                    )
                    searchStart = range.upperBound
                }
            }
        }

        let selected = selectNonOverlapping(candidates)
        guard !selected.isEmpty else { return [.plain(text)] }

        var segments: [GlossaryTextSegment] = []
        var cursor = text.startIndex
        for match in selected {
            if cursor < match.range.lowerBound {
                segments.append(.plain(String(text[cursor..<match.range.lowerBound])))
            }
            segments.append(.linked(text: match.matchedText, entryId: match.entryId))
            cursor = match.range.upperBound
        }
        if cursor < text.endIndex {
            segments.append(.plain(String(text[cursor...])))
        }
        return segments
    }

    private static func selectNonOverlapping(_ candidates: [GlossaryTextMatchCandidate]) -> [GlossaryTextMatchCandidate] {
        let sorted = candidates.sorted { lhs, rhs in
            if lhs.range.lowerBound != rhs.range.lowerBound {
                return lhs.range.lowerBound < rhs.range.lowerBound
            }
            return lhs.matchedText.count > rhs.matchedText.count
        }

        var selected: [GlossaryTextMatchCandidate] = []
        var occupied: [Range<String.Index>] = []
        for candidate in sorted {
            guard !occupied.contains(where: { $0.overlaps(candidate.range) }) else { continue }
            selected.append(candidate)
            occupied.append(candidate.range)
        }
        return selected.sorted { $0.range.lowerBound < $1.range.lowerBound }
    }
}
