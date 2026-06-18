import SwiftUI
import TabletomeDomain

struct ArmyTrackerCard: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let woundsRemaining: [String: Int]
    let healthPerModelOverrides: [String: Int]
    let activePlayerIsOne: Bool
    var usesWideLayout: Bool = false
    var usesCompactSidebar: Bool = false
    let onChange: (String, Int) -> Void
    var onSelectUnit: ((String, String) -> Void)?

    @State private var hidesDestroyedUnits = false

    var body: some View {
        VStack(alignment: .leading, spacing: usesCompactSidebar ? DesignTokens.Spacing.sm : DesignTokens.Spacing.md) {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                if usesCompactSidebar {
                    Text(String(localized: "Army Health"))
                        .font(.subheadline.weight(.semibold))
                } else {
                    Label(String(localized: "Army Health"), systemImage: "heart.text.square.fill")
                        .font(.headline)
                }
                Spacer(minLength: 0)
                if hasDestroyedUnits {
                    Toggle(String(localized: "Hide destroyed"), isOn: $hidesDestroyedUnits)
                        .toggleStyle(.switch)
                        .font(.caption)
                        .labelsHidden()
                        .accessibilityLabel(String(localized: "Hide destroyed units"))
                }
            }

            if usesWideLayout {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
                    armyColumn(
                        army: playerOneArmy,
                        playerName: playerOneName,
                        isActivePlayer: activePlayerIsOne
                    )
                    armyColumn(
                        army: playerTwoArmy,
                        playerName: playerTwoName,
                        isActivePlayer: !activePlayerIsOne
                    )
                }
            } else {
                armyColumn(
                    army: playerOneArmy,
                    playerName: playerOneName,
                    isActivePlayer: activePlayerIsOne
                )
                armyColumn(
                    army: playerTwoArmy,
                    playerName: playerTwoName,
                    isActivePlayer: !activePlayerIsOne
                )
            }
        }
        .padding(usesCompactSidebar ? DesignTokens.Spacing.sm : DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .accessibilityIdentifier("battleTracker.armyTracker")
    }

    private var hasDestroyedUnits: Bool {
        [playerOneArmy, playerTwoArmy].compactMap { army in
            army.flatMap {
                ArmyHealthCatalog.summary(army: $0, playerName: "", woundsRemaining: woundsRemaining, healthPerModelOverrides: healthPerModelOverrides)
            }
        }
        .contains { $0.destroyedUnitCount > 0 }
    }

    @ViewBuilder
    private func armyColumn(army: SpearheadArmy?, playerName: String, isActivePlayer: Bool) -> some View {
        if let army,
           let summary = ArmyHealthCatalog.summary(
               army: army,
               playerName: playerName,
               woundsRemaining: woundsRemaining,
               healthPerModelOverrides: healthPerModelOverrides
           ) {
            ArmyHealthPanel(
                summary: summary,
                isActivePlayer: isActivePlayer,
                hidesDestroyedUnits: hidesDestroyedUnits,
                usesWideLayout: usesWideLayout,
                usesCompactSidebar: usesCompactSidebar,
                onChange: onChange,
                onSelectUnit: onSelectUnit
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ArmyHealthPanel: View {
    let summary: ArmyHealthSummary
    let isActivePlayer: Bool
    let hidesDestroyedUnits: Bool
    let usesWideLayout: Bool
    let usesCompactSidebar: Bool
    let onChange: (String, Int) -> Void
    var onSelectUnit: ((String, String) -> Void)?

    private var visibleUnits: [ArmyUnitHealth] {
        summary.visibleUnits(hidingDestroyed: hidesDestroyedUnits)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Text(summary.playerName)
                            .font(.subheadline.weight(.semibold))
                        if isActivePlayer {
                            Text(String(localized: "Active"))
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, DesignTokens.Spacing.sm)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.15), in: Capsule())
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    Text(summary.armyName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }

            Text(summaryLine)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            ArmyHealthProgressBar(fraction: summary.fractionRemaining, isCritical: summary.fractionRemaining <= 0.25)

            if visibleUnits.isEmpty {
                Text(String(localized: "All units destroyed."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(visibleUnits) { unit in
                    ArmyUnitHealthRow(
                        unit: unit,
                        armyId: summary.armyId,
                        usesWideLayout: usesWideLayout,
                        usesCompactSidebar: usesCompactSidebar,
                        onChange: onChange,
                        onSelect: onSelectUnit
                    )
                }
            }

            if hidesDestroyedUnits, summary.destroyedUnitCount > 0 {
                Text(String(localized: "\(summary.destroyedUnitCount) destroyed hidden"))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(usesCompactSidebar ? DesignTokens.Spacing.xs : DesignTokens.Spacing.sm)
        .background(
            isActivePlayer ? Color.accentColor.opacity(0.06) : Color(.tertiarySystemFill).opacity(0.35),
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
        )
        .overlay {
            if isActivePlayer {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                    .strokeBorder(Color.accentColor.opacity(0.2), lineWidth: 1)
            }
        }
    }

    private var summaryLine: String {
        String(
            localized: """
            \(summary.aliveUnitCount)/\(summary.trackableUnitCount) units · \
            \(summary.totalWoundsRemaining)/\(summary.totalWoundCapacity) wounds
            """
        )
    }
}

struct ArmyHealthProgressBar: View {
    let fraction: Double
    var isCritical: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.tertiarySystemFill))
                Capsule()
                    .fill(barColor)
                    .frame(width: geometry.size.width * max(0, min(1, fraction)))
            }
        }
        .frame(height: 8)
        .accessibilityLabel(String(localized: "Army wounds remaining"))
        .accessibilityValue(String(localized: "\(Int(fraction * 100)) percent"))
    }

    private var barColor: Color {
        if fraction <= 0 {
            return .red.opacity(0.45)
        }
        if isCritical {
            return .orange.opacity(0.85)
        }
        return Color.accentColor.opacity(0.8)
    }
}

struct ArmyUnitHealthRow: View {
    let unit: ArmyUnitHealth
    let armyId: String
    var usesWideLayout: Bool = false
    var usesCompactSidebar: Bool = false
    let onChange: (String, Int) -> Void
    var onSelect: ((String, String) -> Void)?

    private var woundKey: String {
        UnitWoundTracker.unitKey(armyId: armyId, unitId: unit.unitId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                Button {
                    onSelect?(armyId, unit.unitId)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: DesignTokens.Spacing.xs) {
                            Text(unit.unitName)
                                .font(usesWideLayout ? .subheadline.weight(.semibold) : .caption.weight(.semibold))
                                .lineLimit(usesWideLayout ? 2 : 1)
                                .multilineTextAlignment(.leading)
                            if unit.isDestroyed {
                                Text(String(localized: "Destroyed"))
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.red)
                            }
                        }
                        Text(String(localized: "\(unit.woundsRemaining)/\(unit.woundCapacity) wounds"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .disabled(onSelect == nil || unit.isDestroyed)

                Stepper(
                    String(localized: "\(unit.woundsRemaining)"),
                    value: Binding(
                        get: { unit.woundsRemaining },
                        set: { onChange(woundKey, $0) }
                    ),
                    in: 0...unit.woundCapacity
                )
                .labelsHidden()
                .accessibilityLabel(
                    String(localized: "\(unit.unitName) wounds remaining")
                )
                .accessibilityValue(String(localized: "\(unit.woundsRemaining)"))
                .accessibilityIdentifier("battleTracker.wounds.\(armyId).\(unit.unitId)")
            }

            ArmyHealthProgressBar(
                fraction: unit.fractionRemaining,
                isCritical: unit.fractionRemaining > 0 && unit.fractionRemaining <= 0.35
            )
        }
        .opacity(unit.isDestroyed ? 0.6 : 1)
        .frame(minHeight: usesCompactSidebar ? 40 : DesignTokens.minTouchTarget)
        .accessibilityHint(onSelect == nil ? "" : String(localized: "Opens unit focus with warscroll and combat options."))
    }
}
