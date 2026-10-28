import SwiftUI

struct BattlePrimaryActionBar: View {
    let title: String
    let systemImage: String?
    var usesPlayerStyle: Bool = false
    var playerIsOne: Bool = true
    var usesCompleteIdentifier: Bool = false
    var isPrimaryEnabled: Bool = true
    let onPrimary: () -> Void
    let onUnits: () -> Void
    let onDice: () -> Void
    var diceEnabled: Bool = true

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            if dynamicTypeSize.needsLayoutAdaptation {
                overflowMenu
            } else {
                toolButton(
                    title: String(localized: "Units"),
                    systemImage: "person.3.fill",
                    identifier: "battleTracker.actionBar.units",
                    action: onUnits
                )
                toolButton(
                    title: String(localized: "Dice"),
                    systemImage: "dice.fill",
                    identifier: "battleTracker.actionBar.dice",
                    action: onDice
                )
                .disabled(!diceEnabled)
            }
            primaryButton
        }
        .barChromeBackground(horizontalPadding: DesignTokens.Spacing.sm, verticalPadding: DesignTokens.Spacing.xs)
    }

    private var overflowMenu: some View {
        Menu {
            Button(String(localized: "Units"), systemImage: "person.3.fill", action: onUnits)
            Button(String(localized: "Dice"), systemImage: "dice.fill", action: onDice)
                .disabled(!diceEnabled)
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: 52, height: 52)
                .background(TTColor.raised, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        }
        .accessibilityIdentifier("battleTracker.actionBar.overflow")
    }

    private func toolButton(
        title: String,
        systemImage: String,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: systemImage)
                Text(title)
                    .font(TTFont.caption)
                    .lineLimit(1)
            }
            .foregroundStyle(TTColor.inkPrimary)
            .frame(width: 52, height: 52)
            .background(TTColor.raised, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    @ViewBuilder
    private var primaryButton: some View {
        let label = HStack(spacing: DesignTokens.Spacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(title)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Image(systemName: "chevron.right")
                .accessibilityHidden(true)
        }
        if usesPlayerStyle {
            Button(action: onPrimary) { label }
                .buttonStyle(.ttPlayer(isPlayerOne: playerIsOne))
                .disabled(!isPrimaryEnabled)
                .accessibilityIdentifier(primaryIdentifier)
        } else {
            Button(action: onPrimary) { label }
                .buttonStyle(.ttPrimary)
                .disabled(!isPrimaryEnabled)
                .accessibilityIdentifier(primaryIdentifier)
        }
    }

    private var primaryIdentifier: String {
        usesCompleteIdentifier ? "battleGuide.complete" : "battleGuide.action"
    }
}
