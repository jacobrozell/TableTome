import SwiftUI
import TabletomeDomain

public struct TTWeaponTable: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let weapons: [SpearheadWeapon]
    private let highlightedWeaponId: String?
    private let onResolve: ((SpearheadWeapon) -> Void)?

    public init(
        weapons: [SpearheadWeapon],
        highlightedWeaponId: String? = nil,
        onResolve: ((SpearheadWeapon) -> Void)? = nil
    ) {
        self.weapons = weapons
        self.highlightedWeaponId = highlightedWeaponId
        self.onResolve = onResolve
    }

    public var body: some View {
        if dynamicTypeSize.needsLayoutAdaptation {
            VStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(weapons) { weapon in
                    stacked(weapon)
                }
            }
        } else {
            Grid(alignment: .leading, horizontalSpacing: DesignTokens.Spacing.sm, verticalSpacing: DesignTokens.Spacing.xs) {
                GridRow {
                    header("Rng")
                    header("Atk")
                    header("Hit")
                    header("Wnd")
                    header("Rnd")
                    header("Dmg")
                }
                ForEach(weapons) { weapon in
                    weaponBlock(weapon)
                }
            }
        }
    }

    private func header(_ title: String) -> some View {
        Text(title).ttEyebrow(TTColor.inkTertiary)
    }

    @ViewBuilder
    private func weaponBlock(_ weapon: SpearheadWeapon) -> some View {
        GridRow {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                HStack {
                    Text(weapon.name).font(TTFont.headline).foregroundStyle(TTColor.inkPrimary)
                    if isMelee(weapon) { TTBadge("Melee") }
                    Spacer(minLength: 0)
                    resolveButton(weapon)
                }
                if let ability = weapon.ability, !ability.isEmpty {
                    Text(ability)
                        .font(TTFont.footnote)
                        .foregroundStyle(TTColor.inkSecondary)
                }
            }
            .gridCellColumns(6)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText(weapon))
        GridRow {
            cell(rangeText(weapon))
            cell(weapon.attacks)
            cell("\(weapon.hit)+")
            cell("\(weapon.wound)+")
            cell(weapon.rend == 0 ? "—" : "\(weapon.rend)")
            cell(weapon.damage)
        }
        .background(weapon.id == highlightedWeaponId ? TTColor.brandSoft : .clear)
    }

    private func stacked(_ weapon: SpearheadWeapon) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(weapon.name).font(TTFont.headline)
            if isMelee(weapon) { TTBadge("Melee") }
            LabeledContent("Rng", value: rangeText(weapon))
            LabeledContent("Atk", value: weapon.attacks)
            LabeledContent("Hit", value: "\(weapon.hit)+")
            LabeledContent("Wnd", value: "\(weapon.wound)+")
            LabeledContent("Rnd", value: weapon.rend == 0 ? "—" : "\(weapon.rend)")
            LabeledContent("Dmg", value: weapon.damage)
            resolveButton(weapon)
        }
        .padding(DesignTokens.Spacing.sm)
        .background(TTColor.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText(weapon))
    }

    @ViewBuilder
    private func resolveButton(_ weapon: SpearheadWeapon) -> some View {
        if let onResolve {
            Button("Resolve") { onResolve(weapon) }
                .buttonStyle(.ttTertiary)
                .accessibilityIdentifier("weapon.resolve.\(weapon.id)")
        }
    }

    private func cell(_ text: String) -> some View {
        Text(text)
            .font(TTFont.numericSmall)
            .foregroundStyle(TTColor.inkPrimary)
    }

    private func isMelee(_ weapon: SpearheadWeapon) -> Bool {
        weapon.rangeInches == nil || weapon.rangeInches == 0
    }

    private func rangeText(_ weapon: SpearheadWeapon) -> String {
        if isMelee(weapon) { return "—" }
        return "\(weapon.rangeInches ?? 0)\""
    }

    private func accessibilityText(_ weapon: SpearheadWeapon) -> String {
        let range = isMelee(weapon) ? "melee" : "\(weapon.rangeInches ?? 0) inches"
        let rend = weapon.rend == 0 ? "no rend" : "rend \(weapon.rend)"
        return "\(weapon.name), \(range), \(weapon.attacks) attacks, hit \(weapon.hit) plus, wound \(weapon.wound) plus, \(rend), damage \(weapon.damage)"
    }
}
