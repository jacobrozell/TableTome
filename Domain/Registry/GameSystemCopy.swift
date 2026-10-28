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
    /// Button title for "open the guide" continuation. Per-system so callers do not switch on id.
    public let openGuideButtonTitle: String
    /// Button title for resuming an in-progress Guided Match.
    public let resumeMatchButtonTitle: String
    /// Body under "Start your first match". Already includes the game's display name where needed.
    public let startGuidedMatchMessage: String
    /// Button title for starting Guided Match from Play home.
    public let startGuidedMatchButtonTitle: String
    /// Shown when a loadout step has no selectable options.
    public let emptyLoadoutOptionsMessage: String
    /// Clause after "N steps — " on the Guided Match setup caption.
    public let setupStepsDetail: String

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
        catalogLoadFailureMessage: String = String(localized: "Armies could not be loaded."),
        openGuideButtonTitle: String = String(localized: "Open game guide"),
        resumeMatchButtonTitle: String = String(localized: "Resume match"),
        startGuidedMatchMessage: String = String(localized: "Tap below to open Guided Match."),
        startGuidedMatchButtonTitle: String = String(localized: "Start Guided Match"),
        emptyLoadoutOptionsMessage: String = String(
            localized: "See your faction's free Spearhead download for regiment and enhancement options."
        ),
        setupStepsDetail: String = String(
            localized: "army pick, attacker roll, abilities, deployment, and battle"
        )
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
        self.openGuideButtonTitle = openGuideButtonTitle
        self.resumeMatchButtonTitle = resumeMatchButtonTitle
        self.startGuidedMatchMessage = startGuidedMatchMessage
        self.startGuidedMatchButtonTitle = startGuidedMatchButtonTitle
        self.emptyLoadoutOptionsMessage = emptyLoadoutOptionsMessage
        self.setupStepsDetail = setupStepsDetail
    }

    public func setupStepsCaption(stepCount: Int) -> String {
        String(localized: "\(stepCount) steps — \(setupStepsDetail)")
    }

    public var tabTitle: String { shortLabel }
    public var tabAccessibilityTitle: String { rulesTitle }
    public var rulesReferenceTitle: String { rulesTitle }
    public var searchNavigationTitle: String { rulesTitle }
    public var rulesReferenceLinkTitle: String { rulesTitle }
    public var searchResultRulesSectionTitle: String { rulesTitle }
}
