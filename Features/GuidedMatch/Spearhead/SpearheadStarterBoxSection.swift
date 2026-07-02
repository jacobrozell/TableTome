import SwiftUI
import TabletomeDomain
import TabletomeData

enum SpearheadStarterBoxStorage {
    static let selectedBoxIdKey = "spearhead.selectedStarterBoxId"
    static let defaultBoxId = "skaventide"
}

struct SpearheadStarterBoxSection: View {
    let boxSets: [BoxSet]
    @Binding var selectedBoxId: String
    let onUseStarterMatchup: () -> Void

    private var selectedBox: BoxSet? {
        boxSets.first { $0.id == selectedBoxId } ?? boxSets.first
    }

    var body: some View {
        Section {
            if boxSets.count > 1 {
                Picker(String(localized: "Starter box"), selection: $selectedBoxId) {
                    ForEach(boxSets) { box in
                        Text(box.starterMatchupTitle).tag(box.id)
                    }
                }
                .accessibilityIdentifier("guidedMatch.starterBoxPicker")
            } else if let box = selectedBox {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Which starter box do you have?"))
                        .font(.subheadline.weight(.semibold))
                    Text(box.starterMatchupTitle)
                        .font(.headline)
                    if let badge = box.starterSetBadge, !badge.isEmpty {
                        Text(badge)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("guidedMatch.starterBoxPicker")
            }

            if let box = selectedBox {
                starterMatchupButton(for: box)
            }
        } header: {
            Text(String(localized: "Starter Set"))
        } footer: {
            Text(
                String(
                    localized: """
                    Pick the box you bought, then tap Use Starter Matchup. \
                    Have a different Spearhead box? Expand Choose armies below.
                    """
                )
            )
        }
    }

    private func starterMatchupButton(for box: BoxSet) -> some View {
        Button(action: onUseStarterMatchup) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Label {
                    Text(box.starterMatchupTitle)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                } icon: {
                    Image(systemName: "flag.2.crossed.fill")
                        .foregroundStyle(Color.accentOnSurface)
                }
                if let description = box.starterSetDescription, !description.isEmpty {
                    Text(description)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text(String(localized: "Use Starter Matchup"))
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                    .prominentButtonLabelStyle()
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("guidedMatch.starterMatchup")
        .accessibilityLabel(
            String(localized: "Use Starter Matchup, \(box.starterMatchupTitle)")
        )
        .accessibilityHint(
            String(
                localized: "Fills both armies, recommended picks, and defaults attacker to Player 1 — change on Setup if your roll differed."
            )
        )
    }
}
