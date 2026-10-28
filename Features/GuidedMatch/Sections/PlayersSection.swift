import SwiftUI
import TabletomeDomain

struct PlayerSidebarRow: View {
    let label: String
    let selection: PlayerArmySelection
    let catalog: SpearheadCatalog
    var profile: PlayerProfile?
    var isPrimaryProfile: Bool = false
    let destination: GuidedMatchDestination

    var body: some View {
        PlayerArmyRow(
            label: label,
            isPlayerOne: destination == .playerOne,
            selection: selection,
            catalog: catalog,
            profile: profile,
            isPrimaryProfile: isPrimaryProfile
        )
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
    var householdProfiles: [PlayerProfile] = []
    var primaryProfileId: UUID?
    @Binding var showsOwnListsSection: Bool

    private func profile(for selection: PlayerArmySelection) -> PlayerProfile? {
        guard let profileId = selection.profileId else { return nil }
        return householdProfiles.first { $0.id == profileId }
    }

    var body: some View {
        Section {
            if useSplitSelection {
                PlayerSidebarRow(
                    label: String(localized: "Player 1"),
                    selection: viewModel.matchState.playerOne,
                    catalog: catalog,
                    profile: profile(for: viewModel.matchState.playerOne),
                    isPrimaryProfile: viewModel.matchState.playerOne.profileId == primaryProfileId,
                    destination: .playerOne
                )
                PlayerSidebarRow(
                    label: String(localized: "Player 2"),
                    selection: viewModel.matchState.playerTwo,
                    catalog: catalog,
                    profile: profile(for: viewModel.matchState.playerTwo),
                    isPrimaryProfile: viewModel.matchState.playerTwo.profileId == primaryProfileId,
                    destination: .playerTwo
                )
            } else {
                playerOneLink
                playerTwoLink
            }
        } header: {
            TTSectionHeader(String(localized: "Or Pick Your Own"))
        } footer: {
            Text(String(localized: "Pick any Spearhead army for each player."))
        }
    }

    private var playerOneLink: some View {
        NavigationLink(value: GuidedMatchDestination.playerOne) {
            PlayerArmyRow(
                label: String(localized: "Player 1"),
                isPlayerOne: true,
                selection: viewModel.matchState.playerOne,
                catalog: catalog,
                profile: profile(for: viewModel.matchState.playerOne),
                isPrimaryProfile: viewModel.matchState.playerOne.profileId == primaryProfileId
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("guidedMatch.playerOne")
    }

    private var playerTwoLink: some View {
        NavigationLink(value: GuidedMatchDestination.playerTwo) {
            PlayerArmyRow(
                label: String(localized: "Player 2"),
                isPlayerOne: false,
                selection: viewModel.matchState.playerTwo,
                catalog: catalog,
                profile: profile(for: viewModel.matchState.playerTwo),
                isPrimaryProfile: viewModel.matchState.playerTwo.profileId == primaryProfileId
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("guidedMatch.playerTwo")
    }

}
