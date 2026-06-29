import Foundation

protocol RedactionPolicy: Sendable {
    func redact(metadata: [String: String]) -> [String: String]
}

struct DefaultRedactionPolicy: RedactionPolicy {
    private let allowedMetadataKeys: Set<String>
    private let sensitiveKeyFragments: [String]

    init(
        allowedMetadataKeys: Set<String> = AnalyticsMetadataKeys.defaultRedactionAllowed,
        sensitiveKeyFragments: [String] = [
            "token",
            "secret",
            "password",
            "credential",
            "note",
            "payload"
        ]
    ) {
        self.allowedMetadataKeys = allowedMetadataKeys
        self.sensitiveKeyFragments = sensitiveKeyFragments
    }

    func redact(metadata: [String: String]) -> [String: String] {
        metadata.reduce(into: [:]) { partialResult, pair in
            guard !AnalyticsMetadataKeys.isBlockedPersonalDataKey(pair.key) else { return }
            let lowercasedKey = pair.key.lowercased()
            guard allowedMetadataKeys.contains(pair.key) else { return }
            if sensitiveKeyFragments.contains(where: { lowercasedKey.contains($0) }) {
                partialResult[pair.key] = "[REDACTED]"
            } else {
                partialResult[pair.key] = pair.value
            }
        }
    }
}
