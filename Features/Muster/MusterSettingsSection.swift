import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

struct MusterSettingsSection: View {
    @Environment(\.modelContext) private var context
    @Bindable var cfg: AppConfiguration
    @State private var showDisclaimer = false

    var body: some View {
        Section(String(localized: "Army Lists")) {
            LabeledContent {
                Text(UnitCatalogLoader.version)
                    .foregroundStyle(.secondary)
            } label: {
                Label(String(localized: "Catalog version"), systemImage: "books.vertical")
            }
            Button(String(localized: "Disclaimer"), systemImage: "info.circle") { showDisclaimer = true }
            Picker(String(localized: "Default battle size (40k)"), selection: Binding(
                get: { cfg.defaultBattleSizeKey40k },
                set: { cfg.defaultBattleSizeKey40k = $0; try? context.save() }
            )) {
                ForEach(BattleSizes.forGame("40k")) { size in
                    HStack(spacing: 8) {
                        Image(systemName: HobbyGameSymbol.systemImage(for: "40k"))
                            .foregroundStyle(Color.accentOnSurface)
                            .symbolRenderingMode(.hierarchical)
                            .accessibilityHidden(true)
                        Text(size.label)
                    }
                    .tag(size.id)
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
