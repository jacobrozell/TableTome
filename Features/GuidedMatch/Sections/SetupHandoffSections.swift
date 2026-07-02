import SwiftUI
import TabletomeDomain

struct SetupCompleteHandoffSection: View {
    let setupIsComplete: Bool
    @Binding var dismissedSetupCompleteHandoff: Bool
    @Binding var hubTab: GuidedMatchHubTab

    var body: some View {
        if setupIsComplete, !dismissedSetupCompleteHandoff {
            Section {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Label(String(localized: "Setup complete"), systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(Color.accentOnSurface)

                    Text(
                        String(
                            localized: """
                            Open the Battle tab when you're at the table. Roll physical dice — Tabletome tracks phases and score.
                            """
                        )
                    )
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                    Button(String(localized: "Open Battle")) {
                        hubTab = .battle
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("guidedMatch.setupComplete.openBattle")

                    Button(String(localized: "Dismiss")) {
                        dismissedSetupCompleteHandoff = true
                    }
                    .buttonStyle(.plain)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("guidedMatch.setupComplete.dismiss")
                }
                .accentHighlightCard()
                .listHeroCardRow()
            }
        }
    }
}

struct StarterMatchupHandoffSection: View {
    let showsStarterMatchupHandoff: Bool
    @Binding var dismissedStarterMatchupHandoff: Bool
    let matchupSummary: String?
    let nextStepTitle: String?
    let attackerLabel: String?
    let usesSpearheadCopy: Bool
    let onDismiss: () -> Void

    var body: some View {
        if showsStarterMatchupHandoff,
           !dismissedStarterMatchupHandoff,
           let summary = matchupSummary {
            Section {
                StarterMatchupHandoffBanner(
                    matchupSummary: summary,
                    nextStepTitle: nextStepTitle,
                    attackerLabel: attackerLabel,
                    usesSpearheadCopy: usesSpearheadCopy,
                    onDismiss: onDismiss
                )
                .listHeroCardRow()
            }
        }
    }
}
