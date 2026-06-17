import SwiftUI
import TabletomeDomain

struct UnitWarscrollCard: View {
    let army: SpearheadArmy
    let unit: SpearheadUnit
    let ruleSections: [RuleSection]

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
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
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
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(spacing: DesignTokens.Spacing.lg) {
                if let move = unit.move {
                    statItem(
                        label: String(localized: "Move"),
                        value: move,
                        hint: String(localized: "Max distance in inches")
                    )
                }
                if let save = unit.save {
                    statItem(
                        label: String(localized: "Save"),
                        value: "\(save)+",
                        hint: String(localized: "Roll this or higher on D6 to block damage")
                    )
                }
                if let health = unit.health {
                    statItem(
                        label: String(localized: "Health"),
                        value: "\(health)",
                        hint: String(localized: "Wounds per model")
                    )
                }
                if let control = unit.control {
                    statItem(
                        label: String(localized: "Control"),
                        value: "\(control)",
                        hint: String(localized: "Strength when contesting objectives")
                    )
                }
            }
            .font(.caption)
        }
    }

    private func statItem(label: String, value: String, hint: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
            Text(hint)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) \(value). \(hint)")
    }

    private var weaponsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Weapons"))
                .font(.subheadline.bold())
            ForEach(unit.weapons) { weapon in
                weaponRow(weapon)
            }
        }
    }

    private func weaponRow(_ weapon: SpearheadWeapon) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack {
                Text(weapon.name)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if weapon.numericRollProfile != nil || weapon.isRollEvaluable {
                    NavigationLink {
                        UnitMatchupEvaluatorView(
                            ruleSections: ruleSections,
                            attackerPrefill: MatchupUnitPrefill(
                                armyId: army.id,
                                unitId: unit.id,
                                weaponId: weapon.id
                            )
                        )
                    } label: {
                        Label(String(localized: "Resolve"), systemImage: "dice.fill")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("warscroll.roll.\(unit.id).\(weapon.id)")
                }
            }
            Text(weaponStatLine(weapon))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(String(localized: "A = attacks · Hit/Wound = roll this or higher on D6 · Rend lowers save · Dmg = damage dealt"))
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
            if let ability = weapon.ability {
                Text(ability)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
    }

    private func weaponStatLine(_ weapon: SpearheadWeapon) -> String {
        WarscrollStatSummary.weaponCombatProfile(weapon)
    }

    private var evaluableWeapons: [SpearheadWeapon] {
        unit.weapons.filter(\.isRollEvaluable)
    }

    private var matchupLink: some View {
        NavigationLink {
            UnitMatchupEvaluatorView(
                ruleSections: ruleSections,
                attackerPrefill: MatchupUnitPrefill(
                    armyId: army.id,
                    unitId: unit.id,
                    weaponId: evaluableWeapons.first?.id
                )
            )
        } label: {
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
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(ability.name)
                        .font(.caption.weight(.semibold))
                    Text(ability.effect)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
