import SwiftUI

public enum DesignTokens {
    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
    }

    public enum Radius {
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        /// Default corner radius for `surfaceCard` and `accentHighlightCard`.
        public static let lg: CGFloat = 16
    }

    public static let minTouchTarget: CGFloat = 44

    /// Max width for the battle tracker control column on regular size class (flexible below this).
    public static let battleTrackerControlColumnMaxWidth: CGFloat = 420

    /// Max width for the full battle tracker two-column layout on iPad portrait.
    public static let battleTrackerRegularMaxWidth: CGFloat = 1_120

    /// Control column width in iPad landscape (controls left).
    public static let battleTrackerLandscapeControlColumnMaxWidth: CGFloat = 380

    /// Tighter section spacing in landscape to preserve vertical space.
    public static let battleTrackerLandscapeSectionSpacing: CGFloat = 16

    /// Scroll content inset so the last rows clear the floating tab bar on iPhone.
    public static let tabBarScrollBottomInset: CGFloat = 104

    /// Extra scroll inset on Guided Match Setup when inline step controls sit above the tab bar.
    public static let guidedMatchSetupScrollExtraInset: CGFloat = 48

    /// Extra scroll inset when the phase dock sits below the battle tracker scroll view.
    public static let battleTrackerPhaseDockScrollBottomInset: CGFloat = 32

    /// Horizontal padding on iPhone landscape to preserve vertical space.
    public static let phoneLandscapeHorizontalPadding: CGFloat = 16

    /// Tighter vertical spacing between sections on iPhone landscape.
    public static let phoneLandscapeSectionSpacing: CGFloat = 12

    /// Pinned warscroll column in iPhone landscape combat split.
    public static let phoneLandscapeWarscrollColumnMinWidth: CGFloat = 140
    public static let phoneLandscapeWarscrollColumnIdealWidth: CGFloat = 180
    public static let phoneLandscapeWarscrollColumnMaxWidth: CGFloat = 220

    /// Pinned combat bar height on iPhone landscape battle tracker.
    public static let phoneLandscapeStickyBarHeight: CGFloat = 56

    /// Optional readable width cap for prose on iPhone landscape.
    public static let readableContentMaxWidthPhoneLandscape: CGFloat = 560
}
