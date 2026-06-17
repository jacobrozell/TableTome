import SwiftUI
import TabletomeDomain

struct RealmSideCoinFlipCard: View {
    @State private var result: RealmSide?
    @State private var isFlipping = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(String(localized: "Realm Side"))
                .font(.headline)

            Text(String(localized: "Fair 50/50 flip between the Fire and Jade board sides."))
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: DesignTokens.Spacing.md) {
                ForEach(RealmSide.allCases) { side in
                    sideChip(side)
                }
            }

            if let result {
                Label(result.resultDescription, systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .accessibilityIdentifier("coinFlip.result")
            }

            PrimaryButton(
                title: isFlipping ? String(localized: "Flipping…") : String(localized: "Flip Coin"),
                accessibilityId: "coinFlip.flip"
            ) {
                performFlip()
            }
            .disabled(isFlipping)
        }
        .surfaceCard()
        .accessibilityIdentifier("coinFlip.card")
    }

    private func sideChip(_ side: RealmSide) -> some View {
        let isWinner = result == side
        return VStack(spacing: DesignTokens.Spacing.xs) {
            Image(systemName: side == .aqshy ? "flame.fill" : "leaf.fill")
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isWinner ? Color.accentColor : .secondary)
            Text(side.name)
                .font(.subheadline.weight(.semibold))
            Text(side.elementLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignTokens.Spacing.sm)
        .background(
            isWinner ? Color.accentColor.opacity(0.15) : Color(.tertiarySystemFill),
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
        )
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                .strokeBorder(isWinner ? Color.accentColor : .clear, lineWidth: 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            isWinner
                ? String(localized: "\(side.name), \(side.elementLabel), selected")
                : String(localized: "\(side.name), \(side.elementLabel)")
        )
        .accessibilityIdentifier("coinFlip.side.\(side.id)")
    }

    private func performFlip() {
        guard !isFlipping else { return }
        isFlipping = true
        result = nil

        let reveal = {
            let side = CoinFlipEngine.flip()
            result = side
            isFlipping = false
            UIAccessibility.post(
                notification: .announcement,
                argument: side.resultDescription
            )
        }

        if reduceMotion {
            reveal()
        } else {
            Task {
                try? await Task.sleep(for: .milliseconds(400))
                await MainActor.run { reveal() }
            }
        }
    }
}
