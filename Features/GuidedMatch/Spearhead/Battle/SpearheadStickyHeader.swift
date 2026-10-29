import SwiftUI
import TabletomeDomain

/// Always-visible header showing round, phase, active player, and VP totals.
struct SpearheadStickyHeader: View {
    let round: Int
    let phase: BattleTurnPhase
    let activePlayerName: String
    let playerOneVP: Int
    let playerTwoVP: Int
    let playerOneName: String
    let playerTwoName: String
    let activePlayerIsOne: Bool
    let isRoundOneFirstTurnEditable: Bool
    var compactLandscape: Bool = false
    let onSetFirstTurn: (Bool) -> Void
    let onTapVP: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 0) {
            if compactLandscape {
                compactLandscapeBody
            } else {
                standardBody
            }
            Divider()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier("spearheadBattle.stickyHeader")
    }

    @ViewBuilder
    private var standardBody: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            roundPhaseLabel
            Spacer(minLength: 0)
            vpSummary
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .frame(minHeight: DesignTokens.minTouchTarget)
        .background(.bar)
    }

    @ViewBuilder
    private var compactLandscapeBody: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Text("Round \(round) · \(phase.title)")
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Spacer(minLength: 0)
                vpSummary
            }
            if isRoundOneFirstTurnEditable {
                firstTurnPicker
            } else {
                Text(activePlayerName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, DesignTokens.phoneLandscapeHorizontalPadding)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .frame(minHeight: DesignTokens.phoneLandscapeStickyBarHeight, alignment: .leading)
        .background(.bar)
    }

    @ViewBuilder
    private var roundPhaseLabel: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            Text("Round \(round)")
                .font(.subheadline.weight(.semibold))

            Text("·")
                .foregroundStyle(.tertiary)

            Text(phase.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("·")
                .foregroundStyle(.tertiary)

            if isRoundOneFirstTurnEditable {
                firstTurnPicker
            } else {
                Text(activePlayerName)
                    .font(.subheadline)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private var firstTurnPicker: some View {
        Menu {
            Button {
                onSetFirstTurn(true)
            } label: {
                Label(playerOneName, systemImage: activePlayerIsOne ? "checkmark" : "")
            }
            Button {
                onSetFirstTurn(false)
            } label: {
                Label(playerTwoName, systemImage: activePlayerIsOne ? "" : "checkmark")
            }
        } label: {
            HStack(spacing: 4) {
                Text(activePlayerName)
                    .font(.subheadline)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityLabel(String(localized: "First turn: \(activePlayerName)"))
        .accessibilityHint(String(localized: "Double tap to change who goes first"))
        .accessibilityIdentifier("spearheadBattle.firstTurnPicker")
    }

    @ViewBuilder
    private var vpSummary: some View {
        Button(action: onTapVP) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                vpBadge(name: playerOneName, vp: playerOneVP, isActive: activePlayerIsOne)
                vpBadge(name: playerTwoName, vp: playerTwoVP, isActive: !activePlayerIsOne)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(vpAccessibilityLabel)
        .accessibilityHint(String(localized: "Double tap to see score breakdown"))
        .accessibilityIdentifier("spearheadBattle.vpSummary")
    }

    @ViewBuilder
    private func vpBadge(name: String, vp: Int, isActive: Bool) -> some View {
        HStack(spacing: 4) {
            if dynamicTypeSize.needsLayoutAdaptation {
                Text("\(vp)")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
            } else {
                Text(abbreviatedName(name))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(vp)")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, 3)
        .background(
            isActive ? Color.accentColor.opacity(0.15) : TTColor.sunken,
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.nested, style: .continuous)
        )
        .foregroundStyle(isActive ? Color.accentOnSurface : Color.primary)
    }

    private func abbreviatedName(_ name: String) -> String {
        if name.count <= 6 { return name }
        let first = name.prefix(1).uppercased()
        return "\(first):"
    }

    private var accessibilityLabel: String {
        [
            "Round \(round)",
            phase.title,
            activePlayerName,
            "\(playerOneName): \(playerOneVP) points",
            "\(playerTwoName): \(playerTwoVP) points"
        ].joined(separator: ", ")
    }

    private var vpAccessibilityLabel: String {
        "\(playerOneName) \(playerOneVP), \(playerTwoName) \(playerTwoVP)"
    }
}
