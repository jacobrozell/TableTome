import SwiftUI
import SwiftData
import TabletomeDomain
import TabletomeHobbyData

struct RosterEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let entry: RosterEntry

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent(String(localized: "Unit"), value: entry.displayName)
                    QuantityStepper(label: String(localized: "Quantity"), value: Binding(
                        get: { entry.qty },
                        set: { RosterStore.setQty(entry, $0, in: context) }
                    ), range: 1...HobbyLimits.maxRosterQty)
                } header: {
                    Text(String(localized: "Entry"))
                }

                Section {
                    LabeledContent(String(localized: "Points each"), value: "\(entry.pointsEach)")
                    LabeledContent(String(localized: "Total"), value: String(localized: "\(entry.pointsTotal) pts"))
                } header: {
                    Text(String(localized: "Points"))
                }

                Section {
                    Button(String(localized: "Remove from list"), role: .destructive) {
                        RosterStore.deleteEntry(entry, in: context)
                        dismiss()
                    }
                }
            }
            .tabBarScrollInset()
            .readableContentWidth()
            .navigationTitle(entry.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
