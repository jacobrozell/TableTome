import SwiftUI

public struct TTPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.controlSize) private var controlSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var fullWidth: Bool = true

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(controlSize == .small ? TTFont.buttonSmall : TTFont.button)
            .foregroundStyle(TTColor.inkOnBrand)
            .symbolRenderingMode(.monochrome)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(minHeight: height)
            .background(
                TTColor.brandFill,
                in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
            )
            .opacity(isEnabled ? (configuration.isPressed ? 0.9 : 1) : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(TTMotion.press(reduceMotion: reduceMotion), value: configuration.isPressed)
            .contentShape(Rectangle())
    }

    private var height: CGFloat {
        if controlSize == .small { return 36 }
        return verticalSizeClass == .compact ? 50 : 52
    }
}

public struct TTSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.controlSize) private var controlSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var fullWidth: Bool = true

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(controlSize == .small ? TTFont.buttonSmall : TTFont.button)
            .foregroundStyle(TTColor.inkPrimary)
            .symbolRenderingMode(.monochrome)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(minHeight: height)
            .background(
                TTColor.raised,
                in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                    .strokeBorder(TTColor.strokeStrong, lineWidth: 1)
            }
            .opacity(isEnabled ? (configuration.isPressed ? 0.9 : 1) : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(TTMotion.press(reduceMotion: reduceMotion), value: configuration.isPressed)
            .contentShape(Rectangle())
    }

    private var height: CGFloat {
        if controlSize == .small { return 36 }
        return verticalSizeClass == .compact ? 50 : 52
    }
}

public struct TTTertiaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TTFont.buttonSmall)
            .foregroundStyle(TTColor.brand)
            .symbolRenderingMode(.monochrome)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .frame(minHeight: DesignTokens.minTouchTarget)
            .opacity(isEnabled ? (configuration.isPressed ? 0.9 : 1) : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(TTMotion.press(reduceMotion: reduceMotion), value: configuration.isPressed)
            .contentShape(Rectangle())
    }
}

public struct TTDestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.controlSize) private var controlSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var fullWidth: Bool = true

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(controlSize == .small ? TTFont.buttonSmall : TTFont.button)
            .foregroundStyle(TTColor.danger)
            .symbolRenderingMode(.monochrome)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(minHeight: height)
            .background(
                TTColor.dangerSoft,
                in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
            )
            .opacity(isEnabled ? (configuration.isPressed ? 0.9 : 1) : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(TTMotion.press(reduceMotion: reduceMotion), value: configuration.isPressed)
            .contentShape(Rectangle())
    }

    private var height: CGFloat {
        if controlSize == .small { return 36 }
        return verticalSizeClass == .compact ? 50 : 52
    }
}

public struct TTPlayerButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.controlSize) private var controlSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var isPlayerOne: Bool
    var fullWidth: Bool = true

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(controlSize == .small ? TTFont.buttonSmall : TTFont.button)
            .foregroundStyle(TTColor.inkOnPlayer)
            .symbolRenderingMode(.monochrome)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(minHeight: height)
            .background(
                TTColor.player(isPlayerOne),
                in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
            )
            .opacity(isEnabled ? (configuration.isPressed ? 0.9 : 1) : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(TTMotion.press(reduceMotion: reduceMotion), value: configuration.isPressed)
            .contentShape(Rectangle())
    }

    private var height: CGFloat {
        if controlSize == .small { return 36 }
        return verticalSizeClass == .compact ? 50 : 52
    }
}

public extension ButtonStyle where Self == TTPrimaryButtonStyle {
    static var ttPrimary: TTPrimaryButtonStyle { TTPrimaryButtonStyle() }
    static var ttPrimaryInline: TTPrimaryButtonStyle { TTPrimaryButtonStyle(fullWidth: false) }
}

public extension ButtonStyle where Self == TTSecondaryButtonStyle {
    static var ttSecondary: TTSecondaryButtonStyle { TTSecondaryButtonStyle() }
}

public extension ButtonStyle where Self == TTTertiaryButtonStyle {
    static var ttTertiary: TTTertiaryButtonStyle { TTTertiaryButtonStyle() }
}

public extension ButtonStyle where Self == TTDestructiveButtonStyle {
    static var ttDestructive: TTDestructiveButtonStyle { TTDestructiveButtonStyle() }
}

public extension ButtonStyle where Self == TTPlayerButtonStyle {
    static func ttPlayer(isPlayerOne: Bool) -> TTPlayerButtonStyle {
        TTPlayerButtonStyle(isPlayerOne: isPlayerOne)
    }
}
