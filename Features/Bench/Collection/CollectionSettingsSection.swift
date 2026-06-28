import SwiftUI
import SwiftData
import TabletomeHobbyData

struct CollectionSettingsSection: View {
    @Environment(\.modelContext) private var context
    @Bindable var cfg: AppConfiguration

    var body: some View {
        Section {
            Button(String(localized: "Reset Models intro"), systemImage: "arrow.counterclockwise") {
                cfg.hasSeenCollectionIntro = false
                cfg.hasDismissedCollectionFirstStepsCoach = false
                try? context.save()
            }
        } header: {
            Text(String(localized: "Models"))
        } footer: {
            Text(String(localized: "Show the one-time Models tab walkthrough again."))
        }
    }
}
