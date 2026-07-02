import SwiftUI
import TabletomeDomain

struct MatchupUnitSelectionSection: View {
    let armyId: String
    let selectedUnit: SpearheadUnit?
    let selectableUnits: [SpearheadUnit]
    let usesCompactStyle: Bool
    let woundsRemaining: Int?
    let hideUnitPicker: Bool
    let unitPickerHint: String?
    @Binding var unitId: String
    let unitPickerLabel: (SpearheadUnit) -> String
    let onUnitChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            if let unit = selectedUnit {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.xs) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(unitPickerLabel(unit))
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

            if hideUnitPicker, let hint = unitPickerHint {
                Text(hint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else if selectableUnits.count > 1 {
                unitChangePicker
            }
        }
    }

    private var unitChangePicker: some View {
        Picker(selection: $unitId) {
            ForEach(selectableUnits) { unit in
                Text(unitPickerLabel(unit)).tag(unit.id)
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
        .accessibilityIdentifier("matchup.unitPicker")
        .accessibilityLabel(
            selectedUnit == nil
                ? String(localized: "Unit")
                : String(localized: "Change unit")
        )
        .accessibilityHint(String(localized: "Chooses which unit to evaluate in this matchup."))
    }
}
