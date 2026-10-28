import SwiftUI

/// Circular completion indicator for collection progress.
struct ProgressRing: View {
    let percent: Int
    var diameter: CGFloat = 36

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .caption) private var scaledSmall: CGFloat = 36
    @ScaledMetric(relativeTo: .title2) private var scaledLarge: CGFloat = 88

    private var size: CGFloat {
        if diameter <= 36 { return min(scaledSmall, 52) }
        return min(scaledLarge, 120)
    }

    private var progress: CGFloat {
        CGFloat(min(max(percent, 0), 100)) / 100
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(TTColor.sunken, lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    TTColor.brandFill,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(percent)%")
                .font(TTFont.numericLarge)
                .foregroundStyle(TTColor.inkPrimary)
                .minimumScaleFactor(0.35)
                .lineLimit(1)
        }
        .frame(width: size, height: size)
        .fixedSize()
        .layoutPriority(-1)
        .animation(TTMotion.standard(reduceMotion: reduceMotion), value: percent)
        .accessibilityLabel(String(localized: "\(percent) percent complete"))
    }
}

#Preview("ProgressRing") {
    TTPreviewMatrix {
        ProgressRing(percent: 62, diameter: 88)
    }
}
