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
