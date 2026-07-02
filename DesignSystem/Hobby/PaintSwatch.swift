import SwiftUI

/// Small paint colour swatch for list and detail rows.
struct PaintSwatch: View {
    let hex: String
    var size: CGFloat = 28
    var cornerRadius: CGFloat = 6

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(hex: hex))
            .frame(width: size, height: size)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color(.separator).opacity(0.55), lineWidth: 0.5)
            }
            .accessibilityHidden(true)
    }
}
