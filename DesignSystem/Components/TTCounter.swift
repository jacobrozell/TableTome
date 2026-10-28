import SwiftUI

public struct TTCounter: View {
    public enum Size { case regular, large }

    @Binding private var value: Int
    private let range: ClosedRange<Int>
    private let label: String
    private let tone: TTTone
    private let size: Size
    private let valueFormatter: (Int) -> String
    private let onStep: ((Int) -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var repeatTask: Task<Void, Never>?
    @State private var didRepeat = false
    @State private var hapticToken = 0
    @State private var lastDelta = 1

    public init(
        value: Binding<Int>,
        range: ClosedRange<Int>,
        label: String,
        tone: TTTone = .brand,
        size: Size = .regular,
        valueFormatter: @escaping (Int) -> String = { "\($0)" },
        onStep: ((Int) -> Void)? = nil
    ) {
        _value = value
        self.range = range
        self.label = label
        self.tone = tone
        self.size = size
        self.valueFormatter = valueFormatter
        self.onStep = onStep
    }

    public var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            stepButton(delta: -1, systemImage: "minus")
                .disabled(value <= range.lowerBound)
            Text(valueFormatter(value))
                .font(size == .large ? TTFont.numericHero : TTFont.numericLarge)
                .foregroundStyle(tone.foreground)
                .contentTransition(.numericText(value: Double(value)))
                .animation(reduceMotion ? nil : TTMotion.numeric, value: value)
                .frame(minWidth: size == .large ? 72 : 48)
            stepButton(delta: 1, systemImage: "plus")
                .disabled(value >= range.upperBound)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(valueFormatter(value))
        .accessibilityRepresentation {
            Stepper(label, value: $value, in: range)
        }
        .ttHaptic(lastDelta > 0 ? .scoreUp : .scoreDown, trigger: hapticToken)
        .onDisappear {
            repeatTask?.cancel()
            repeatTask = nil
        }
    }

    private var buttonSide: CGFloat { size == .large ? 56 : 44 }

    private func stepButton(delta: Int, systemImage: String) -> some View {
        Image(systemName: systemImage)
            .font(TTFont.button)
            .foregroundStyle(tone.foreground)
            .frame(width: buttonSide, height: buttonSide)
            .background(tone.soft, in: Circle())
            .contentShape(Circle())
            .gesture(pressGesture(delta: delta))
            .accessibilityHidden(true)
    }

    private func pressGesture(delta: Int) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard repeatTask == nil else { return }
                didRepeat = false
                repeatTask = Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(400))
                    while !Task.isCancelled {
                        didRepeat = true
                        apply(delta)
                        try? await Task.sleep(for: .milliseconds(150))
                    }
                }
            }
            .onEnded { _ in
                repeatTask?.cancel()
                repeatTask = nil
                if !didRepeat { apply(delta) }
                didRepeat = false
            }
    }

    private func apply(_ delta: Int) {
        let next = min(range.upperBound, max(range.lowerBound, value + delta))
        guard next != value else { return }
        value = next
        lastDelta = delta
        hapticToken += 1
        onStep?(delta)
    }
}

#Preview("TTCounter") {
    TTPreviewMatrix {
        TTCounterPreview()
    }
}

private struct TTCounterPreview: View {
    @State private var value = 7
    var body: some View {
        TTCounter(value: $value, range: 0...20, label: "Azure victory points", size: .large)
    }
}
