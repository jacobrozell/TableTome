import SwiftUI

enum PlayerAccentPalette {
    static let options: [(name: String, color: Color)] = [
        ("blue", .blue),
        ("orange", .orange),
        ("green", .green),
        ("purple", .purple),
        ("pink", .pink),
        ("teal", .teal),
        ("red", .red),
        ("indigo", .indigo)
    ]

    static func color(named name: String?) -> Color {
        options.first { $0.name == name }?.color ?? .accentColor
    }
}

struct PlayerAvatarView: View {
    let name: String
    var accentColorName: String?
    var size: CGFloat = 40

    private var initial: String {
        String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(1)).uppercased()
    }

    var body: some View {
        Text(initial)
            .font(.system(size: size * 0.42, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(PlayerAccentPalette.color(named: accentColorName), in: Circle())
            .accessibilityHidden(true)
    }
}
