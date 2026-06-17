import SwiftUI
import TabletomeDomain

struct UnitWoundTrackerRow: View {
    let unit: SpearheadUnit
    let armyId: String
    let woundsRemaining: Int
    let onChange: (Int) -> Void

    private var capacity: Int {
        UnitWoundCapacity.capacity(for: unit)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(unit.name)
                    .font(.subheadline.weight(.semibold))
                Text(String(localized: "Max \(capacity) wounds"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Stepper(
                String(localized: "\(woundsRemaining) left"),
                value: Binding(
                    get: { woundsRemaining },
                    set: onChange
                ),
                in: 0...capacity
            )
            .accessibilityIdentifier("battleTracker.wounds.\(armyId).\(unit.id)")
        }
        .frame(minHeight: DesignTokens.minTouchTarget)
    }
}

struct UnitWoundTrackerSection: View {
    let title: String
    let armyId: String
    let units: [SpearheadUnit]
    let woundsRemaining: [String: Int]
    let onChange: (String, Int) -> Void

    private var trackableUnits: [SpearheadUnit] {
        units.filter { $0.health != nil }
    }

    var body: some View {
        if !trackableUnits.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                ForEach(trackableUnits) { unit in
                    let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unit.id)
                    if unit.id != trackableUnits.first?.id {
                        Divider()
                    }
                    UnitWoundTrackerRow(
                        unit: unit,
                        armyId: armyId,
                        woundsRemaining: woundsRemaining[key] ?? UnitWoundCapacity.capacity(for: unit),
                        onChange: { onChange(key, $0) }
                    )
                }
            }
        }
    }
}
