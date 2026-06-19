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
            else { ContentUnavailableView(String(localized: "Paint not found"), systemImage: "paintpalette") }
        }
        .navigationTitle(paint?.name ?? String(localized: "Paint"))
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            String(localized: "Delete \"\(paint?.name ?? "")\"?"),
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Delete"), role: .destructive) {
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
                TextField(String(localized: "Name"), text: $paint.name)
                    .textInputAutocapitalization(.words)
                Picker(String(localized: "Type"), selection: $paint.type) {
                    ForEach(typeOptions, id: \.self) { Text($0.isEmpty ? "—" : $0).tag($0) }
                }
                .formNavigationPickerStyle()
                TextField(String(localized: "Brand"), text: $paint.brand)
                    .textInputAutocapitalization(.words)
            } header: {
                Text(String(localized: "Paint"))
            }

            Section {
                QuantityStepper(label: String(localized: "Quantity"), value: $paint.qty)
                Toggle(String(localized: "Running low"), isOn: $paint.low)
            } header: {
                Text(String(localized: "Inventory"))
            } footer: {
                Text(FormHints.paintLow)
            }

            Section {
                TextField(String(localized: "Source"), text: $paint.source)
                    .textInputAutocapitalization(.words)
            } header: {
                Text(String(localized: "Collection link"))
            } footer: {
                Text(FormHints.paintSource)
            }

            Section {
                FormNotesField(title: String(localized: "Notes"), text: $paint.notes, lineLimit: 2...6)
            } header: {
                Text(String(localized: "Notes"))
            }
            if !paint.source.isEmpty {
                Section(String(localized: "Collection link")) {
                    LabeledContent(String(localized: "Linked units"), value: "\(linked)")
                    Button(String(localized: "Show in Collection"), systemImage: "link") {
                        router.showArmies(filteredBySource: paint.source)
                        banner.show(String(localized: "Filtered by source: \(paint.source)"))
                        filterTrigger.toggle()
                    }
                }
            }
            Section {
                Button(String(localized: "Delete paint"), role: .destructive) { confirmDelete = true }
            }
        }
        .onDisappear { try? context.save() }
    }

    private var typeOptions: [String] {
        var seen = Set<String>()
        return (PaintType.known + types).filter { seen.insert($0).inserted }
    }
}
