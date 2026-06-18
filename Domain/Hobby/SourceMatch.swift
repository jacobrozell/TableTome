import Foundation

/// Fuzzy paint-source ↔ unit-source matching. Ported verbatim from MiniMuster
/// `Domain/SourceMatch.swift` (`js/core/source-match.js`).
public enum SourceMatch {
    /// Split a source on `+`, trimmed, lowercased, non-empty.
    public static func parts(_ source: String) -> [String] {
        source.split(separator: "+")
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            .filter { !$0.isEmpty }
    }

    /// True if a paint source overlaps a unit source (substring either direction).
    public static func matches(_ paintSource: String, _ unitSource: String) -> Bool {
        let us = unitSource.lowercased()
        guard !us.isEmpty else { return false }
        return parts(paintSource).contains { us.contains($0) || $0.contains(us) }
    }
}
