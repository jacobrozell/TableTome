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
            else {
                ContentUnavailableView {
                    Label(String(localized: "Paint not found"), systemImage: "paintpalette")
                } description: {
                    Text(String(localized: "This paint may have been deleted."))
                }
            }
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
                HStack(spacing: 14) {
                    PaintSwatch(hex: paint.swatchHex, size: 56, cornerRadius: 10)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(paint.name)
                                .font(.headline)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            if paint.low {
                                Text(String(localized: "LOW"))
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.orange.opacity(0.2), in: Capsule())
                                    .foregroundStyle(.orange)
                            }
                        }
                        let meta = [paint.type, paint.brand].filter { !$0.isEmpty }.joined(separator: " · ")
                        if !meta.isEmpty {
                            Text(meta)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        if paint.qty > 1 {
                            Text(String(localized: "\(paint.qty) pots"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 4)
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
                if !paint.source.isEmpty {
                    LabeledContent(String(localized: "Linked units"), value: "\(linked)")
                    Button(String(localized: "Show in Collection"), systemImage: "link") {
                        router.showArmies(filteredBySource: paint.source)
                        banner.show(String(localized: "Filtered by source: \(paint.source)"))
                        filterTrigger.toggle()
                    }
                }
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

            Section {
                Button(String(localized: "Delete paint"), role: .destructive) { confirmDelete = true }
            }
        }
        .tabBarScrollInset()
        .readableContentWidth()
        .onDisappear { try? context.save() }
    }

    private var typeOptions: [String] {
        var seen = Set<String>()
        return (PaintType.known + types).filter { seen.insert($0).inserted }
    }
}
