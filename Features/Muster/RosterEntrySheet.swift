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
                    HStack(spacing: 12) {
                        Image(systemName: "figure.stand")
                            .font(.title2)
                            .foregroundStyle(Color.accentOnSurface)
                            .symbolRenderingMode(.hierarchical)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.displayName)
                                .font(.headline)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(String(localized: "Qty \(entry.qty)"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 8)
                        Text(String(localized: "\(entry.pointsTotal) pts"))
                            .font(.subheadline.weight(.semibold).monospacedDigit())
                            .foregroundStyle(Color.accentOnSurface)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.accentColor.opacity(0.12), in: Capsule())
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    QuantityStepper(label: String(localized: "Quantity"), value: Binding(
                        get: { entry.qty },
                        set: { RosterStore.setQty(entry, $0, in: context) }
                    ), range: 1...HobbyLimits.maxRosterQty)
                } header: {
                    Text(String(localized: "Entry"))
                }

                Section {
                    LabeledContent(String(localized: "Points each"), value: "\(entry.pointsEach)")
                    LabeledContent(String(localized: "Line total"), value: String(localized: "\(entry.pointsTotal) pts"))
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
