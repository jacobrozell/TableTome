import SwiftUI
import TabletomeDomain

/// Army-specific deployment reminders on setup step 5 (e.g. Skaven tunnels — §19.2).
struct SpearheadDeploymentGotchasSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel

    private static let deploymentGotchaIds: Set<String> = [
        "lurking-vermintide"
    ]

    private var gotchas: [SpearheadGotcha] {
        var seen = Set<String>()
        return [viewModel.matchState.playerOne.armyId, viewModel.matchState.playerTwo.armyId]
            .filter { !$0.isEmpty }
            .flatMap { SpearheadGotchaCatalog.gotchas(for: $0) }
            .filter { Self.deploymentGotchaIds.contains($0.id) }
            .filter { seen.insert($0.id).inserted }
    }

    var body: some View {
        if !gotchas.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Label(String(localized: "Before round 1 — army deployment rules"), systemImage: "flag.checkered")
                    .font(.headline)

                Text(
                    String(
                        localized: """
                        Resolve these once-per-battle deployment rules before the first turn — easy to forget at the table.
                        """
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

                ForEach(gotchas) { gotcha in
                    ArmyGotchaCard(gotcha: gotcha)
                }
            }
            .surfaceCard()
            .accessibilityIdentifier("guidedMatch.deploymentGotchas")
        }
    }
}
