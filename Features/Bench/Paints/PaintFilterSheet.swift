import SwiftUI
import TabletomeHobbyData

struct PaintFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var cfg: AppConfiguration

    let types: [String]
    let brands: [String]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(String(localized: "Type"), selection: $cfg.paintTypeFilter) {
                        ForEach(["All"] + types, id: \.self) { Text($0).tag($0) }
                    }
                    .formNavigationPickerStyle()
                    Picker(String(localized: "Brand"), selection: $cfg.paintBrandFilter) {
                        ForEach(["All"] + brands, id: \.self) { Text($0).tag($0) }
                    }
                    .formNavigationPickerStyle()
                    Toggle(String(localized: "Running low only"), isOn: $cfg.paintLowOnly)
                } header: {
                    Text(String(localized: "Filter by"))
                } footer: {
                    Text(FormHints.paintFilter)
                }

                Section {
                    Button(String(localized: "Clear filters"), role: .destructive) {
                        cfg.paintTypeFilter = "All"
                        cfg.paintBrandFilter = "All"
                        cfg.paintLowOnly = false
                        try? context.save()
                        dismiss()
                    }
                }
            }
            .navigationTitle(String(localized: "Paint filters"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { try? context.save(); dismiss() }
                }
            }
        }
    }
}
