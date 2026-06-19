import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

struct MusterIntroSheet: View {
    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.accentColor)
                        .accessibilityHidden(true)
                    Text(String(localized: "Army Lists"))
                        .font(.title.bold())
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
                        .padding(.horizontal)
                }
                .padding(.top, 32)
                .padding(.bottom, 16)
            }
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
}

struct MusterSettingsSection: View {
    @Environment(\.modelContext) private var context
    @Bindable var cfg: AppConfiguration
    @State private var showDisclaimer = false

    var body: some View {
        Section(String(localized: "Army Lists")) {
            LabeledContent(String(localized: "Catalog version"), value: UnitCatalogLoader.version)
            Button(String(localized: "Disclaimer"), systemImage: "info.circle") { showDisclaimer = true }
            Picker(String(localized: "Default battle size (40k)"), selection: Binding(
                get: { cfg.defaultBattleSizeKey40k },
                set: { cfg.defaultBattleSizeKey40k = $0; try? context.save() }
            )) {
                ForEach(BattleSizes.forGame("40k")) { size in
                    Text(size.label).tag(size.id)
                }
            }
            .formNavigationPickerStyle()
            Button(String(localized: "Reset intro"), systemImage: "arrow.counterclockwise") {
                cfg.hasSeenMusterIntro = false
                try? context.save()
            }
        }
        .alert(String(localized: "Unofficial data"), isPresented: $showDisclaimer) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(
                String(
                    localized: """
                    Unit names and points values are unofficial community data for personal list building. \
                    Not endorsed by Games Workshop. Verify before events.
                    """
                )
            )
        }
    }
}
