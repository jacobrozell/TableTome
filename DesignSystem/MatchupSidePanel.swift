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
    let onArmyChange: (String) -> Void
    let onUnitChange: (String) -> Void
    let onWeaponChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: title, systemImage: systemImage)

            Picker(String(localized: "Army"), selection: $armyId) {
                ForEach(armies) { army in
                    Text(army.name).tag(army.id)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: armyId) { _, newValue in onArmyChange(newValue) }

            Picker(String(localized: "Unit"), selection: $unitId) {
                ForEach(units) { unit in
                    Text(unit.name).tag(unit.id)
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
                Divider()
                unitSummary(unit)
            }
        }
        .surfaceCard()
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
