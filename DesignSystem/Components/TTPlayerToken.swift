import SwiftUI

public struct TTPlayerToken: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false
    private let isPlayerOne: Bool
    private let size: CGFloat
    private let isActive: Bool

    public init(isPlayerOne: Bool, size: CGFloat = DesignTokens.Size.playerToken, isActive: Bool = false) {
        self.isPlayerOne = isPlayerOne
        self.size = size
        self.isActive = isActive
    }

    public var body: some View {
        Text(isPlayerOne ? "1" : "2")
            .font(TTFont.numericSmall)
            .foregroundStyle(TTColor.inkOnPlayer)
            .frame(width: size, height: size)
            .background(TTColor.player(isPlayerOne), in: Circle())
            .overlay {
                if isActive {
                    Circle()
                        .strokeBorder(TTColor.player(isPlayerOne).opacity(pulse ? 1 : 0.4), lineWidth: 2)
                        .padding(-4)
                }
            }
            .onAppear {
                guard isActive, !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
            .accessibilityLabel(isPlayerOne ? String(localized: "Player 1") : String(localized: "Player 2"))
            .accessibilityValue(isActive ? String(localized: "Active") : "")
    }
}

#Preview("TTPlayerToken") {
    TTPreviewMatrix {
        HStack {
            TTPlayerToken(isPlayerOne: true, isActive: true)
            TTPlayerToken(isPlayerOne: false)
        }
    }
}
