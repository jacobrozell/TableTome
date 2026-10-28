import SwiftUI
import TabletomeDomain

struct UnitWarscrollCard: View {
    let army: SpearheadArmy
    let unit: SpearheadUnit
    let ruleSections: [RuleSection]
    var gameSystemId: GameSystemId = .default

    init(
        army: SpearheadArmy,
        unit: SpearheadUnit,
        ruleSections: [RuleSection],
        gameSystemId: GameSystemId = .default
    ) {
        self.army = army
        self.unit = unit
        self.ruleSections = ruleSections
        self.gameSystemId = gameSystemId
    }

    init(
        army: SpearheadArmy,
        unit: SpearheadUnit,
        ruleSections: [RuleSection],
        gameSystemId: String
    ) {
        self.init(
            army: army,
            unit: unit,
            ruleSections: ruleSections,
            gameSystemId: GameSystemId(resolving: gameSystemId)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            header
            if unit.hasWarscroll {
                statsRow
            }
            if !unit.weapons.isEmpty {
                weaponsSection
            }
            if !unit.abilities.isEmpty {
                abilitiesSection
            }
            if !evaluableWeapons.isEmpty {
                matchupLink
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TTColor.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                .strokeBorder(TTColor.stroke, lineWidth: 1)
        }
        .accessibilityIdentifier("warscroll.unit.\(unit.id)")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(unit.name)
                .font(.headline)
            if !unit.keywords.isEmpty {
                Text(unit.keywords.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let notes = unit.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var statsRow: some View {
        TTStatStrip(stats: unitReferenceStats(unit))
    }

    private var weaponsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            TTSectionHeader(String(localized: "Weapons"))
            TTWeaponTable(weapons: unit.weapons)
        }
    }

    private var evaluableWeapons: [SpearheadWeapon] {
        unit.weapons.filter(\.isRollEvaluable)
    }

    private var matchupLink: some View {
        NavigationLink(value: CombatResolverLink(
            gameSystemId: gameSystemId.rawValue,
            attackerArmyId: army.id,
            attackerUnitId: unit.id,
            attackerWeaponId: evaluableWeapons.first?.id
        )) {
            Label(String(localized: "Resolve vs Unit…"), systemImage: "arrow.left.arrow.right")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: DesignTokens.minTouchTarget)
        }
        .accessibilityIdentifier("warscroll.matchup.\(unit.id)")
    }

    private var abilitiesSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Abilities"))
                .font(.subheadline.bold())
            ForEach(unit.abilities) { ability in
                UnitAbilityCard(
                    ability: ability,
                    phase: ability.phases.first ?? .hero,
                    isUsed: false,
                    onMarkUsed: nil,
                    ruleSections: ruleSections,
                    gameSystemId: gameSystemId.rawValue
                )
            }
        }
    }
}
