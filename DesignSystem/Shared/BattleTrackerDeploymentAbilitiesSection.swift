import SwiftUI
import TabletomeDomain

struct BattleTrackerDeploymentAbilitiesSection: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let usedOncePerBattleAbilityIds: Set<String>
    let ruleSections: [RuleSection]
    var onMarkUsed: ((TriggeredAbility) -> Void)? = nil

    private var playerOneAbilities: [TriggeredAbility] {
        deploymentAbilities(for: playerOneArmy)
    }

    private var playerTwoAbilities: [TriggeredAbility] {
        deploymentAbilities(for: playerTwoArmy)
    }

    private var hasAny: Bool {
        !playerOneAbilities.isEmpty || !playerTwoAbilities.isEmpty
    }

    var body: some View {
        if hasAny {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Label(String(localized: "Deployment abilities"), systemImage: "flag.checkered")
                    .font(.headline)

                Text(
                    String(
                        localized: """
                        Once-per-battle rules that happen before round 1 — resolve both armies before the first turn.
                        """
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

                armyColumn(
                    playerName: playerOneName,
                    army: playerOneArmy,
                    abilities: playerOneAbilities
                )
                armyColumn(
                    playerName: playerTwoName,
                    army: playerTwoArmy,
                    abilities: playerTwoAbilities
                )
            }
            .surfaceCard()
            .accessibilityIdentifier("battleTracker.deploymentAbilities")
        }
    }

    @ViewBuilder
    private func armyColumn(
        playerName: String,
        army: SpearheadArmy?,
        abilities: [TriggeredAbility]
    ) -> some View {
        if !abilities.isEmpty, let army {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("\(playerName) · \(army.name)")
                    .font(.subheadline.weight(.semibold))

                ForEach(abilities) { ability in
                    UnitAbilityCard(
                        ability: ability,
                        phase: .deployment,
                        isUsed: usedOncePerBattleAbilityIds.contains(ability.id),
                        onMarkUsed: ability.usageLimit == .oncePerBattle ? { onMarkUsed?(ability) } : nil,
                        ruleSections: ruleSections,
                        showsRollTools: false
                    )
                }
            }
        }
    }

    private func deploymentAbilities(for army: SpearheadArmy?) -> [TriggeredAbility] {
        guard let army else { return [] }
        return BattleAbilityCatalog.abilities(for: army)
            .filter { ability in
                !ability.isPassive
                    && ability.isAvailableIn(
                        phase: .deployment,
                        usedOncePerBattle: usedOncePerBattleAbilityIds
                    )
            }
            .sorted { $0.source < $1.source }
    }
}
