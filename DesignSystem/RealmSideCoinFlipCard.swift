import SwiftUI
import TabletomeDomain

struct RealmSideCoinFlipCard: View {
    @State private var battlefield: SpearheadBattlefield = .fireAndJade
    @State private var result: BattlefieldSide?
    @State private var isFlipping = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var sides: [BattlefieldSide] {
        BattlefieldSide.sides(for: battlefield)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(String(localized: "Board Side"))
                .font(.headline)

            Text(
                String(
                    localized: """
                    The defender chooses which battlefield and side to use. Pick the board you own, \
                    then flip or agree on Aqshy vs Ghyran, Ossia vs Dolorum, or Ashen Bastion vs \
                    Shattered Crossroads.
                    """
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            Picker(String(localized: "Battlefield"), selection: $battlefield) {
                ForEach(SpearheadBattlefield.allCases) { board in
                    Text(board.name).tag(board)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("coinFlip.battlefieldPicker")
            .onChange(of: battlefield) { _, _ in
                result = nil
            }

            Text(battlefield.newPlayerSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(battlefield.flipCaption)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: DesignTokens.Spacing.md) {
                ForEach(sides) { side in
                    sideChip(side)
                }
            }
            .frame(maxWidth: .infinity)

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
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .surfaceCard()
        .accessibilityIdentifier("coinFlip.card")
    }

    private func sideChip(_ side: BattlefieldSide) -> some View {
        let isWinner = result == side
        return VStack(spacing: DesignTokens.Spacing.xs) {
            Image(systemName: symbolName(for: side))
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isWinner ? Color.accentColor : .secondary)
            Text(side.name)
                .font(.subheadline.weight(.semibold))
            Text(side.paletteLabel)
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
                ? String(localized: "\(side.name), \(side.paletteLabel), selected")
                : String(localized: "\(side.name), \(side.paletteLabel)")
        )
        .accessibilityIdentifier("coinFlip.side.\(side.id)")
    }

    private func symbolName(for side: BattlefieldSide) -> String {
        switch side {
        case .aqshy: "flame.fill"
        case .ghyran: "leaf.fill"
        case .ossia: "sun.dust.fill"
        case .dolorum: "moon.haze.fill"
        case .ashenBastion: "building.columns.fill"
        case .shatteredCrossroads: "arrow.triangle.branch"
        }
    }

    private func performFlip() {
        guard !isFlipping else { return }
        isFlipping = true
        result = nil

        let reveal = {
            let side = CoinFlipEngine.flip(for: battlefield)
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
