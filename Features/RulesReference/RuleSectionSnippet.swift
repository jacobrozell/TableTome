import SwiftUI

struct RuleSnippetMatch: Equatable {
    let text: String
    let highlight: Range<String.Index>?

    var highlightedText: String? {
        guard let highlight else { return nil }
        return String(text[highlight])
    }
}

/// First-sentence and search-window helpers for rules list subtitles.
enum RuleSectionSnippet {
    static let limit = 70

    static func firstSentence(of content: String, limit: Int = RuleSectionSnippet.limit) -> String {
        let flat = flatten(content)
        guard !flat.isEmpty else { return "" }
        let sentence: String
        if let end = flat.firstIndex(where: { $0 == "." || $0 == "!" || $0 == "?" }) {
            sentence = String(flat[...end])
        } else {
            sentence = flat
        }
        return clip(sentence, limit: limit)
    }

    static func match(in content: String, query: String, limit: Int = RuleSectionSnippet.limit) -> RuleSnippetMatch? {
        let flat = flatten(content)
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty, let found = flat.range(of: needle, options: [.caseInsensitive]) else {
            return nil
        }
        return window(in: flat, around: found, limit: limit)
    }

    static func attributedSubtitle(content: String, query: String) -> AttributedString {
        if let found = match(in: content, query: query), let highlight = found.highlight {
            let text = found.text
            let prefix = String(text[..<highlight.lowerBound])
            let mid = String(text[highlight])
            let suffix = String(text[highlight.upperBound...])
            var result = baseAttributed(prefix)
            var emphasis = AttributedString(mid)
            emphasis.font = TTFont.bodyEmphasis
            emphasis.foregroundColor = TTColor.inkPrimary
            result.append(emphasis)
            result.append(baseAttributed(suffix))
            return result
        }
        return baseAttributed(firstSentence(of: content))
    }

    static func flatten(_ content: String) -> String {
        content
            .replacingOccurrences(of: "\n", with: " ")
            .split(separator: " ", omittingEmptySubsequences: true)
            .joined(separator: " ")
    }

    private static func baseAttributed(_ text: String) -> AttributedString {
        var value = AttributedString(text)
        value.font = TTFont.subheadline
        value.foregroundColor = TTColor.inkSecondary
        return value
    }

    private static func clip(_ text: String, limit: Int) -> String {
        guard text.count > limit else { return text }
        let budget = max(1, limit - 1)
        var end = text.index(text.startIndex, offsetBy: budget, limitedBy: text.endIndex) ?? text.endIndex
        if end < text.endIndex {
            let head = text[..<end]
            if let space = head.lastIndex(of: " "),
               text.distance(from: text.startIndex, to: space) >= budget / 2 {
                end = space
            }
        }
        return String(text[..<end]).trimmingCharacters(in: .whitespaces) + "…"
    }

    private static func window(in text: String, around match: Range<String.Index>, limit: Int) -> RuleSnippetMatch {
        if text.count <= limit {
            return RuleSnippetMatch(text: text, highlight: match)
        }

        let query = String(text[match])
        var start = match.lowerBound
        var end = match.upperBound
        var takeLeft = true

        func renderedCount(start: String.Index, end: String.Index) -> Int {
            let prefix = start > text.startIndex ? 1 : 0
            let suffix = end < text.endIndex ? 1 : 0
            return text.distance(from: start, to: end) + prefix + suffix
        }

        while renderedCount(start: start, end: end) < limit {
            let canLeft = start > text.startIndex
            let canRight = end < text.endIndex
            if !canLeft, !canRight { break }

            let nextStart: String.Index
            let nextEnd: String.Index
            if takeLeft, canLeft {
                nextStart = text.index(before: start)
                nextEnd = end
            } else if canRight {
                nextStart = start
                nextEnd = text.index(after: end)
            } else {
                nextStart = text.index(before: start)
                nextEnd = end
            }
            if renderedCount(start: nextStart, end: nextEnd) > limit { break }
            start = nextStart
            end = nextEnd
            takeLeft.toggle()
        }

        if start < match.lowerBound, start > text.startIndex {
            let head = text[start..<match.lowerBound]
            if let space = head.firstIndex(of: " ") {
                let next = text.index(after: space)
                if next <= match.lowerBound {
                    start = next
                }
            }
        }
        if end > match.upperBound, end < text.endIndex {
            let tail = text[match.upperBound..<end]
            if let space = tail.lastIndex(of: " ") {
                end = space
            }
        }

        let prefixEllipsis = start > text.startIndex
        let suffixEllipsis = end < text.endIndex
        var snippet = String(text[start..<end]).trimmingCharacters(in: .whitespacesAndNewlines)
        if prefixEllipsis {
            snippet = "…" + snippet
        }
        if suffixEllipsis {
            snippet += "…"
        }
        if snippet.count > limit {
            snippet = String(snippet.prefix(limit))
        }
        return RuleSnippetMatch(
            text: snippet,
            highlight: snippet.range(of: query, options: [.caseInsensitive])
        )
    }
}
