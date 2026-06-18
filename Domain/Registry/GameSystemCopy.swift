import Foundation

public struct GameSystemCopy: Sendable, Equatable {
    public let shortLabel: String
    public let rulesTitle: String
    public let glossaryTitle: String
    public let searchPrompt: String
    public let rulesSearchPrompt: String
    public let browseIntro: String
    public let gameGuideBrowseTitle: String
    public let searchEmptyStateHint: String
    public let displayName: String
    public let searchPickerLabel: String
    public let catalogLoadFailureMessage: String

    public init(
        shortLabel: String,
        rulesTitle: String,
        glossaryTitle: String,
        searchPrompt: String,
        rulesSearchPrompt: String,
        browseIntro: String,
        gameGuideBrowseTitle: String,
        searchEmptyStateHint: String,
        displayName: String,
        searchPickerLabel: String,
        catalogLoadFailureMessage: String = String(localized: "Armies could not be loaded.")
    ) {
        self.shortLabel = shortLabel
        self.rulesTitle = rulesTitle
        self.glossaryTitle = glossaryTitle
        self.searchPrompt = searchPrompt
        self.rulesSearchPrompt = rulesSearchPrompt
        self.browseIntro = browseIntro
        self.gameGuideBrowseTitle = gameGuideBrowseTitle
        self.searchEmptyStateHint = searchEmptyStateHint
        self.displayName = displayName
        self.searchPickerLabel = searchPickerLabel
        self.catalogLoadFailureMessage = catalogLoadFailureMessage
    }

    public var tabTitle: String { shortLabel }
    public var tabAccessibilityTitle: String { rulesTitle }
    public var rulesReferenceTitle: String { rulesTitle }
    public var searchNavigationTitle: String { rulesTitle }
    public var rulesReferenceLinkTitle: String { rulesTitle }
    public var searchResultRulesSectionTitle: String { rulesTitle }
}
