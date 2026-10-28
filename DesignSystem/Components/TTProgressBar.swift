import SwiftUI

public struct TTProgressBar: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let fraction: Double
    private let tone: TTTone
    private let height: CGFloat
    private let criticalThreshold: Double?

    public init(
        fraction: Double,
        tone: TTTone,
        height: CGFloat = 6,
        criticalThreshold: Double? = 0.35
    ) {
        self.fraction = fraction
        self.tone = tone
        self.height = height
        self.criticalThreshold = criticalThreshold
    }

    public var body: some View {
        let clamped = min(1, max(0, fraction))
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(TTColor.sunken)
                Capsule()
                    .fill(fill)
                    .frame(width: geometry.size.width * clamped)
            }
        }
        .frame(height: height)
        .animation(TTMotion.standard(reduceMotion: reduceMotion), value: clamped)
        .accessibilityValue("\(Int(clamped * 100)) percent")
    }

    private var fill: Color {
        if let criticalThreshold, fraction <= criticalThreshold, fraction > 0 {
            return TTColor.danger
        }
        return tone.solid
    }
}

#Preview("TTProgressBar") {
    TTPreviewMatrix {
        TTProgressBar(fraction: 0.7, tone: .brand)
            .frame(height: 6)
    }
}
