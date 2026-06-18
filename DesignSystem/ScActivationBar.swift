import SwiftUI
import TabletomeDomain

/// Sticky activation prompt for StarCraft TMG alternating activations.
struct ScActivationBar: View {
    let activePlayerName: String
    let phase: BattleTurnPhase
    var markerHolderName: String?
    var passClaimedByActivePlayer: Bool
    let onDone: () -> Void
    let onPass: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Label(activePlayerName, systemImage: "person.fill")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(phase.title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            if let markerHolderName {
                Label(
                    String(localized: "First Player Marker: \(markerHolderName)"),
                    systemImage: "flag.fill"
                )
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            }

            Text(activationHint)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: DesignTokens.Spacing.sm) {
                Button(String(localized: "Done"), action: onDone)
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("scTmg.activation.done")

                Button(passButtonTitle, action: onPass)
                    .buttonStyle(.bordered)
                    .disabled(passClaimedByActivePlayer)
                    .accessibilityIdentifier("scTmg.activation.pass")
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .accessibilityIdentifier("scTmg.activation.bar")
    }

    private var activationHint: String {
        if passClaimedByActivePlayer {
            String(
                localized: """
                You already passed this phase. Finish other activations, then advance the phase.
                """
            )
        } else if markerHolderName == nil {
            String(
                localized: """
                Activate one unit, then hand off. Pass to claim the First Player Marker for the next phase.
                """
            )
        } else {
            String(
                localized: """
                Activate one unit, then hand off. Pass moves the marker to you for the next phase.
                """
            )
        }
    }

    private var passButtonTitle: String {
        passClaimedByActivePlayer
            ? String(localized: "Passed")
            : String(localized: "Pass")
    }
}
