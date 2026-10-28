import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text(String(localized: "Privacy Policy"))
                    .font(TTFont.title)
                    .foregroundStyle(TTColor.inkPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text(String(localized: "Last updated: 29 June 2026"))
                    .font(TTFont.footnote)
                    .foregroundStyle(TTColor.inkSecondary)

                heading(String(localized: "Overview"))
                paragraph(
                    String(
                        localized: """
                        Tabletome is an offline-first iOS app for tabletop battle games — Age of Sigmar: Spearhead, \
                        Warhammer 40,000 11th Edition, and Combat Patrol (10th Edition rules) in v1.0. \
                        You do not need an account. This policy describes what the app stores on your device, \
                        when it uses the network, and what may be sent to diagnostics services in Release builds.
                        """
                    )
                )

                heading(String(localized: "Data stored on your device"))
                bullet(String(localized: "**Guide progress** — optional checkmarks for Getting Started steps."))
                bullet(
                    String(
                        localized: """
                        **Guided Match state** — army selections, battle tracker, phases, and scores for in-progress games.
                        """
                    )
                )
                bullet(String(localized: "**Match history** — saved match summaries you choose to keep."))
                bullet(
                    String(
                        localized: """
                        **Collection (Models)** — armies, units, painting pipeline stages, tags, and optional unit photos you add.
                        """
                    )
                )
                bullet(
                    String(
                        localized: """
                        **Appearance and preferences** — theme, onboarding completion, and in-app tips you have seen.
                        """
                    )
                )
                bullet(
                    String(
                        localized: """
                        **Backup files** — if you export or import collection data, those files are created or read at your direction.
                        """
                    )
                )
                paragraph(
                    String(
                        localized: """
                        All of the above stays on your iPhone or iPad unless you explicitly share it \
                        (for example, exporting a backup file or a match paste code).
                        """
                    )
                )

                heading(String(localized: "Diagnostics in Release builds (Firebase)"))
                paragraph(
                    String(
                        localized: """
                        In **Release builds** from TestFlight or the App Store (not typical Debug builds from Xcode), \
                        the app may send limited, anonymous usage and crash data to **Google Firebase** (Google LLC):
                        """
                    )
                )
                bullet(
                    String(
                        localized: """
                        **Firebase Analytics** — a small allowlisted set of product-health events (for example app open, \
                        tab navigation, guided match started/completed, battle tracker actions). Parameters are restricted \
                        to non-identifying context such as game system, app version, error codes, and accessibility-setting flags. \
                        We do **not** send army names, roster names, player names, or freeform notes.
                        """
                    )
                )
                bullet(
                    String(
                        localized: """
                        **Firebase Crashlytics** — crash stack traces, allowlisted non-fatal errors, and short diagnostic \
                        breadcrumbs (event names only) to help fix bugs. No personal content from your collection or match notes \
                        is included.
                        """
                    )
                )
                paragraph(
                    String(
                        localized: """
                        We do not use Firebase for advertising, cross-app tracking, or selling personal information. \
                        Firebase is disabled in Debug builds and in builds without a valid production configuration.
                        """
                    )
                )

                heading(String(localized: "Data we do not collect"))
                bullet(String(localized: "No advertising identifiers or cross-app tracking."))
                bullet(String(localized: "No developer-operated account or cloud profile storage."))
                bullet(String(localized: "No sale of personal information."))
                bullet(String(localized: "No upload of your collection photos, army names, or match notes to Analytics."))

                heading(String(localized: "Network use"))
                bullet(
                    String(
                        localized: """
                        **Offline core** — guides, rules reference, and Guided Match work without internet after install.
                        """
                    )
                )
                bullet(
                    String(
                        localized: "**Diagnostics (Release only)** — Firebase Analytics and Crashlytics as described above."
                    )
                )
                bullet(
                    String(
                        localized: """
                        **Settings links** — Support, feedback, and the source repository open in Safari when you tap them. \
                        Privacy and the accessibility statement open in the app, with a link to the same page on the web.
                        """
                    )
                )
                bullet(
                    String(
                        localized: """
                        **Official publisher links** — optional links on game guide screens open externally \
                        (for example, Warhammer Community downloads).
                        """
                    )
                )
                bullet(
                    String(
                        localized: """
                        **Nearby match sync (optional)** — when both players choose to sync a Guided Match, the app may use \
                        local Wi‑Fi or Bluetooth between nearby devices. Match state is exchanged peer-to-peer; it is not \
                        uploaded to a Tabletome server. iOS may show a local network permission prompt the first time you host or join.
                        """
                    )
                )

                heading(String(localized: "Your choices"))
                bullet(String(localized: "Replay the app tour or battle-tracker tips from **Settings**."))
                bullet(
                    String(localized: "Export or import collection data from **Settings → Collection & Data**.")
                )
                bullet(String(localized: "Delete the app to remove all locally stored data."))

                heading(String(localized: "Children"))
                paragraph(
                    String(
                        localized: """
                        Tabletome is not directed at children under 13 and does not knowingly collect personal information from children.
                        """
                    )
                )

                heading(String(localized: "Changes"))
                paragraph(
                    String(
                        localized: """
                        We may update this policy as features change. The “Last updated” date at the top will reflect revisions.
                        """
                    )
                )

                heading(String(localized: "Contact"))
                paragraph(
                    String(localized: "Questions about privacy? See Support for how to reach the developer.")
                )
                Link(destination: AppLinks.support) {
                    Text(String(localized: "Support"))
                }
                .buttonStyle(.ttTertiary)
                .accessibilityIdentifier("privacy.support")
                .accessibilityHint(String(localized: "Opens support page in Safari"))

                Link(destination: AppLinks.privacy) {
                    Text(String(localized: "Open in Safari"))
                }
                .buttonStyle(.ttTertiary)
                .accessibilityIdentifier("privacy.openWeb")
                .accessibilityHint(String(localized: "Opens privacy policy in Safari"))
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .ttScreenBackground()
        .tabBarScrollInset()
        .navigationTitle(String(localized: "Privacy Policy"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func heading(_ title: String) -> some View {
        Text(title)
            .font(TTFont.headline)
            .foregroundStyle(TTColor.inkPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, DesignTokens.Spacing.sm)
            .accessibilityAddTraits(.isHeader)
    }

    private func paragraph(_ markdown: String) -> some View {
        markdownText(markdown)
    }

    private func bullet(_ markdown: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
            Text("•")
                .font(TTFont.body)
                .foregroundStyle(TTColor.brand)
                .accessibilityHidden(true)
            markdownText(markdown)
        }
        .accessibilityElement(children: .combine)
    }

    private func markdownText(_ markdown: String) -> some View {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        let attributed = (try? AttributedString(markdown: markdown, options: options)) ?? AttributedString(markdown)
        return Text(attributed)
            .font(TTFont.body)
            .foregroundStyle(TTColor.inkPrimary)
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Privacy Policy") {
    TTPreviewMatrix {
        NavigationStack {
            PrivacyPolicyView()
        }
    }
}
