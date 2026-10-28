import SwiftUI

struct AccessibilityView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text(String(localized: "Accessibility Statement"))
                    .font(TTFont.title)
                    .foregroundStyle(TTColor.inkPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text(String(localized: "Last updated: 29 June 2026"))
                    .font(TTFont.footnote)
                    .foregroundStyle(TTColor.inkSecondary)

                heading(String(localized: "Our commitment"))
                paragraph(
                    String(
                        localized: """
                        Tabletome targets WCAG 2.1 AA engineering practices on core v1.0 flows: \
                        Play (guides and Guided Match), Rules reference, Models (Collection), and Settings.
                        """
                    )
                )

                heading(String(localized: "Built-in iOS accessibility"))
                bullet(
                    String(
                        localized: """
                        **VoiceOver** — labels, hints, and identifiers on primary controls across Play, Rules, Models, and Settings.
                        """
                    )
                )
                bullet(
                    String(
                        localized: """
                        **Dynamic Type** — semantic text styles scale with your system font size; \
                        key screens adapt at the largest accessibility sizes.
                        """
                    )
                )
                bullet(String(localized: "**Touch targets** — minimum 44×44 pt on primary controls."))
                bullet(
                    String(
                        localized: "**Reduce Motion** — guide and onboarding animations respect the system setting."
                    )
                )
                bullet(String(localized: "**Dark Mode** — system, light, and dark appearance in Settings."))

                heading(String(localized: "Known limitations"))
                bullet(String(localized: "English only."))
                bullet(
                    String(
                        localized: """
                        Some dense battle-tracker layouts may require scrolling at the largest text sizes on smaller phones.
                        """
                    )
                )
                bullet(
                    String(
                        localized: "External PDF and web links open in Safari or system viewers outside the app."
                    )
                )
                bullet(
                    String(
                        localized: """
                        Tabletome does not include video content; Captions and Audio Descriptions do not apply.
                        """
                    )
                )

                heading(String(localized: "Feedback"))
                paragraph(
                    String(
                        localized: """
                        If you encounter an accessibility barrier on a core task, please file an issue with the screen name, \
                        assistive feature, and iOS version:
                        """
                    )
                )
                Link(destination: AppLinks.sourceRepository.appending(path: "issues")) {
                    Text(String(localized: "GitHub Issues"))
                }
                .buttonStyle(.ttTertiary)
                .accessibilityIdentifier("accessibility.issues")
                .accessibilityHint(String(localized: "Opens GitHub issues in Safari"))

                Link(destination: AppLinks.accessibility) {
                    Text(String(localized: "Open in Safari"))
                }
                .buttonStyle(.ttTertiary)
                .accessibilityIdentifier("accessibility.openWeb")
                .accessibilityHint(String(localized: "Opens accessibility statement in Safari"))
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .ttScreenBackground()
        .tabBarScrollInset()
        .navigationTitle(String(localized: "Accessibility Statement"))
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

#Preview("Accessibility") {
    TTPreviewMatrix {
        NavigationStack {
            AccessibilityView()
        }
    }
}
