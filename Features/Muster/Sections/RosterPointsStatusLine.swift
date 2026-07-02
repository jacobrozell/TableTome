import SwiftUI

struct RosterPointsStatusLine: View {
    let total: Int
    let limit: Int
    let remaining: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "chart.bar.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.accentOnSurface)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
            Text(String(localized: "\(total) / \(limit) pts · \(remaining) remaining"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .accessibilityLabel(String(localized: "\(total) of \(limit) points, \(remaining) remaining"))
    }
}
