import SwiftUI

/// Shared capsule label for newcomer recommendations and edition markers.
enum GuideBadgeStyle: Equatable {
    case recommended
    case newEdition
    case custom(String)
}

struct GuideBadge: View {
    let style: GuideBadgeStyle

    private var label: String {
        switch style {
        case .recommended:
            String(localized: "Good first game")
        case .newEdition:
            String(localized: "NEW")
        case .custom(let text):
            text
        }
    }

    private var accessibilityLabel: String {
        switch style {
        case .recommended:
            String(localized: "Good first game")
        case .newEdition:
            String(localized: "New edition")
        case .custom(let text):
            text
        }
    }

    var body: some View {
        Text(label)
            .font(.caption2.weight(.bold))
            .foregroundStyle(Color.accentOnSurface)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.accentColor.opacity(0.14), in: Capsule())
            .accessibilityLabel(accessibilityLabel)
    }
}
