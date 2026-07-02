import SwiftUI
import TabletomeDomain

struct BoxIdentificationGenreStep: View {
    let visibleGenres: [BoxIdentificationSheet.Genre]
    let onSelect: (BoxIdentificationSheet.Genre) -> Void

    var body: some View {
        Section {
            ForEach(visibleGenres) { option in
                Button {
                    onSelect(option)
                } label: {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(option.label)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(option.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                }
            }
        } header: {
            Text(String(localized: "What kind of game is on the box?"))
        } footer: {
            Text(String(localized: "Look at the logo and faction name — we will suggest the right Play option."))
        }
    }
}
