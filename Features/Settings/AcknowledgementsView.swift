import SwiftUI

struct AcknowledgementsView: View {
    /// Full Settings trademark paragraph, copied verbatim from the previous About section.
    private static let trademarkDisclaimer = String(localized: """
        Unofficial fan-made companion. Not affiliated with, endorsed, or sponsored by Games Workshop. \
        Warhammer, Age of Sigmar, Warhammer 40,000, Spearhead, Combat Patrol, and all associated names, \
        logos, and images are trademarks of Games Workshop Limited. Rules content is original explanation \
        written for learning and play, not reproduced from official publications.
        """)

    /// Rules-content sentence, copied verbatim from that same paragraph.
    private static let rulesContentNote = String(localized: """
        Rules content is original explanation written for learning and play, not reproduced from official publications.
        """)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text(String(localized: "Acknowledgements & Trademarks"))
                    .font(TTFont.title)
                    .foregroundStyle(TTColor.inkPrimary)
                    .accessibilityAddTraits(.isHeader)

                Text(Self.trademarkDisclaimer)
                    .font(TTFont.body)
                    .foregroundStyle(TTColor.inkPrimary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(String(localized: "Rules content"))
                    .font(TTFont.headline)
                    .foregroundStyle(TTColor.inkPrimary)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, DesignTokens.Spacing.sm)

                Text(Self.rulesContentNote)
                    .font(TTFont.body)
                    .foregroundStyle(TTColor.inkPrimary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(String(localized: "Open source"))
                    .font(TTFont.headline)
                    .foregroundStyle(TTColor.inkPrimary)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, DesignTokens.Spacing.sm)

                Text(
                    String(
                        localized: """
                        This app includes the Firebase iOS SDK (FirebaseCore, FirebaseAnalytics, \
                        and FirebaseCrashlytics), copyright Google LLC. Licensed under the Apache License, \
                        Version 2.0.
                        """
                    )
                )
                .font(TTFont.body)
                .foregroundStyle(TTColor.inkPrimary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

                if let firebaseURL = URL(string: "https://github.com/firebase/firebase-ios-sdk") {
                    Link(destination: firebaseURL) {
                        Text(String(localized: "Firebase iOS SDK"))
                    }
                    .buttonStyle(.ttTertiary)
                    .accessibilityIdentifier("settings.acknowledgements.firebase")
                    .accessibilityHint(String(localized: "Opens the Firebase iOS SDK repository in Safari"))
                }

                if let licenseURL = URL(string: "https://www.apache.org/licenses/LICENSE-2.0") {
                    Link(destination: licenseURL) {
                        Text(String(localized: "Apache License 2.0"))
                    }
                    .buttonStyle(.ttTertiary)
                    .accessibilityIdentifier("settings.acknowledgements.license")
                    .accessibilityHint(String(localized: "Opens the Apache License, Version 2.0, in Safari"))
                }
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .ttScreenBackground()
        .tabBarScrollInset()
        .navigationTitle(String(localized: "Acknowledgements & Trademarks"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Acknowledgements") {
    TTPreviewMatrix {
        NavigationStack {
            AcknowledgementsView()
        }
    }
}
