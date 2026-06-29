import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(MessageUI)
import MessageUI
#endif

struct FeedbackDraft: Equatable {
    var category: FeedbackCategory
    var specificItem: String
    var summary: String
    var details: String

    var trimmedSummary: String {
        summary.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isValid: Bool {
        !trimmedSummary.isEmpty
    }
}

enum AppSupport {
    static let feedbackEmail = "jacob.rozell83@gmail.com"

    static var installedVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }

    static var installedBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
    }

    static var canSendMail: Bool {
        #if canImport(MessageUI)
        MFMailComposeViewController.canSendMail()
        #else
        false
        #endif
    }

    static func mailSubject(for draft: FeedbackDraft) -> String {
        let item = draft.specificItem.trimmingCharacters(in: .whitespacesAndNewlines)
        if item.isEmpty {
            return "[Tabletome] \(draft.category.subjectTag) — \(draft.trimmedSummary)"
        }
        return "[Tabletome] \(draft.category.subjectTag) — \(item)"
    }

    static func mailBody(for draft: FeedbackDraft) -> String {
        let item = draft.specificItem.trimmingCharacters(in: .whitespacesAndNewlines)
        let details = draft.details.trimmingCharacters(in: .whitespacesAndNewlines)

        var lines: [String] = [
            "Category: \(draft.category.label)",
        ]
        if !item.isEmpty {
            lines.append("\(draft.category.specificItemLabel): \(item)")
        }
        lines.append("Summary: \(draft.trimmedSummary)")
        lines.append("")
        lines.append("Details:")
        lines.append(details.isEmpty ? "(none provided)" : details)
        lines.append("")
        lines.append("---")
        lines.append(deviceDiagnostics)
        return lines.joined(separator: "\n")
    }

    static var deviceDiagnostics: String {
        #if canImport(UIKit)
        let device = UIDevice.current
        return """
        App: Tabletome \(installedVersion) (\(installedBuild))
        Device: \(device.model)
        iOS: \(device.systemVersion)
        """
        #else
        return "App: Tabletome \(installedVersion) (\(installedBuild))"
        #endif
    }

    static func mailtoURL(for draft: FeedbackDraft) -> URL {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = feedbackEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: mailSubject(for: draft)),
            URLQueryItem(name: "body", value: mailBody(for: draft)),
        ]
        // Fallback built from a verified literal constant.
        return components.url ?? URL(string: "mailto:\(feedbackEmail)")!
    }
}
