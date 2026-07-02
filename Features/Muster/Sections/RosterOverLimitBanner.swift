import SwiftUI

struct RosterOverLimitBanner: View {
    let total: Int
    let limit: Int

    var body: some View {
        let overBy = total - limit
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(.red)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "Over point limit"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
                Text(
                    String(
                        localized: """
                        \(total) / \(limit) pts (\(overBy) over) — remove units or lower quantities.
                        """
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                .strokeBorder(Color.red.opacity(0.28), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            String(localized: "Over point limit, \(total) of \(limit) points, \(overBy) over limit")
        )
    }
}
