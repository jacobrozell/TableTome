import SwiftUI

/// Tab bar label with a stable accessibility identifier for UI automation.
struct TabBarItemLabel: View {
    let title: String
    let systemImage: String
    let identifier: String
    var accessibilityLabel: String?

    var body: some View {
        Label(title, systemImage: systemImage)
            .accessibilityLabel(accessibilityLabel ?? title)
            .accessibilityIdentifier(identifier)
    }
}
