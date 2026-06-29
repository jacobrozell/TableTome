import SwiftUI
import TabletomeDomain

/// One-time Models tab intro — deferred until after Play engagement.
struct CollectionIntroSheet: View {
    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 52))
                        .foregroundStyle(Color.accentOnSurface)
                        .symbolRenderingMode(.hierarchical)
                        .accessibilityHidden(true)
                    Text(String(localized: "Your Models"))
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    Text(
                        String(
                            localized: """
                            Track miniatures from sprue to table-ready. Optional until after your first game — \
                            add armies when you're ready to paint.
                            """
                        )
                    )
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 12) {
                        introStep(
                            number: 1,
                            title: String(localized: "Add an army"),
                            detail: String(localized: "Pick your game and faction — e.g. Space Marines or Stormcast."),
                            symbol: "plus.circle"
                        )
                        introStep(
                            number: 2,
                            title: String(localized: "Add units"),
                            detail: String(localized: "Name what's on the sprue. Use (5) in the name when a box has five models."),
                            symbol: "figure.stand"
                        )
                        introStep(
                            number: 3,
                            title: String(localized: "Track painting"),
                            detail: String(localized: "Swipe right to advance through painting stages."),
                            symbol: "arrow.right.circle"
                        )
                    }
                    .surfaceCard()
                }
                .padding()
                .readableContentWidth()
            }
            .tabBarScrollInset()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Got it")) { onDismiss() }
                        .accessibilityIdentifier("collectionIntroDismiss")
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private func introStep(number: Int, title: String, detail: String, symbol: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(Color.accentOnSurface)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(number). \(title)")
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
