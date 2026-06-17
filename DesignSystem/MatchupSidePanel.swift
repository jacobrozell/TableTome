import SwiftUI
import TabletomeDomain

struct MatchupSidePanel: View {
    let title: String
    var systemImage: String = "person.fill"
    let armyName: String
    let armies: [SpearheadArmy]
    @Binding var armyId: String
    let units: [SpearheadUnit]
    @Binding var unitId: String
    var weapons: [SpearheadWeapon] = []
    @Binding var weaponId: String
    var showsWeaponPicker: Bool = false
    var showsArmyPicker: Bool = true
    var usesCompactStyle: Bool = false
    var woundsRemaining: Int?
    var unitWoundsRemaining: ((String) -> Int?)?
    let onArmyChange: (String) -> Void
    let onUnitChange: (String) -> Void
    let onWeaponChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: usesCompactStyle ? DesignTokens.Spacing.sm : DesignTokens.Spacing.md) {
            if usesCompactStyle {
                Text(title)
                    .font(.subheadline.weight(.semibold))
            } else {
                SectionHeader(title: title, systemImage: systemImage)
            }

            if showsArmyPicker {
                Picker(String(localized: "Army"), selection: $armyId) {
                    ForEach(armies) { army in
                        Text(army.name).tag(army.id)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: armyId) { _, newValue in onArmyChange(newValue) }
            } else {
                Text(armyName)
                    .font(usesCompactStyle ? .caption.weight(.semibold) : .subheadline.weight(.semibold))
                    .foregroundStyle(usesCompactStyle ? .secondary : .primary)
            }

            Picker(String(localized: "Unit"), selection: $unitId) {
                ForEach(units) { unit in
                    Text(unitPickerLabel(for: unit)).tag(unit.id)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: unitId) { _, newValue in onUnitChange(newValue) }

            if showsWeaponPicker, !weapons.isEmpty {
                Picker(String(localized: "Weapon"), selection: $weaponId) {
                    ForEach(weapons) { weapon in
                        Text(weapon.name).tag(weapon.id)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: weaponId) { _, newValue in onWeaponChange(newValue) }
            }

            if let unit = units.first(where: { $0.id == unitId }) {
                if usesCompactStyle {
                    UnitQuickStatsRow(unit: unit, woundsRemaining: woundsRemaining)
                } else {
                    Divider()
                    unitSummary(unit)
                }
            }
        }
        .modifier(ConditionalSurfaceCard(enabled: !usesCompactStyle))
    }

    private func unitPickerLabel(for unit: SpearheadUnit) -> String {
        guard let remaining = unitWoundsRemaining?(unit.id) else { return unit.name }
        if remaining == 0 {
            return String(localized: "\(unit.name) (Destroyed)")
        }
        return unit.name
    }

    @ViewBuilder
    private func unitSummary(_ unit: SpearheadUnit) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(armyName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            if let save = unit.save {
                Text(String(localized: "Save \(save)+ · Health \(unit.health ?? 0)"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if !unit.keywords.isEmpty {
                Text(unit.keywords.joined(separator: " · "))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

private struct ConditionalSurfaceCard: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.surfaceCard()
        } else {
            content
        }
    }
}

struct CombatBuffToggleRow: View {
    let buff: CombatMatchupBuff
    let isOn: Bool
    let onToggle: (Bool) -> Void

    var body: some View {
        Toggle(isOn: Binding(get: { isOn }, set: onToggle)) {
            VStack(alignment: .leading, spacing: 2) {
                Text(buff.name)
                    .font(.subheadline.weight(.semibold))
                Text(buff.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .toggleStyle(.switch)
        .frame(minHeight: DesignTokens.minTouchTarget)
        .accessibilityIdentifier("matchup.buff.\(buff.id)")
    }
}
