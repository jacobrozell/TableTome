import SwiftUI

public enum TTFont {
    public static let display = Font.system(.largeTitle, design: .serif).weight(.bold)
    public static let title = Font.system(.title2, design: .serif).weight(.semibold)
    public static let titleSmall = Font.system(.title3, design: .serif).weight(.semibold)
    public static let headline = Font.headline
    public static let body = Font.body
    public static let bodyEmphasis = Font.body.weight(.semibold)
    public static let callout = Font.callout
    public static let subheadline = Font.subheadline
    public static let footnote = Font.footnote
    public static let caption = Font.caption
    public static let numericHero = Font.system(.largeTitle, design: .rounded).weight(.bold).monospacedDigit()
    public static let numericLarge = Font.system(.title, design: .rounded).weight(.bold).monospacedDigit()
    public static let numericMedium = Font.system(.title3, design: .rounded).weight(.semibold).monospacedDigit()
    public static let numericSmall = Font.system(.subheadline, design: .rounded).weight(.semibold).monospacedDigit()
    public static let button = Font.headline
    public static let buttonSmall = Font.subheadline.weight(.semibold)
}

public extension View {
    /// Small uppercase label above a card or group ("THIS PHASE").
    func ttEyebrow(_ color: Color = TTColor.inkSecondary) -> some View {
        font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .tracking(0.8)
            .foregroundStyle(color)
    }
}
