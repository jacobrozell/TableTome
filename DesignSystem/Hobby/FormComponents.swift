import SwiftUI

/// Shared copy for form section footers.
enum FormHints {
    static var source: String {
        String(localized: "Box, kit, or set name. Links paints and units in your collection.")
    }
    static var paintSource: String {
        String(localized: "Same string on units lets you jump from paint to collection.")
    }
    static var notesTags: String {
        String(localized: "Add #tags in notes to filter later.")
    }
    static var paintLow: String {
        String(localized: "Flag bottles you want to restock.")
    }
    static var uniqueName: String {
        String(localized: "Names must be unique.")
    }
    static var rosterLink: String {
        String(localized: "Match painted models to units on this list.")
    }
    static var pipelineStages: String {
        String(localized: "Stages run left to right. Drag to reorder, swipe to delete.")
    }
    static var factionCrest: String {
        String(localized: "Short abbreviation shown on army rows. Up to 8 characters.")
    }
    static var filterQuickView: String {
        String(localized: "Preset views for common painting progress slices.")
    }
    static var filterNarrow: String {
        String(localized: "Combine filters to focus on one army, state, or box.")
    }
    static var filterSort: String {
        String(localized: "Applies to the current filtered list.")
    }
    static var paintFilter: String {
        String(localized: "Filter your paint shelf by type, brand, or restock needs.")
    }
}

/// Consistent quantity control used across collection and paint forms.
struct QuantityStepper: View {
    let label: String
    @Binding var value: Int
    var range: ClosedRange<Int> = 1...9999

    var body: some View {
        Stepper(value: $value, in: range) {
            Text(String(localized: "\(label): \(value)"))
        }
        .accessibilityValue("\(value)")
    }
}

/// Multiline notes field with consistent sizing.
struct FormNotesField: View {
    let title: String
    @Binding var text: String
    var lineLimit: ClosedRange<Int> = 3...8

    var body: some View {
        TextField(title, text: $text, axis: .vertical)
            .lineLimit(lineLimit)
    }
}

/// Primary name field for add/rename sheets — capitalizes words and submits on Return.
struct FormNameField: View {
    let title: String
    @Binding var text: String
    var focus: FocusState<Bool>.Binding

    var body: some View {
        TextField(title, text: $text)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .focused(focus)
    }
}

/// Inline validation message shown as a section footer.
struct FormValidationFooter: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.red)
    }
}
