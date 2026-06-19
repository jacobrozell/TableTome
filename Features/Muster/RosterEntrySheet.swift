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
                    LabeledContent("ArmyUnit", value: entry.displayName)
                    QuantityStepper(label: "Quantity", value: Binding(
                        get: { entry.qty },
                        set: { RosterStore.setQty(entry, $0, in: context) }
                    ), range: 1...HobbyLimits.maxRosterQty)
                } header: {
                    Text("Entry")
                }

                Section {
                    LabeledContent("Points each", value: "\(entry.pointsEach)")
                    LabeledContent("Total", value: "\(entry.pointsTotal) pts")
                } header: {
                    Text("Points")
                }

                Section {
                    Button("Remove from list", role: .destructive) {
                        RosterStore.deleteEntry(entry, in: context)
                        dismiss()
                    }
                }
            }
            .navigationTitle(entry.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
