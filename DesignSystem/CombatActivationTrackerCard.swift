import SwiftUI
import TabletomeDomain

/// New-player friendly "who's up / who's fought" tracker for the active player's
/// units in a combat-related phase. Tapping a unit opens the dice resolver; the
/// trailing toggle checks the unit off once it has attacked.
struct CombatActivationTrackerCard: View {
    let units: [SpearheadUnit]
    let playerName: String
    let phaseTitle: String
    let doneCount: Int
    let hasActed: (String) -> Bool
    let weaponSummary: (SpearheadUnit) -> String
    let onToggleActed: (String) -> Void
    var onSelectUnit: ((String) -> Void)?

    private var remaining: Int { max(0, units.count - doneCount) }

    private var helperText: String {
        if remaining == 0 {
            return String(localized: "Every unit has had its turn. Move to the next phase when you're ready.")
        }
        return String(
            localized: "Tap a unit to open its warscroll and resolve attacks, then mark it done. \(remaining) still to go."
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                Label(String(localized: "Whose turn to attack"), systemImage: "checklist")
                    .font(.headline)
                Spacer(minLength: 0)
                Text(String(localized: "\(doneCount)/\(units.count) done"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(remaining == 0 ? Color.accentColor : .secondary)
                    .monospacedDigit()
            }

            Text("\(playerName) · \(phaseTitle)")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            Text(helperText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(units) { unit in
                    unitRow(unit)
                }
            }
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.combatActivation")
    }

    @ViewBuilder
    private func unitRow(_ unit: SpearheadUnit) -> some View {
        let acted = hasActed(unit.id)
        HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
            Button {
                onSelectUnit?(unit.id)
            } label: {
                rowLabel(unit: unit, acted: acted)
            }
            .buttonStyle(.plain)
            .disabled(onSelectUnit == nil)
            .accessibilityIdentifier("battleTracker.combatActivation.resolve.\(unit.id)")
            .accessibilityHint(onSelectUnit == nil ? "" : String(localized: "Opens unit details and combat tools for this unit"))

            toggleButton(unit: unit, acted: acted)
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .background(
            acted ? Color.clear : Color.accentColor.opacity(0.06),
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
        )
        .opacity(acted ? 0.7 : 1)
    }

    private func rowLabel(unit: SpearheadUnit, acted: Bool) -> some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: acted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(acted ? Color.accentColor : Color.secondary)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(unit.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(acted ? .secondary : .primary)
                    .strikethrough(acted, color: .secondary)
                    .multilineTextAlignment(.leading)
                Text(weaponSummary(unit))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func toggleButton(unit: SpearheadUnit, acted: Bool) -> some View {
        Button {
            onToggleActed(unit.id)
        } label: {
            Text(acted ? String(localized: "Undo") : String(localized: "Done"))
                .font(.caption.weight(.semibold))
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .frame(minHeight: DesignTokens.minTouchTarget)
        }
        .buttonStyle(.bordered)
        .tint(acted ? .secondary : .accentColor)
        .accessibilityLabel(
            acted
                ? String(localized: "Mark \(unit.name) as not done")
                : String(localized: "Mark \(unit.name) as done")
        )
        .accessibilityIdentifier("battleTracker.combatActivation.toggle.\(unit.id)")
    }
}
