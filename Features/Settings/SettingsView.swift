import SwiftUI
import TabletomeDomain

struct SettingsView: View {
    @AppStorage("appearance") private var appearance = "system"

    var body: some View {
        List {
            Section(String(localized: "Appearance")) {
                Picker(String(localized: "Theme"), selection: $appearance) {
                    Text(String(localized: "System")).tag("system")
                    Text(String(localized: "Light")).tag("light")
                    Text(String(localized: "Dark")).tag("dark")
                }
                .accessibilityIdentifier("settings.appearance")
            }

            Section(String(localized: "Support")) {
                Link(String(localized: "Privacy Policy"), destination: AppLinks.privacy)
                    .accessibilityIdentifier("settings.privacy")
                Link(String(localized: "Support"), destination: AppLinks.support)
                    .accessibilityIdentifier("settings.support")
                Link(String(localized: "Accessibility Statement"), destination: AppLinks.accessibility)
                    .accessibilityIdentifier("settings.accessibility")
                if let tipJar = AppLinks.tipJar {
                    Link(String(localized: "Tip Jar"), destination: tipJar)
                        .accessibilityIdentifier("settings.tipJar")
                }
            }

            Section(String(localized: "Data")) {
                Button(role: .destructive) {
                    GuideProgressStore.resetAll()
                } label: {
                    Text(String(localized: "Reset Guide Progress"))
                        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                }
                .accessibilityIdentifier("settings.resetProgress")
            }

            Section {
                HStack {
                    Text(String(localized: "Version"))
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "Settings"))
    }
}
