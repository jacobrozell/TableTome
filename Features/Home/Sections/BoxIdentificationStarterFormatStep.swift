import SwiftUI

struct BoxIdentificationStarterFormatStep: View {
    let onSelect: (BoxIdentificationSheet.SciFiStarterFormat) -> Void

    var body: some View {
        Section {
            ForEach(BoxIdentificationSheet.SciFiStarterFormat.allCases) { format in
                Button {
                    onSelect(format)
                } label: {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(format.label)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(format.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                }
            }
        } header: {
            Text(String(localized: "Which 40k starter box?"))
        } footer: {
            Text(
                String(
                    localized: """
                    Combat Patrol is a different format — go back if your box says Combat Patrol on the cover.
                    """
                )
            )
        }
    }
}
