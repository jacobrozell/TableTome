import SwiftUI
import TabletomeDomain

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
    static var paintSwatch: String {
        String(
            localized: """
            Match a known paint by name, or pick a custom swatch colour. Unknown paints use a type \
            placeholder until you match or choose one.
            """
        )
    }
    static var paintCatalogSearch: String {
        String(localized: "Start typing to search the built-in Citadel and Army Painter catalog.")
    }
    static var paintCatalogPick: String {
        String(localized: "Pick a row to fill name, brand, type, and swatch colour.")
    }
    static var basingCatalogSearch: String {
        String(localized: "Search flock, tufts, texture paste, and gel basing products.")
    }
    static var basingCatalogPick: String {
        String(localized: "Pick a basing material to fill name, brand, type, and swatch colour.")
    }
    static var paintRefreshCatalog: String {
        String(
            localized: """
            Updates swatch colours from the built-in paint and basing catalogs for inventory rows that \
            aren't using a custom colour.
            """
        )
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
        String(localized: "Tap a faction to edit its abbreviation, colour, or upload a custom crest image.")
    }
    static var filterQuickView: String {
        String(localized: "Preset views for common painting progress slices.")
    }
    static var filterQuickViewBeginner: String {
        String(
            localized: """
            Backlog = still on the sprue. WIP = started painting. Table-ready = done enough to play.
            """
        )
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
    static var modelCount: String {
        String(
            localized: """
            Put the model count in parentheses — e.g. \"Clanrats (5)\" — then multiply by quantity. \
            Without parentheses, each unit entry counts as one model.
            """
        )
    }
    static var modelCountBeginner: String {
        String(
            localized: """
            Name what's on the sprue — e.g. \"Intercessors (5)\" for five models. The number in parentheses \
            is how many physical models are in that entry.
            """
        )
    }
    static var pipelineBeginner: String {
        String(
            localized: """
            Models move through painting stages left to right. Swipe right on a unit to advance — \
            most start at Unassembled on the sprue.
            """
        )
    }
    static var trackPerModel: String {
        String(
            localized: "Track painting progress for each model separately. Handy when part of a squad is further along."
        )
    }
    static var trackPerModelOff: String {
        String(localized: "All models in this entry share the starting state above.")
    }
    static var catalogPoints: String {
        String(
            localized: """
            Default points come from the bundled Games Workshop Munitorum Field Manual. You can override any unit \
            on a list — custom values stay put when you refresh from catalog.
            """
        )
    }
}

/// Live estimate of physical models for a unit name + quantity.
struct ModelCountSummary: View {
    let name: String
    let qty: Int

    private var modelCount: Int { ModelCount.of(name: name, qty: qty) }
    private var perUnit: Int { ModelCount.of(name: name, qty: 1) }
    private var hasParenCount: Bool { ModelCount.firstParenGroup(name) != nil }

    var body: some View {
        LabeledContent {
            Text(
                modelCount == 1
                    ? String(localized: "1 model")
                    : String(localized: "\(modelCount) models")
            )
            .fontWeight(.semibold)
            .accessibilityIdentifier("modelCountValue")
        } label: {
            Label(String(localized: "Physical models"), systemImage: "figure.2")
        }

        if hasParenCount, perUnit > 1 {
            if qty > 1 {
                Text(String(localized: "\(perUnit) per unit × \(qty) units"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text(String(localized: "\(perUnit) models in this unit entry"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
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
    var prompt: String?
    var focus: FocusState<Bool>.Binding

    var body: some View {
        Group {
            if let prompt {
                TextField(title, text: $text, prompt: Text(prompt))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .focused(focus)
            } else {
                TextField(title, text: $text)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .focused(focus)
            }
        }
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
