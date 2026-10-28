import SwiftUI
import TabletomeDomain
import TabletomeData

struct MatchupSection: View {
    let gameSystemId: GameSystemId
    let showsSpearheadArmyPicker: Bool
    let boxSets: [BoxSet]
    @Binding var selectedBoxId: String
    let onUseStarterMatchup: () -> Void
    let onContinueToSetup: () -> Void
    let featuredArmies: GuidedMatchFeaturedArmies
    let matchupSummary: String?
    let catalog: SpearheadCatalog?
    let hasBothArmies: Bool

    var body: some View {
        Group {
            if hasBothArmies, let summary = matchupSummary {
                Section {
                    TTHeroCard(eyebrow: String(localized: "TODAY'S MATCH"), title: summary) {
                        Button(String(localized: "Continue to Setup"), action: onContinueToSetup)
                            .buttonStyle(.ttSecondary)
                            .accessibilityIdentifier("guidedMatch.continueToSetup")
                    }
                    .accessibilityIdentifier("guidedMatch.matchupSummary")
                    .listHeroCardRow()
                }
            } else if gameSystemId == .aosSpearhead, showsSpearheadArmyPicker {
                SpearheadStarterBoxSection(
                    boxSets: boxSets,
                    selectedBoxId: $selectedBoxId,
                    catalog: catalog,
                    onUseStarterMatchup: onUseStarterMatchup
                )
            } else if showsSpearheadArmyPicker {
                LegacyMatchupSection(
                    featuredArmies: featuredArmies,
                    catalog: catalog,
                    onUseStarterMatchup: onUseStarterMatchup
                )
            }
        }
    }
}

private struct LegacyMatchupSection: View {
    let featuredArmies: GuidedMatchFeaturedArmies
    let catalog: SpearheadCatalog?
    let onUseStarterMatchup: () -> Void

    var body: some View {
        Section {
            TTHeroCard(
                eyebrow: String(localized: "STARTER SET"),
                title: featuredArmies.starterMatchupTitle,
                subtitle: featuredArmies.starterSetDescription
            ) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    armyLine(isPlayerOne: true, selection: featuredArmies.featuredConfig.playerOne)
                    MatchupVersusBadge()
                    armyLine(isPlayerOne: false, selection: featuredArmies.featuredConfig.playerTwo)
                    Button(String(localized: "Use Starter Matchup"), action: onUseStarterMatchup)
                        .buttonStyle(.ttPrimary)
                }
            }
            .listHeroCardRow()
            .accessibilityIdentifier("guidedMatch.starterMatchup")
            .accessibilityLabel(
                String(localized: "Use Starter Matchup, \(featuredArmies.starterMatchupTitle)")
            )
            .accessibilityHint(
                String(
                    localized: "Fills both armies, recommended picks, and defaults attacker to Player 1 — change on Setup if your roll differed."
                )
            )
        }
    }

    private func armyLine(isPlayerOne: Bool, selection: StarterArmySelection) -> some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            TTPlayerToken(isPlayerOne: isPlayerOne, size: 28)
            Text(armyName(selection))
                .font(TTFont.callout)
                .foregroundStyle(TTColor.inkPrimary)
        }
    }

    private func armyName(_ selection: StarterArmySelection) -> String {
        guard let catalog,
              let faction = catalog.factions.first(where: { $0.id == selection.factionId }),
              let army = faction.armies.first(where: { $0.id == selection.armyId }) else {
            return selection.playerName.isEmpty ? String(localized: "Starter army") : selection.playerName
        }
        return army.name
    }
}
