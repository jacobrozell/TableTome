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
        HStack(spacing: DesignTokens.Spacing.lg) {
            if let move = unit.move {
                statItem(label: String(localized: "Move"), value: move)
            }
            if let save = unit.save {
                statItem(label: String(localized: "Save"), value: "\(save)+")
            }
            if let health = unit.health {
                statItem(label: String(localized: "Health"), value: "\(health)")
            }
            if let control = unit.control {
                statItem(label: String(localized: "Control"), value: "\(control)")
            }
        }
        .font(.caption)
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
        }
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
        var parts: [String] = []
        if let range = weapon.rangeInches {
            parts.append("Range \(range)\"")
        }
        parts.append("A \(weapon.attacks)")
        parts.append("Hit \(weapon.hit)+")
        parts.append("Wound \(weapon.wound)+")
        parts.append("Rend \(weapon.rend)")
        parts.append("Dmg \(weapon.damage)")
        return parts.joined(separator: " · ")
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
