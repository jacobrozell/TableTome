import SwiftUI
import TabletomeDomain

struct PlayerSidebarRow: View {
    let label: String
    let selection: PlayerArmySelection
    let catalog: SpearheadCatalog
    let destination: GuidedMatchDestination

    var body: some View {
        PlayerArmyRow(label: label, selection: selection, catalog: catalog)
            .tag(destination)
            .accessibilityIdentifier(destination == .playerOne ? "guidedMatch.playerOne" : "guidedMatch.playerTwo")
            .accessibilityLabel(playerSidebarAccessibilityLabel)
            .accessibilityHint(String(localized: "Opens army selection for this player."))
            .accessibilityAddTraits(.isButton)
    }

    private var playerSidebarAccessibilityLabel: String {
        let name = selection.playerName.isEmpty ? label : selection.playerName
        return "\(name), \(playerArmySubtitle)"
    }

    private var playerArmySubtitle: String {
        guard let faction = catalog.factions.first(where: { $0.id == selection.factionId }),
              let army = faction.armies.first(where: { $0.id == selection.armyId }) else {
            return String(localized: "Tap to choose faction and army")
        }
        return "\(faction.name) — \(army.name)"
    }
}

struct PlayersSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let catalog: SpearheadCatalog
    let useSplitSelection: Bool
    @Binding var showsOwnListsSection: Bool

    var body: some View {
        Section {
            DisclosureGroup(
                isExpanded: Binding(
                    get: { showsOwnListsSection || viewModel.matchState.hasBothArmies },
                    set: { showsOwnListsSection = $0 }
                )
            ) {
                if useSplitSelection {
                    PlayerSidebarRow(
                        label: String(localized: "Player 1"),
                        selection: viewModel.matchState.playerOne,
                        catalog: catalog,
                        destination: .playerOne
                    )
                    PlayerSidebarRow(
                        label: String(localized: "Player 2"),
                        selection: viewModel.matchState.playerTwo,
                        catalog: catalog,
                        destination: .playerTwo
                    )
                } else {
                    NavigationLink(value: GuidedMatchDestination.playerOne) {
                        PlayerArmyRow(
                            label: String(localized: "Player 1"),
                            selection: viewModel.matchState.playerOne,
                            catalog: catalog
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("guidedMatch.playerOne")

                    NavigationLink(value: GuidedMatchDestination.playerTwo) {
                        PlayerArmyRow(
                            label: String(localized: "Player 2"),
                            selection: viewModel.matchState.playerTwo,
                            catalog: catalog
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("guidedMatch.playerTwo")
                }
            } label: {
                Text(String(localized: "We brought our own lists"))
                    .font(.subheadline.weight(.semibold))
            }
        } footer: {
            if !viewModel.matchState.hasBothArmies {
                Text(
                    String(
                        localized: "Optional — most beginners tap Use Starter Matchup above to load both armies."
                    )
                )
            } else {
                Text(
                    String(
                        localized: "Armies are set. Open the Setup tab for mission, deployment, and battlefield steps."
                    )
                )
            }
        }
    }
}
