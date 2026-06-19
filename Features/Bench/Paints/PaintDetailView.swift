import SwiftUI
import SwiftData
import TabletomeHobbyData

@MainActor
struct PaintDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(AppRouter.self) private var router
    @Environment(BannerCenter.self) private var banner
    @Query private var armies: [Army]
    @Query private var allPaints: [HobbyPaint]

    let paintId: UUID

    @State private var confirmDelete = false
    @State private var filterTrigger = false

    private var paint: HobbyPaint? { allPaints.first { $0.id == paintId } }
    private var types: [String] {
        Array(Set(allPaints.map(\.type).filter { !$0.isEmpty })).sorted()
    }

    var body: some View {
        Group {
            if let paint { form(paint) }
            else { ContentUnavailableView("HobbyPaint not found", systemImage: "paintpalette") }
        }
        .navigationTitle(paint?.name ?? "HobbyPaint")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete \"\(paint?.name ?? "")\"?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let paint {
                    PaintStore.delete(paint, in: context)
                    dismiss()
                }
            }
        }
        .sensoryFeedback(.selection, trigger: filterTrigger)
    }

    @ViewBuilder
    private func form(_ paint: HobbyPaint) -> some View {
        @Bindable var paint = paint
        let linked = PaintStore.linkedUnitCount(source: paint.source, armies: armies)
        Form {
            Section {
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: paint.swatchHex))
                        .frame(width: 48, height: 48)
                    Spacer()
                }
            }
            Section {
                TextField("Name", text: $paint.name)
                    .textInputAutocapitalization(.words)
                Picker("Type", selection: $paint.type) {
                    ForEach(typeOptions, id: \.self) { Text($0.isEmpty ? "—" : $0).tag($0) }
                }
                .formNavigationPickerStyle()
                TextField("Brand", text: $paint.brand)
                    .textInputAutocapitalization(.words)
            } header: {
                Text("HobbyPaint")
            }

            Section {
                QuantityStepper(label: "Quantity", value: $paint.qty)
                Toggle("Running low", isOn: $paint.low)
            } header: {
                Text("Inventory")
            } footer: {
                Text(FormHints.paintLow)
            }

            Section {
                TextField("Source", text: $paint.source)
                    .textInputAutocapitalization(.words)
            } header: {
                Text("Collection link")
            } footer: {
                Text(FormHints.paintSource)
            }

            Section {
                FormNotesField(title: "Notes", text: $paint.notes, lineLimit: 2...6)
            } header: {
                Text("Notes")
            }
            if !paint.source.isEmpty {
                Section("Collection link") {
                    LabeledContent("Linked units", value: "\(linked)")
                    Button("Show in Collection", systemImage: "link") {
                        router.showArmies(filteredBySource: paint.source)
                        banner.show("Filtered by source: \(paint.source)")
                        filterTrigger.toggle()
                    }
                }
            }
            Section {
                Button("Delete paint", role: .destructive) { confirmDelete = true }
            }
        }
        .onDisappear { try? context.save() }
    }

    private var typeOptions: [String] {
        var seen = Set<String>()
        return (PaintType.known + types).filter { seen.insert($0).inserted }
    }
}
