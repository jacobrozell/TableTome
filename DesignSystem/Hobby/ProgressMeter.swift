import SwiftUI
import TabletomeDomain

/// Stacked progress meter. Renders `Pipeline.segments` as width-proportional colour bars.
/// Mirrors the web `.meter` / `.army-bar` (`docs/ios-spec/10 §4`).
struct ProgressMeter: View {
    let segments: [ProgressSegment]
    var height: CGFloat = 10

    @ScaledMetric(relativeTo: .caption) private var scaledHeight: CGFloat = 10

    private var barHeight: CGFloat { height == 10 ? scaledHeight : height }

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                if segments.isEmpty {
                    Rectangle().fill(.quaternary)
                } else {
                    ForEach(segments) { seg in
                        Rectangle()
                            .fill(Color(hex: seg.hex))
                            .frame(width: max(0, geo.size.width * seg.pct / 100))
                    }
                }
            }
        }
        .frame(height: barHeight)
        .clipShape(Capsule())
        .accessibilityHidden(true)
    }
}
