import Foundation
import OSLog

protocol LogSink: Sendable {
    func write(_ entry: LogEntry)
}

struct ConsoleLogSink: LogSink {
    private let subsystem: String

    init(subsystem: String = "com.jacobrozell.tabletome") {
        self.subsystem = subsystem
    }

    func write(_ entry: LogEntry) {
        let logger = Logger(subsystem: subsystem, category: entry.category.rawValue)
        logger.log(level: entry.level.osLogType, "\(formattedMessage(for: entry), privacy: .public)")
    }

    private func formattedMessage(for entry: LogEntry) -> String {
        let metadataPart = entry.metadata.isEmpty ? "" : " metadata=\(entry.metadata)"
        let correlationPart = entry.correlationId.map { " correlationId=\($0)" } ?? ""
        return "[\(entry.eventName)] \(entry.message)\(metadataPart)\(correlationPart)"
    }
}

private extension LogLevel {
    var osLogType: OSLogType {
        switch self {
        case .debug: .debug
        case .info: .info
        case .warning: .default
        case .error: .error
        case .fault: .fault
        }
    }
}

struct CompositeLogSink: LogSink {
    private let sinks: [any LogSink]

    init(sinks: [any LogSink]) {
        self.sinks = sinks
    }

    func write(_ entry: LogEntry) {
        for sink in sinks {
            sink.write(entry)
        }
    }
}

struct FilteredLogSink: LogSink {
    private let minimumLevel: LogLevel
    private let wrapped: any LogSink

    init(minimumLevel: LogLevel, wrapped: any LogSink) {
        self.minimumLevel = minimumLevel
        self.wrapped = wrapped
    }

    func write(_ entry: LogEntry) {
        guard entry.level >= minimumLevel else { return }
        wrapped.write(entry)
    }
}

struct NoOpLogSink: LogSink {
    init() {}

    func write(_ entry: LogEntry) {}
}

protocol RemoteAnalyticsLogSink: LogSink {}

struct NoOpRemoteAnalyticsLogSink: RemoteAnalyticsLogSink {
    init() {}

    func write(_ entry: LogEntry) {}
}
