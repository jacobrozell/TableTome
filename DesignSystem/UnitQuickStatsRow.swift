import SwiftUI
import TabletomeDomain

struct UnitQuickStatsRow: View {
    let unit: SpearheadUnit
    var woundsRemaining: Int?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var capacity: Int {
        UnitWoundCapacity.capacity(for: unit)
    }

    private var isDestroyed: Bool {
        woundsRemaining == 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Group {
                if dynamicTypeSize.needsLayoutAdaptation {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        statChips
                    }
                } else {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        statChips
                    }
                }
            }
        }
        .opacity(isDestroyed ? 0.65 : 1)
    }

    @ViewBuilder
    private var statChips: some View {
        if let move = unit.move {
            statChip(String(localized: "Move \(move)\""), systemImage: "figure.walk")
        }
        if let save = unit.save {
            statChip(String(localized: "Save \(save)+"), systemImage: "shield.fill")
        }
        if let health = unit.health {
            let woundLabel: String = {
                if let woundsRemaining {
                    return String(localized: "\(woundsRemaining)/\(capacity) wounds")
                }
                return String(localized: "\(health) wounds/model")
            }()
            statChip(woundLabel, systemImage: "heart.fill")
        }
        if isDestroyed {
            Text(String(localized: "Destroyed"))
                .font(.caption2.weight(.bold))
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .background(Color.red.opacity(0.15), in: Capsule())
                .foregroundStyle(.red)
        }
    }

    private func statChip(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .adaptiveLineLimit(1)
    }
}
