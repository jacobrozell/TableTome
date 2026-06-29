import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

/// Swatch colour controls for paint inventory — match a known pot colour or pick a custom one.
struct PaintColorSection: View {
    @Binding var swatchHex: String
    @Binding var usesCustomSwatch: Bool
    let name: String
    let brand: String
    let type: String

    private var pickerColor: Binding<Color> {
        Binding(
            get: { Color(hex: swatchHex) },
            set: {
                swatchHex = $0.hexString
                usesCustomSwatch = true
            }
        )
    }

    private var catalogMatch: String? {
        PaintInventoryCatalog.lookup(name: name, brand: brand)
    }

    private var footerText: String {
        if usesCustomSwatch {
            return String(localized: "Custom colour — won't change when you edit the name or type.")
        }
        if catalogMatch != nil {
            return String(localized: "Matched to a known paint colour. Edit the name to re-match.")
        }
        return FormHints.paintSwatch
    }

    var body: some View {
        Section {
            HStack(spacing: 14) {
                PaintSwatch(hex: swatchHex, size: 44, cornerRadius: 8)
                ColorPicker(String(localized: "Swatch colour"), selection: pickerColor, supportsOpacity: false)
            }
            .padding(.vertical, 2)

            Button {
                applyCatalogMatch()
            } label: {
                Label(String(localized: "Match paint colour"), systemImage: "eyedropper")
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        } header: {
            Text(String(localized: "Colour"))
        } footer: {
            Text(footerText)
        }
        .onChange(of: name) { _, _ in refreshAutomaticSwatch() }
        .onChange(of: brand) { _, _ in refreshAutomaticSwatch() }
        .onChange(of: type) { _, _ in refreshAutomaticSwatch() }
    }

    private func applyCatalogMatch() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        swatchHex = PaintSwatchResolver.defaultSwatch(name: trimmedName, brand: brand, type: type)
        usesCustomSwatch = false
    }

    private func refreshAutomaticSwatch() {
        guard !usesCustomSwatch else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        swatchHex = PaintSwatchResolver.defaultSwatch(
            name: trimmedName.isEmpty ? name : trimmedName,
            brand: brand,
            type: type
        )
    }
}
