import SwiftUI

struct RosterFieldableSummary: View {
    let fieldablePercent: Int
    let ownershipCounts: (owned: Int, partial: Int, missing: Int)

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            ProgressRing(percent: fieldablePercent, diameter: 36)
                .accessibilityLabel(String(localized: "\(fieldablePercent) percent fieldable"))
            if ownershipCounts.owned + ownershipCounts.partial + ownershipCounts.missing > 0 {
                Text(ownershipSummaryLine)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var ownershipSummaryLine: String {
        var parts: [String] = []
        if ownershipCounts.owned > 0 {
            parts.append(String(localized: "\(ownershipCounts.owned) owned"))
        }
        if ownershipCounts.partial > 0 {
            parts.append(String(localized: "\(ownershipCounts.partial) partial"))
        }
        if ownershipCounts.missing > 0 {
            parts.append(String(localized: "\(ownershipCounts.missing) missing"))
        }
        return parts.joined(separator: " · ")
    }
}
