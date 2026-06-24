import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

struct MusterIntroSheet: View {
    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(Color.accentOnSurface)
                        .symbolRenderingMode(.hierarchical)
                        .accessibilityHidden(true)
                    Text(String(localized: "Army Lists"))
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    Text(
                        String(
                            localized: """
                            Army lists help you plan which models to bring. Track what you own under Models, \
                            then build lists here — you can skip this until after your first game.
                            """
                        )
                    )
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 12) {
                        introStep(
                            number: 1,
                            title: String(localized: "Track models"),
                            detail: String(localized: "Add armies and units on the Models tab."),
                            symbol: "shield.lefthalf.filled"
                        )
                        introStep(
                            number: 2,
                            title: String(localized: "Build a list"),
                            detail: String(localized: "Pick faction, battle size, and catalog units."),
                            symbol: "flag"
                        )
                        introStep(
                            number: 3,
                            title: String(localized: "See what you can field"),
                            detail: String(localized: "Link a list to Collection to compare ownership."),
                            symbol: "link"
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
                        .accessibilityIdentifier("musterIntroDismiss")
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
