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
        public static let lg: CGFloat = 16
    }

    public static let minTouchTarget: CGFloat = 44

    /// Max width for the battle tracker control column on regular size class (flexible below this).
    public static let battleTrackerControlColumnMaxWidth: CGFloat = 360

    /// Max width for the full battle tracker two-column layout on iPad portrait.
    public static let battleTrackerRegularMaxWidth: CGFloat = 1_120

    /// Control column width in iPad landscape (controls left).
    public static let battleTrackerLandscapeControlColumnMaxWidth: CGFloat = 300

    /// Army health sidebar width in iPad landscape.
    public static let battleTrackerLandscapeArmyColumnMaxWidth: CGFloat = 340

    /// Tighter section spacing in landscape to preserve vertical space.
    public static let battleTrackerLandscapeSectionSpacing: CGFloat = 16

    /// Scroll content inset so the last rows clear the floating tab bar on iPhone.
    public static let tabBarScrollBottomInset: CGFloat = 64
}
