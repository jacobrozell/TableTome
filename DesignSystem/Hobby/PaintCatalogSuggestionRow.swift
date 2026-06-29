import SwiftUI
import TabletomeDomain

/// Catalog suggestion row for add-paint autocomplete.
struct PaintCatalogSuggestionRow: View {
    let entry: PaintCatalogEntry

    var body: some View {
        HStack(spacing: 12) {
            PaintSwatch(hex: entry.hex, size: 28, cornerRadius: 6)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                let meta = [entry.category, entry.type, entry.brand]
                    .compactMap { $0 }
                    .filter { !$0.isEmpty }
                    .joined(separator: " · ")
                if !meta.isEmpty {
                    Text(meta)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            [entry.name, entry.type, entry.brand].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
        )
    }
}
