import SwiftUI
import TabletomeDomain
import TabletomeData

struct MatchupSection: View {
    let gameSystemId: GameSystemId
    let showsSpearheadArmyPicker: Bool
    let boxSets: [BoxSet]
    @Binding var selectedBoxId: String
    let onUseStarterMatchup: () -> Void
    let featuredArmies: GuidedMatchFeaturedArmies
    let matchupSummary: String?

    var body: some View {
        Group {
            if gameSystemId == .aosSpearhead, showsSpearheadArmyPicker {
                SpearheadStarterBoxSection(
                    boxSets: boxSets,
                    selectedBoxId: $selectedBoxId,
                    onUseStarterMatchup: onUseStarterMatchup
                )
            } else if showsSpearheadArmyPicker {
                LegacyMatchupSection(
                    featuredArmies: featuredArmies,
                    onUseStarterMatchup: onUseStarterMatchup
                )
            }

            if let summary = matchupSummary {
                Section(String(localized: "Today's Match")) {
                    Label {
                        Text(summary)
                            .font(.subheadline.weight(.medium))
                            .fixedSize(horizontal: false, vertical: true)
                    } icon: {
                        Image(systemName: "person.2.fill")
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityIdentifier("guidedMatch.matchupSummary")
                }
            }
        }
    }
}

private struct LegacyMatchupSection: View {
    let featuredArmies: GuidedMatchFeaturedArmies
    let onUseStarterMatchup: () -> Void

    var body: some View {
        Section {
            Button(action: onUseStarterMatchup) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Label {
                        Text(featuredArmies.starterMatchupTitle)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                    } icon: {
                        Image(systemName: "flag.2.crossed.fill")
                            .foregroundStyle(Color.accentOnSurface)
                    }
                    Text(featuredArmies.starterSetDescription)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(String(localized: "Use Starter Matchup"))
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                        .prominentButtonLabelStyle()
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("guidedMatch.starterMatchup")
            .accessibilityLabel(
                String(
                    localized: "Use Starter Matchup, \(featuredArmies.starterMatchupTitle)"
                )
            )
            .accessibilityHint(
                String(
                    localized: "Fills both armies, recommended picks, and defaults attacker to Player 1 — change on Setup if your roll differed."
                )
            )
        } header: {
            Text(String(localized: "Starter Set"))
        }
    }
}
