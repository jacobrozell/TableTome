import SwiftUI
import TabletomeDomain
import TabletomeData

struct OwnedSpearheadArmiesSection: View {
    @ObservedObject var viewModel: PlayerDetailViewModel
    let gameSystemId: String

    private var factions: [SpearheadFaction] {
        viewModel.catalog?.factions.sorted { $0.name < $1.name } ?? []
    }

    var body: some View {
        if !factions.isEmpty {
            if !viewModel.boxSets.isEmpty {
                Section {
                    ForEach(viewModel.boxSets) { box in
                        let isLinked = viewModel.profile?.linkedStarterBoxIds.contains(box.id) == true
                        Button {
                            Task { await viewModel.linkStarterBox(box) }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                                    Text(box.starterMatchupTitle)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    if let badge = box.starterSetBadge, !badge.isEmpty {
                                        Text(badge)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                if isLinked {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                        .accessibilityIdentifier("playersHub.starterBox.\(box.id)")
                    }
                } header: {
                    Text(String(localized: "Starter box"))
                } footer: {
                    Text(String(localized: "Adds both armies from your starter box to this player."))
                }
            }

            ForEach(factions) { faction in
                let armies = faction.armies.sorted { $0.name < $1.name }
                if !armies.isEmpty {
                    Section(faction.name) {
                        ForEach(armies) { army in
                            ownedArmyRow(army)
                        }
                    }
                }
            }
        }
    }

    private func ownedArmyRow(_ army: SpearheadArmy) -> some View {
        let isOwned = viewModel.ownedArmyIds().contains(army.id)
        return HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            Toggle(isOn: Binding(
                get: { isOwned },
                set: { _ in Task { await viewModel.toggleOwnedArmy(army.id) } }
            )) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(army.name)
                        .font(.headline)
                    Text(army.general)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityIdentifier("playersHub.ownedArmy.\(army.id)")

            NavigationLink(value: ArmyRosterLink(gameSystemId: gameSystemId, armyId: army.id)) {
                Image(systemName: "book.closed")
                    .font(.body.weight(.semibold))
                    .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "Learn about \(army.name)"))
        }
    }
}
