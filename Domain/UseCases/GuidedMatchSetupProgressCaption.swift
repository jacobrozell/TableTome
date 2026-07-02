import Foundation

/// Plain-language setup progress for Play home continuation cards.
public enum GuidedMatchSetupProgressCaption {
    public static func summary(
        matchState: GuidedMatchState,
        steps: [MatchSetupStep]
    ) -> String? {
        guard !steps.isEmpty else { return nil }

        let sortedSteps = steps.sorted { $0.order < $1.order }
        let completedIds = matchState.completedStepIds
        let completedCount = sortedSteps.filter { completedIds.contains($0.id) }.count
        guard completedCount < sortedSteps.count else { return nil }

        var lines: [String] = [
            String(localized: "Setup: \(completedCount) of \(sortedSteps.count) complete")
        ]

        let completedTitles = sortedSteps
            .filter { completedIds.contains($0.id) }
            .map(\.title)
        if !completedTitles.isEmpty {
            lines.append(
                String(localized: "Done: \(completedTitles.joined(separator: " · "))")
            )
        }

        if let next = sortedSteps.first(where: { !completedIds.contains($0.id) }) {
            lines.append(String(localized: "Next: \(next.title)"))
        }

        return lines.joined(separator: "\n")
    }
}
