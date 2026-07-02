import SwiftUI
import TabletomeDomain

struct RosterStalePointsBanner: View {
    let status: RosterCatalogSync.Status
    let onRefresh: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.title3)
                .foregroundStyle(Color.accentOnSurface)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "Points update available"))
                    .font(.subheadline.weight(.semibold))
                if status.driftCount > 0 {
                    Text(
                        String(
                            localized: """
                            \(status.driftCount) unit\(status.driftCount == 1 ? "" : "s") differ from catalog \
                            (MFM \(status.catalogPointsKey)).
                            """
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    if status.customOverrideCount > 0 {
                        HStack(spacing: 6) {
                            PointsSourceViews.customPointsBadge(compact: true)
                            Text(
                                String(
                                    localized: """
                                    \(status.customOverrideCount) custom value\(status.customOverrideCount == 1 ? "" : "s") \
                                    will be left unchanged.
                                    """
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                } else if status.hasVersionDrift {
                    Text(
                        String(
                            localized: """
                            Catalog updated to \(status.catalogVersion) — refresh list points to match GW values.
                            """
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } else {
                    Text(String(localized: "Some units are no longer in the catalog."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Button(String(localized: "Update now"), systemImage: "arrow.triangle.2.circlepath") {
                    onRefresh()
                }
                .font(.caption.weight(.semibold))
                .buttonStyle(.bordered)
                .padding(.top, 2)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(String(localized: "Points update available from catalog"))
    }
}
