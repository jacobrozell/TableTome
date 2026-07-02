import SwiftUI
import TabletomeDomain

struct CallForReinforcementsCard: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let calledUnitKeys: Set<String>
    var showsCallReminder: Bool = false
    var onReinforcementOnTableChanged: ((String, String, Bool) -> Void)? = nil

    private var playerOneUnits: [SpearheadUnit] {
        reinforcementUnits(in: playerOneArmy)
    }

    private var playerTwoUnits: [SpearheadUnit] {
        reinforcementUnits(in: playerTwoArmy)
    }

    private var hasAny: Bool {
        !playerOneUnits.isEmpty || !playerTwoUnits.isEmpty
    }

    var body: some View {
        if hasAny {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Label(String(localized: "Call for Reinforcements"), systemImage: "arrow.down.to.line")
                    .font(.headline)

                if showsCallReminder {
                    reminderBanner
                }

                Text(
                    String(
                        localized: """
                        When an enemy unit is destroyed during your Movement phase, you may bring one unit with \
                        the Reinforcements keyword onto a battlefield edge. Mark each unit In reserve until you \
                        call it onto the table.
                        """
                    )
                )
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

                if !playerOneUnits.isEmpty, let army = playerOneArmy {
                    unitList(
                        title: "\(playerOneName) · \(army.name)",
                        armyId: army.id,
                        units: playerOneUnits
                    )
                }
                if !playerTwoUnits.isEmpty, let army = playerTwoArmy {
                    unitList(
                        title: "\(playerTwoName) · \(army.name)",
                        armyId: army.id,
                        units: playerTwoUnits
                    )
                }
            }
            .modifier(ReinforcementsCardStyle(showsCallReminder: showsCallReminder))
            .accessibilityIdentifier("battleTracker.callForReinforcements")
        }
    }

    private var reminderBanner: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "bell.badge.fill")
                .foregroundStyle(Color.accentOnSurface)
            Text(
                String(
                    localized: """
                    Enemy unit destroyed — the active player may Call for Reinforcements now. Toggle a unit to \
                    On table when it arrives.
                    """
                )
            )
            .font(.caption.weight(.semibold))
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        .accessibilityIdentifier("battleTracker.callForReinforcements.reminder")
    }

    private func unitList(title: String, armyId: String, units: [SpearheadUnit]) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(title)
                .font(.subheadline.weight(.semibold))

            ForEach(units) { unit in
                reinforcementRow(armyId: armyId, unit: unit)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func reinforcementRow(armyId: String, unit: SpearheadUnit) -> some View {
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unit.id)
        let onTable = calledUnitKeys.contains(key)
        let canToggle = onReinforcementOnTableChanged != nil

        return HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(unit.name)
                    .font(.subheadline)
                Text(onTable ? String(localized: "On the battlefield") : String(localized: "In reserve"))
                    .font(.caption)
                    .foregroundStyle(onTable ? .green : .orange)
            }
            Spacer(minLength: 0)
            if canToggle {
                Toggle(
                    onTable ? String(localized: "On table") : String(localized: "In reserve"),
                    isOn: Binding(
                        get: { onTable },
                        set: { onReinforcementOnTableChanged?(armyId, unit.id, $0) }
                    )
                )
                .labelsHidden()
                .toggleStyle(.switch)
                .accessibilityLabel(
                    String(localized: "\(unit.name), \(onTable ? "on table" : "in reserve")")
                )
                .accessibilityIdentifier("battleTracker.reinforcement.\(key)")
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }

    private func reinforcementUnits(in army: SpearheadArmy?) -> [SpearheadUnit] {
        guard let army else { return [] }
        return ReinforcementsTracking.reinforcementUnits(in: army)
    }
}

private struct ReinforcementsCardStyle: ViewModifier {
    let showsCallReminder: Bool

    func body(content: Content) -> some View {
        if showsCallReminder {
            content.accentHighlightCard()
        } else {
            content.surfaceCard()
        }
    }
}

struct BattleTrackerReinforcementCallBanner: View {
    let prompt: ReinforcementCallPrompt
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "arrow.down.to.line.circle.fill")
                    .foregroundStyle(Color.accentOnSurface)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Call for Reinforcements"))
                        .font(.subheadline.weight(.semibold))
                    Text(
                        String(
                            localized: """
                            \(prompt.destroyedUnitName) was destroyed. \(prompt.activePlayerName) may bring one \
                            reinforcement unit onto a battlefield edge — mark it on table below.
                            """
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    if !prompt.availableUnits.isEmpty {
                        Text(
                            String(
                                localized: "Available: \(prompt.availableUnits.map(\.unitName).joined(separator: ", "))"
                            )
                        )
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .minimumTouchTarget()
                .accessibilityLabel(String(localized: "Dismiss"))
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .accessibilityIdentifier("battleTracker.reinforcementCallBanner")
    }
}
