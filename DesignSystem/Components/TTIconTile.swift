import SwiftUI

public struct TTIconTile: View {
    private let systemImage: String
    private let tone: TTTone
    private let size: CGFloat
    @ScaledMetric private var scaled: CGFloat

    public init(systemImage: String, tone: TTTone = .brand, size: CGFloat = DesignTokens.Size.iconTile) {
        self.systemImage = systemImage
        self.tone = tone
        self.size = size
        _scaled = ScaledMetric(wrappedValue: size)
    }

    public var body: some View {
        Image(systemName: systemImage)
            .resizable()
            .scaledToFit()
            .frame(width: scaled * 0.5, height: scaled * 0.5)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(tone.foreground)
            .frame(width: scaled, height: scaled)
            .background(tone.soft, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm, style: .continuous))
            .accessibilityHidden(true)
    }
}

#Preview("TTIconTile") {
    TTPreviewMatrix {
        TTIconTile(systemImage: "flag.checkered")
    }
}
