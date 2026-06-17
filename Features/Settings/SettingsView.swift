import SwiftUI
import TabletomeDomain

struct SettingsView: View {
    @AppStorage("appearance") private var appearance = "system"
    @State private var showResetConfirmation = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Offline Spearhead guide and rules reference."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(String(localized: "Unofficial fan app — not affiliated with Games Workshop."))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, DesignTokens.Spacing.xs)
                .accessibilityElement(children: .combine)
            } header: {
                Text(String(localized: "About"))
            }

            Section(String(localized: "Appearance")) {
                Picker(String(localized: "Theme"), selection: $appearance) {
                    Text(String(localized: "System")).tag("system")
                    Text(String(localized: "Light")).tag("light")
                    Text(String(localized: "Dark")).tag("dark")
                }
                .accessibilityIdentifier("settings.appearance")
                .accessibilityHint(String(localized: "Changes app color scheme"))
            }

            Section(String(localized: "Support & Legal")) {
                settingsLink(
                    title: String(localized: "Privacy Policy"),
                    systemImage: "hand.raised",
                    destination: AppLinks.privacy,
                    identifier: "settings.privacy",
                    hint: String(localized: "Opens privacy policy in Safari")
                )
                settingsLink(
                    title: String(localized: "Support"),
                    systemImage: "lifepreserver",
                    destination: AppLinks.support,
                    identifier: "settings.support",
                    hint: String(localized: "Opens support page in Safari")
                )
                settingsLink(
                    title: String(localized: "Accessibility Statement"),
                    systemImage: "accessibility",
                    destination: AppLinks.accessibility,
                    identifier: "settings.accessibility",
                    hint: String(localized: "Opens accessibility statement in Safari")
                )
                settingsLink(
                    title: String(localized: "Buy Me a Coffee"),
                    systemImage: "cup.and.saucer",
                    destination: AppLinks.tipJar,
                    identifier: "settings.tipJar",
                    hint: String(localized: "Opens tip page in Safari")
                )
                settingsLink(
                    title: String(localized: "Source Code"),
                    systemImage: "chevron.left.forwardslash.chevron.right",
                    destination: AppLinks.sourceRepository,
                    identifier: "settings.sourceCode",
                    hint: String(localized: "Opens project repository in Safari")
                )
            }

            Section {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Label(String(localized: "Reset Guide Progress"), systemImage: "arrow.counterclockwise")
                        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                }
                .accessibilityIdentifier("settings.resetProgress")
                .accessibilityHint(String(localized: "Clears all Getting Started checkmarks"))
            } header: {
                Text(String(localized: "Data"))
            } footer: {
                Text(String(localized: "Guide checkmarks are stored only on this device."))
            }

            Section {
                LabeledContent(String(localized: "Version"), value: appVersion)
                LabeledContent(String(localized: "Build"), value: appBuild)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "Settings"))
        .confirmationDialog(
            String(localized: "Reset guide progress?"),
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Reset"), role: .destructive) {
                GuideProgressStore.resetAll()
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "This removes all Getting Started checkmarks. This cannot be undone."))
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    @ViewBuilder
    private func settingsLink(
        title: String,
        systemImage: String,
        destination: URL?,
        identifier: String,
        hint: String
    ) -> some View {
        if let destination {
            Link(destination: destination) {
                Label(title, systemImage: systemImage)
                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
            }
            .accessibilityIdentifier(identifier)
            .accessibilityHint(hint)
        }
    }
}
