import SwiftUI
import TabletomeDomain
import TabletomeData

extension GuidedMatchView {
    // MARK: - iPad

    @ViewBuilder
    func regularLayout(catalog: SpearheadCatalog) -> some View {
        NavigationSplitView {
            List(selection: $selectedDestination) {
                guidedMatchSections(catalog: catalog, useSplitSelection: true)
            }
            .listStyle(.sidebar)
            .navigationTitle(String(localized: "Guided Match"))
            .navigationSplitViewColumnWidth(
                min: isPadLandscape ? 220 : 260,
                ideal: isPadLandscape ? 260 : 300,
                max: isPadLandscape ? 300 : 340
            )
        } detail: {
            guidedMatchDetail(catalog: catalog)
                .modifier(GuidedMatchDetailWidth(destination: selectedDestination))
        }
        .onChange(of: viewModel.matchState.hasBothArmies) { _, hasBoth in
            guard hasBoth, usesPadSplitNavigation, selectedDestination == nil else { return }
            selectedDestination = .battleTracker
        }
    }

    @ViewBuilder
    func guidedMatchDetail(catalog: SpearheadCatalog) -> some View {
        if let selectedDestination {
            guidedMatchScreen(
                destination: selectedDestination,
                catalog: catalog,
                dismissesArmySelectionOnSave: false
            )
        } else {
            guidedMatchPadWelcome(catalog: catalog)
        }
    }

    @ViewBuilder
    func guidedMatchPadWelcome(catalog: SpearheadCatalog) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                guidedMatchPlaceholder(
                    title: String(localized: "Start here"),
                    message: padWelcomeMessage
                )

                if !viewModel.matchState.hasBothArmies {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                        Button(String(localized: "Use Starter Matchup")) {
                            useStarterMatchup(navigateToSetup: false)
                            selectedDestination = .battleTracker
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                        .accessibilityIdentifier("guidedMatch.starterMatchup.detail")
                        .accessibilityLabel(String(localized: "Use Starter Matchup"))
                        .accessibilityHint(
                            String(
                                localized: "Fills both armies and recommended enhancement and objective picks."
                            )
                        )

                        DisclosureGroup(String(localized: "We brought our own lists")) {
                            VStack(spacing: DesignTokens.Spacing.sm) {
                                Button {
                                    selectedDestination = .playerOne
                                } label: {
                                    PlayerArmyRow(
                                        label: String(localized: "Player 1"),
                                        selection: viewModel.matchState.playerOne,
                                        catalog: catalog
                                    )
                                }
                                .buttonStyle(.bordered)
                                .accessibilityIdentifier("guidedMatch.playerOne.detail")

                                Button {
                                    selectedDestination = .playerTwo
                                } label: {
                                    PlayerArmyRow(
                                        label: String(localized: "Player 2"),
                                        selection: viewModel.matchState.playerTwo,
                                        catalog: catalog
                                    )
                                }
                                .buttonStyle(.bordered)
                                .accessibilityIdentifier("guidedMatch.playerTwo.detail")
                            }
                            .padding(.top, DesignTokens.Spacing.sm)
                        }
                        .font(.subheadline.weight(.semibold))
                    }
                }
            }
            .padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(String(localized: "Guided Match"))
    }

    var padWelcomeMessage: String {
        switch gameSystemId {
        case .wh40k10eCp:
            return String(
                localized: """
                Tap Use Starter Matchup for Space Marines vs Tyranids, or pick the Combat Patrol boxes you own below.
                """
            )
        case .wh40k11e:
            return String(
                localized: """
                Tap Use Starter Matchup for the Armageddon starter armies, or pick each player's force below.
                """
            )
        case .scTmg:
            return String(
                localized: """
                Tap Use Starter Matchup for Raynor vs Kerrigan, or pick each player's faction below.
                """
            )
        default:
            return String(
                localized: """
                New to tabletop battles? Tap Use Starter Matchup to load both armies, or pick each player below.
                """
            )
        }
    }
}
