import SwiftUI
import UIKit

/// App crest mark — shared by onboarding and other branded surfaces.
struct BrandCrest: View {
    var size: CGFloat = 160

    var body: some View {
        Group {
            if let uiImage = UIImage(named: "CrestLogo") ?? BundleAppIcon.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "book.closed.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.accentColor)
                    .padding(size * 0.18)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
        .shadow(color: .black.opacity(0.14), radius: size * 0.06, y: size * 0.03)
        .accessibilityLabel(String(localized: "Tabletome crest"))
    }
}

private enum BundleAppIcon {
    static var image: UIImage? {
        guard let bundleIcons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primary = bundleIcons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primary["CFBundleIconFiles"] as? [String] else {
            return nil
        }
        for name in iconFiles.reversed() {
            if let image = UIImage(named: name) {
                return image
            }
        }
        return nil
    }
}

#Preview {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()
        BrandCrest()
    }
}
