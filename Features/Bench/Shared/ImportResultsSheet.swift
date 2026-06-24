import SwiftUI

/// Import summary presented after CSV import from Settings.
struct ImportResultsSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let message: String
    let warnings: [String]
    let failed: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: failed ? "xmark.circle.fill" : "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(failed ? Color.red : Color.accentOnSurface)
                            .symbolRenderingMode(.hierarchical)
                            .accessibilityHidden(true)
                        Text(message)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(
                        failed
                            ? String(localized: "Import failed, \(message)")
                            : String(localized: "Import complete, \(message)")
                    )
                }

                if !warnings.isEmpty {
                    Section {
                        ForEach(warnings, id: \.self) { warning in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                    .symbolRenderingMode(.hierarchical)
                                    .padding(.top, 2)
                                    .accessibilityHidden(true)
                                Text(warning)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    } header: {
                        Text(String(localized: "Warnings (\(warnings.count))"))
                    } footer: {
                        Text(
                            String(
                                localized: "Rows with warnings were still imported when possible. Review your collection after import."
                            )
                        )
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                }
            }
        }
    }
}
