import SwiftUI
import TabletomeHobbyData

struct OwnershipBadge: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let status: CollectionMatchResult.Status

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            Label(label, systemImage: symbol)
                .font(.caption)
                .foregroundStyle(color)
                .labelStyle(.titleAndIcon)
        } else {
            Image(systemName: symbol)
                .foregroundStyle(color)
                .accessibilityLabel(label)
        }
    }

    private var symbol: String {
        switch status {
        case .owned: "checkmark.circle.fill"
        case .partial: "minus.circle.fill"
        case .missing: "plus.circle.fill"
        case .unknown: "questionmark.circle"
        }
    }

    private var color: Color {
        switch status {
        case .owned: .green
        case .partial: .orange
        case .missing: .red
        case .unknown: .secondary
        }
    }

    private var label: String {
        switch status {
        case .owned: String(localized: "Owned in collection")
        case .partial: String(localized: "Partially owned")
        case .missing: String(localized: "Missing from collection")
        case .unknown: String(localized: "Collection match unknown")
        }
    }
}
