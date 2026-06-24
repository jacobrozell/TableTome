import SwiftUI
import TabletomeHobbyData

struct PaintFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var cfg: AppConfiguration

    let types: [String]
    let brands: [String]

    private var filtersActive: Bool { PaintFilter.isActive(cfg, search: "") }
    private var filterCount: Int { PaintFilter.activeFilterCount(cfg) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if filtersActive {
                        Label(
                            filterCount == 1
                                ? String(localized: "1 filter active")
                                : String(localized: "\(filterCount) filters active"),
                            systemImage: "line.3.horizontal.decrease.circle.fill"
                        )
                        .font(.subheadline)
                        .foregroundStyle(Color.accentOnSurface)
                        .symbolRenderingMode(.hierarchical)
                    } else {
                        Label(
                            String(localized: "No filters active"),
                            systemImage: "line.3.horizontal.decrease.circle"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Picker(String(localized: "Type"), selection: $cfg.paintTypeFilter) {
                        ForEach(["All"] + types, id: \.self) { type in
                            HStack(spacing: 8) {
                                if type != "All" {
                                    Image(systemName: "paintbrush.pointed")
                                        .font(.caption)
                                        .foregroundStyle(Color.accentOnSurface)
                                        .symbolRenderingMode(.hierarchical)
                                        .frame(width: 20)
                                        .accessibilityHidden(true)
                                }
                                Text(type)
                            }
                            .tag(type)
                        }
                    }
                    .formNavigationPickerStyle()
                    Picker(String(localized: "Brand"), selection: $cfg.paintBrandFilter) {
                        ForEach(["All"] + brands, id: \.self) { brand in
                            HStack(spacing: 8) {
                                if brand != "All" {
                                    Image(systemName: "tag")
                                        .font(.caption)
                                        .foregroundStyle(Color.accentOnSurface)
                                        .frame(width: 20)
                                        .accessibilityHidden(true)
                                }
                                Text(brand)
                            }
                            .tag(brand)
                        }
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
                        PaintFilter.clearFilters(cfg)
                        try? context.save()
                        dismiss()
                    }
                    .disabled(!filtersActive)
                }
            }
            .navigationTitle(String(localized: "Paint filters"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { try? context.save(); dismiss() }
                }
            }
        }
    }
}
