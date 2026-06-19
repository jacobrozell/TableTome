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

    private var selectedUnit: SpearheadUnit? {
        units.first(where: { $0.id == unitId })
    }

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

            unitSelection

            if showsWeaponPicker, !weapons.isEmpty {
                weaponSelection
            }

            if let unit = selectedUnit, !usesCompactStyle {
                Divider()
                unitSummary(unit)
            }
        }
        .modifier(ConditionalSurfaceCard(enabled: !usesCompactStyle))
    }

    private var unitSelection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            if let unit = selectedUnit {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.xs) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(unitPickerLabel(for: unit))
                            .font(usesCompactStyle ? .subheadline.weight(.semibold) : .body.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)
                            .adaptiveLineLimit(2)
                        if let subtext = WarscrollStatSummary.unitChoiceSubtext(
                            unit,
                            woundsRemaining: woundsRemaining
                        ) {
                            Text(subtext)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityIdentifier("matchup.unit.subtext.\(unit.id)")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if !armyId.isEmpty {
                        WarscrollInfoButton(
                            armyId: armyId,
                            unit: unit,
                            accessibilityId: "matchup.unit.warscroll.\(unit.id)"
                        )
                    }
                }
            }

            if units.count > 1 {
                unitChangePicker
            }
        }
    }

    private var unitChangePicker: some View {
        Picker(selection: $unitId) {
            ForEach(units) { unit in
                Text(unitPickerLabel(for: unit)).tag(unit.id)
            }
        } label: {
            Text(
                selectedUnit == nil
                    ? String(localized: "Unit")
                    : String(localized: "Change unit")
            )
            .font(usesCompactStyle ? .caption.weight(.semibold) : .subheadline)
        }
        .pickerStyle(.menu)
        .onChange(of: unitId) { _, newValue in onUnitChange(newValue) }
    }

    private var weaponSelection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            if weapons.count > 1 {
                Text(String(localized: "Weapon profile"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if weapons.count <= 3 {
                weaponProfileButtons
            } else {
                menuWeaponPicker
            }

            if let unit = selectedUnit, let notes = unit.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("matchup.unit.loadoutNotes.\(unit.id)")
            }
        }
    }

    private var weaponProfileButtons: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.xs) {
            VStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(weapons) { weapon in
                    Button {
                        weaponId = weapon.id
                        onWeaponChange(weapon.id)
                    } label: {
                        weaponProfileButtonLabel(for: weapon, isSelected: weaponId == weapon.id)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("matchup.weapon.\(weapon.id)")
                }
            }

            if let unit = selectedUnit, !armyId.isEmpty {
                WarscrollInfoButton(
                    armyId: armyId,
                    unit: unit,
                    accessibilityId: "matchup.weapon.warscroll.\(unit.id)"
                )
            }
        }
    }

    private var menuWeaponPicker: some View {
        HStack(alignment: .center, spacing: 0) {
            Picker(String(localized: "Weapon"), selection: $weaponId) {
                ForEach(weapons) { weapon in
                    Text(weaponPickerLabel(for: weapon)).tag(weapon.id)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: weaponId) { _, newValue in onWeaponChange(newValue) }

            if let unit = selectedUnit, !armyId.isEmpty {
                WarscrollInfoButton(
                    armyId: armyId,
                    unit: unit,
                    accessibilityId: "matchup.weapon.warscroll.\(unit.id)"
                )
            }
        }
    }

    private func weaponProfileButtonLabel(for weapon: SpearheadWeapon, isSelected: Bool) -> some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(weapon.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                if let loadout = WarscrollStatSummary.weaponLoadoutLabel(
                    weapon,
                    unitModelCount: selectedUnit?.modelCount
                ) {
                    Text(loadout)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                }
                Text(WarscrollStatSummary.weaponCombatProfile(weapon))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary.opacity(0.45))
        }
        .padding(DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            isSelected ? Color.accentColor.opacity(0.12) : Color(.tertiarySystemFill),
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
        )
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
        }
        .frame(minHeight: DesignTokens.minTouchTarget)
    }

    private func weaponPickerLabel(for weapon: SpearheadWeapon) -> String {
        var label = weapon.name
        if let loadout = WarscrollStatSummary.weaponLoadoutLabel(
            weapon,
            unitModelCount: selectedUnit?.modelCount
        ) {
            label += " · \(loadout)"
        }
        if let range = weapon.rangeInches {
            return String(localized: "\(label) · \(range)\"")
        }
        return String(localized: "\(label) · Melee")
    }

    private func unitPickerLabel(for unit: SpearheadUnit) -> String {
        let destroyed = unitWoundsRemaining?(unit.id) == 0
        return WarscrollStatSummary.unitPickerLabel(unit, destroyed: destroyed)
    }

    @ViewBuilder
    private func unitSummary(_ unit: SpearheadUnit) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(armyName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
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
        Toggle(isOn: Binding(get: { isOn }, set: { onToggle($0) })) {
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
