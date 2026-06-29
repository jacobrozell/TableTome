import Foundation
#if canImport(UIKit)
import UIKit
#endif

struct ClientEnvironmentSnapshot: Equatable, Sendable {
    let deviceClass: String
    let isVoiceOverRunning: Bool
    let isSwitchControlRunning: Bool
    let isBoldTextEnabled: Bool
    let isReduceMotionEnabled: Bool
    let isScreenCaptured: Bool
    let isExternalDisplayConnected: Bool
    let interfaceOrientation: String
    let contentSizeCategory: String
    let colorScheme: String
    let isLowPowerModeEnabled: Bool

    init(
        deviceClass: String,
        isVoiceOverRunning: Bool,
        isSwitchControlRunning: Bool,
        isBoldTextEnabled: Bool,
        isReduceMotionEnabled: Bool,
        isScreenCaptured: Bool,
        isExternalDisplayConnected: Bool,
        interfaceOrientation: String,
        contentSizeCategory: String = "unknown",
        colorScheme: String = "unspecified",
        isLowPowerModeEnabled: Bool = false
    ) {
        self.deviceClass = deviceClass
        self.isVoiceOverRunning = isVoiceOverRunning
        self.isSwitchControlRunning = isSwitchControlRunning
        self.isBoldTextEnabled = isBoldTextEnabled
        self.isReduceMotionEnabled = isReduceMotionEnabled
        self.isScreenCaptured = isScreenCaptured
        self.isExternalDisplayConnected = isExternalDisplayConnected
        self.interfaceOrientation = interfaceOrientation
        self.contentSizeCategory = contentSizeCategory
        self.colorScheme = colorScheme
        self.isLowPowerModeEnabled = isLowPowerModeEnabled
    }

    var analyticsMetadata: [String: String] {
        [
            "deviceClass": deviceClass,
            "isVoiceOverRunning": Self.boolString(isVoiceOverRunning),
            "isSwitchControlRunning": Self.boolString(isSwitchControlRunning),
            "isBoldTextEnabled": Self.boolString(isBoldTextEnabled),
            "isReduceMotionEnabled": Self.boolString(isReduceMotionEnabled),
            "isScreenCaptured": Self.boolString(isScreenCaptured),
            "isExternalDisplayConnected": Self.boolString(isExternalDisplayConnected),
            "interfaceOrientation": interfaceOrientation,
            "contentSizeCategory": contentSizeCategory,
            "colorScheme": colorScheme,
            "isLowPowerModeEnabled": Self.boolString(isLowPowerModeEnabled)
        ]
    }

    static func changedSignals(
        from previous: ClientEnvironmentSnapshot,
        to current: ClientEnvironmentSnapshot
    ) -> String {
        var changes: [String] = []
        if previous.isVoiceOverRunning != current.isVoiceOverRunning { changes.append("voiceover") }
        if previous.isSwitchControlRunning != current.isSwitchControlRunning { changes.append("switchControl") }
        if previous.isBoldTextEnabled != current.isBoldTextEnabled { changes.append("boldText") }
        if previous.isReduceMotionEnabled != current.isReduceMotionEnabled { changes.append("reduceMotion") }
        if previous.isScreenCaptured != current.isScreenCaptured { changes.append("screenCapture") }
        if previous.isExternalDisplayConnected != current.isExternalDisplayConnected { changes.append("display") }
        if previous.deviceClass != current.deviceClass { changes.append("deviceClass") }
        if previous.interfaceOrientation != current.interfaceOrientation { changes.append("orientation") }
        if previous.contentSizeCategory != current.contentSizeCategory { changes.append("contentSize") }
        if previous.colorScheme != current.colorScheme { changes.append("colorScheme") }
        if previous.isLowPowerModeEnabled != current.isLowPowerModeEnabled { changes.append("lowPowerMode") }
        return changes.joined(separator: ",")
    }

    static func current() -> ClientEnvironmentSnapshot {
        #if canImport(UIKit)
        if Thread.isMainThread {
            return makeUIKitSnapshot()
        }
        return DispatchQueue.main.sync {
            makeUIKitSnapshot()
        }
        #else
        ClientEnvironmentSnapshot(
            deviceClass: "unspecified",
            isVoiceOverRunning: false,
            isSwitchControlRunning: false,
            isBoldTextEnabled: false,
            isReduceMotionEnabled: false,
            isScreenCaptured: false,
            isExternalDisplayConnected: false,
            interfaceOrientation: "unknown",
            contentSizeCategory: "unknown",
            colorScheme: "unspecified",
            isLowPowerModeEnabled: false
        )
        #endif
    }

    private static func boolString(_ value: Bool) -> String {
        value ? "true" : "false"
    }

    #if canImport(UIKit)
    private static func makeUIKitSnapshot() -> ClientEnvironmentSnapshot {
        ClientEnvironmentSnapshot(
            deviceClass: deviceClass(from: UIDevice.current.userInterfaceIdiom),
            isVoiceOverRunning: UIAccessibility.isVoiceOverRunning,
            isSwitchControlRunning: UIAccessibility.isSwitchControlRunning,
            isBoldTextEnabled: UIAccessibility.isBoldTextEnabled,
            isReduceMotionEnabled: UIAccessibility.isReduceMotionEnabled,
            isScreenCaptured: UIScreen.main.isCaptured,
            isExternalDisplayConnected: hasExternalDisplayConnected(),
            interfaceOrientation: currentInterfaceOrientation(),
            contentSizeCategory: contentSizeBucket(from: UIApplication.shared.preferredContentSizeCategory),
            colorScheme: colorSchemeLabel(from: activeTraitCollection()),
            isLowPowerModeEnabled: ProcessInfo.processInfo.isLowPowerModeEnabled
        )
    }

    private static func contentSizeBucket(from category: UIContentSizeCategory) -> String {
        category.isAccessibilityCategory ? "accessibility" : "standard"
    }

    private static func colorSchemeLabel(from traits: UITraitCollection) -> String {
        switch traits.userInterfaceStyle {
        case .dark: "dark"
        case .light: "light"
        default: "unspecified"
        }
    }

    private static func activeTraitCollection() -> UITraitCollection {
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }),
            let window = scene.windows.first(where: { $0.isKeyWindow }) {
            return window.traitCollection
        }
        return UITraitCollection.current
    }

    private static func deviceClass(from idiom: UIUserInterfaceIdiom) -> String {
        switch idiom {
        case .phone: "iphone"
        case .pad: "ipad"
        case .mac: "mac"
        case .tv: "tv"
        case .carPlay: "carplay"
        case .vision: "vision"
        case .unspecified: "unspecified"
        @unknown default: "unspecified"
        }
    }

    private static func hasExternalDisplayConnected() -> Bool {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .contains { scene in
                scene.screen != UIScreen.main
            }
    }

    private static func currentInterfaceOrientation() -> String {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive })
        else {
            return "unknown"
        }

        switch scene.interfaceOrientation {
        case .portrait, .portraitUpsideDown:
            return "portrait"
        case .landscapeLeft, .landscapeRight:
            return "landscape"
        default:
            return "unknown"
        }
    }
    #endif
}

enum ClientEnvironment {
    static var snapshot: ClientEnvironmentSnapshot {
        ClientEnvironmentSnapshot.current()
    }
}
