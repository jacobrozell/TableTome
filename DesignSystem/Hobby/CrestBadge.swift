import SwiftUI
import TabletomeHobbyData
#if canImport(UIKit)
import UIKit
#endif

/// Faction crest badge: abbreviation on the accent colour, or a custom uploaded image.
struct CrestBadge: View {
    let text: String
    let colorHex: String
    var imageFileName: String? = nil

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if let imageFileName, let image = CrestImageStore.loadImage(fileName: imageFileName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(text)
                    .font(.system(.caption, design: .serif).weight(.bold))
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .minimumScaleFactor(dynamicTypeSize.needsLayoutAdaptation ? 1 : 0.85)
                    .foregroundStyle(Color(hex: colorHex).legibleForeground)
            }
        }
        .padding(imageFileName == nil ? EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6) : EdgeInsets())
        .frame(minWidth: 44, minHeight: 30)
        .background(Color(hex: colorHex), in: RoundedRectangle(cornerRadius: 8))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityLabel(
            imageFileName == nil
                ? String(localized: "Faction crest \(text)")
                : String(localized: "Faction crest image for \(text)")
        )
    }
}
