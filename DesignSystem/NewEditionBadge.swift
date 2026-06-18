import SwiftUI

/// Capsule label for freshly launched game editions.
struct NewEditionBadge: View {
    var body: some View {
        Text(String(localized: "NEW"))
            .font(.caption2.weight(.bold))
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.accentColor.opacity(0.14), in: Capsule())
            .accessibilityLabel(String(localized: "New edition"))
    }
}
