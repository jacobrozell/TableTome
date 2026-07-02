import SwiftUI
import TabletomeDomain

struct SpearheadChooseArmiesStep: View {
    @ObservedObject var viewModel: GuidedMatchViewModel

    var body: some View {
        Group {
            if viewModel.matchState.hasBothArmies, let summary = viewModel.matchupSummary {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    SectionHeader(title: String(localized: "Selected Matchup"), systemImage: "person.2.fill")
                    Text(summary)
                        .font(.subheadline.weight(.medium))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(
                        String(
                            localized: "Reset the match from the toolbar to change armies or pick a different box."
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .surfaceCard()
            }
        }
    }
}
