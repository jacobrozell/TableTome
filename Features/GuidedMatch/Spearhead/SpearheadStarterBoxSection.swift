import SwiftUI
import TabletomeDomain
import TabletomeData

enum SpearheadStarterBoxStorage {
    static let selectedBoxIdKey = "spearhead.selectedStarterBoxId"
    static let defaultBoxId = "skaventide"
}

struct SpearheadStarterBoxSection: View {
    let boxSets: [BoxSet]
    @Binding var selectedBoxId: String
    let catalog: SpearheadCatalog?
    let onUseStarterMatchup: () -> Void

    private var selectedBox: BoxSet? {
        boxSets.first { $0.id == selectedBoxId } ?? boxSets.first
    }

    var body: some View {
        Section {
            if boxSets.count > 1 {
                Picker(String(localized: "Starter box"), selection: $selectedBoxId) {
                    ForEach(boxSets) { box in
                        Text(box.starterMatchupTitle).tag(box.id)
                    }
                }
                .accessibilityIdentifier("guidedMatch.starterBoxPicker")
            }
            if let box = selectedBox {
                starterHero(for: box)
                    .listHeroCardRow()
            }
        }
    }

    private func starterHero(for box: BoxSet) -> some View {
        TTHeroCard(
            eyebrow: String(localized: "STARTER SET"),
            title: box.starterMatchupTitle,
            subtitle: box.starterSetDescription
        ) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                armyLine(isPlayerOne: true, selection: box.playerOne)
                MatchupVersusBadge()
                armyLine(isPlayerOne: false, selection: box.playerTwo)
                Button(String(localized: "Use Starter Matchup"), action: onUseStarterMatchup)
                    .buttonStyle(.ttPrimary)
                    .accessibilityIdentifier("guidedMatch.starterMatchup")
                    .accessibilityLabel(
                        String(localized: "Use Starter Matchup, \(box.starterMatchupTitle)")
                    )
                    .accessibilityHint(
                        String(
                            localized: "Fills both armies, recommended picks, and defaults attacker to Player 1 — change on Setup if your roll differed."
                        )
                    )
            }
        }
    }

    private func armyLine(isPlayerOne: Bool, selection: BoxSetArmySelection) -> some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            TTPlayerToken(isPlayerOne: isPlayerOne, size: 28)
            Text(armyName(selection))
                .font(TTFont.callout)
                .foregroundStyle(TTColor.inkPrimary)
                .lineLimit(2)
        }
    }

    private func armyName(_ selection: BoxSetArmySelection) -> String {
        guard let catalog,
              let faction = catalog.factions.first(where: { $0.id == selection.factionId }),
              let army = faction.armies.first(where: { $0.id == selection.armyId }) else {
            return selection.playerName?.isEmpty == false
                ? (selection.playerName ?? "")
                : String(localized: "Starter army")
        }
        return army.name
    }
}
