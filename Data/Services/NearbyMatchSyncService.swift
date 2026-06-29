import Foundation
@preconcurrency import MultipeerConnectivity
import TabletomeDomain
#if canImport(UIKit)
import UIKit
#endif

public final class NearbyMatchSyncService: NSObject, ObservableObject, @unchecked Sendable {
    public enum Role: Equatable {
        case idle
        case hosting(code: String)
        case joining
        case connected(peerName: String)
    }

    @MainActor @Published public private(set) var role: Role = .idle
    @MainActor @Published public private(set) var statusMessage: String?
    @MainActor @Published public private(set) var pendingJoinPeerName: String?
    @MainActor public var syncGameSystemId: String = "aos-spearhead"
    @MainActor public var analyticsHandler: ((String, [String: String]) -> Void)?

    private static let serviceType = "tabletome-match"
    private let peerID: MCPeerID
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var hostCode: String?
    private nonisolated(unsafe) var observer: NSObjectProtocol?
    private nonisolated(unsafe) var pendingInvitationHandler: ((Bool, MCSession?) -> Void)?

    public override init() {
        peerID = MCPeerID(displayName: Self.peerDisplayName())
        super.init()
        MatchSyncLogger.sessionInfo("Initialized peer displayName=\(peerID.displayName)")
        observer = NotificationCenter.default.addObserver(
            forName: .matchSyncStateDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let shouldBroadcast = notification.userInfo?[MatchSyncNotifications.shouldBroadcastToPeersKey] as? Bool ?? true
            guard shouldBroadcast else { return }
            Task { @MainActor in
                self?.broadcastCurrentStateIfConnected()
            }
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    @MainActor
    public func startHosting() {
        stop()
        let code = Self.generateJoinCode()
        hostCode = code
        let session = makeSession()
        self.session = session
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: ["code": code],
            serviceType: Self.serviceType
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        setRole(.hosting(code: code))
        setStatus(String(localized: "Waiting for another player to join with code \(code)."))
        MatchSyncLogger.sessionInfo("Hosting started code=\(code) gameSystemId=\(syncGameSystemId)")
        logAnalytics(
            eventName: "match_sync_started",
            metadata: ["operation": "host", "gameSystemId": syncGameSystemId]
        )
    }

    @MainActor
    public func startJoining(code: String) {
        stop()
        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard normalized.count == 4 else {
            let message = String(localized: "Enter the 4-character code from the host device.")
            reportUserError(message, logMessage: "Join rejected — code length \(normalized.count)")
            return
        }
        hostCode = normalized
        let session = makeSession()
        self.session = session
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: Self.serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        setRole(.joining)
        setStatus(String(localized: "Searching for host \(normalized)…"))
        MatchSyncLogger.sessionInfo("Joining started code=\(normalized) gameSystemId=\(syncGameSystemId)")
        logAnalytics(
            eventName: "match_sync_started",
            metadata: ["operation": "join", "gameSystemId": syncGameSystemId]
        )
    }

    @MainActor
    public func stop() {
        MatchSyncLogger.sessionInfo("Stopping sync role=\(roleLabel(role))")
        declineJoinRequest()
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session?.disconnect()
        advertiser = nil
        browser = nil
        session = nil
        hostCode = nil
        setRole(.idle)
        setStatus(nil)
        logAnalytics(
            eventName: "match_sync_stopped",
            metadata: ["gameSystemId": syncGameSystemId, "operation": "stop"]
        )
    }

    @MainActor
    public func acceptJoinRequest() {
        guard let pendingInvitationHandler else {
            MatchSyncLogger.sessionWarning("Accept join ignored — no pending invitation")
            return
        }
        let peerName = pendingJoinPeerName ?? "unknown"
        pendingInvitationHandler(true, session)
        self.pendingInvitationHandler = nil
        pendingJoinPeerName = nil
        setStatus(String(localized: "Connecting to \(peerName)…"))
        MatchSyncLogger.sessionInfo("Join request accepted peer=\(peerName)")
    }

    @MainActor
    public func declineJoinRequest() {
        if pendingInvitationHandler != nil {
            MatchSyncLogger.sessionInfo("Join request declined peer=\(pendingJoinPeerName ?? "unknown")")
        }
        pendingInvitationHandler?(false, nil)
        pendingInvitationHandler = nil
        pendingJoinPeerName = nil
    }

    @MainActor
    @discardableResult
    public func applyPasteCode(_ pasted: String) -> Bool {
        switch MatchSyncCodec.decodePasteCode(pasted) {
        case let .failure(error):
            reportUserError(error.localizedMessage, logMessage: "Paste import failed — \(error.logDescription)")
            return false
        case let .success(snapshot):
            if let applyError = MatchSyncCodec.apply(
                snapshot,
                expectedGameSystemId: syncGameSystemId,
                notifyUI: true,
                source: "paste"
            ) {
                reportUserError(applyError.localizedMessage, logMessage: "Paste import rejected — \(applyError.logDescription)")
                return false
            }
            setStatus(String(localized: "Match imported from paste code."))
            broadcastCurrentStateIfConnected()
            logAnalytics(
                eventName: "match_sync_paste_applied",
                metadata: ["gameSystemId": syncGameSystemId, "source": "paste", "operation": "import"]
            )
            return true
        }
    }

    @MainActor
    public var exportPasteCode: String? {
        switch MatchSyncCodec.encodePasteCode(MatchSyncCodec.current(gameSystemId: syncGameSystemId)) {
        case let .success(code):
            return code
        case let .failure(error):
            reportUserError(error.localizedMessage, logMessage: "Export paste code failed — \(error.logDescription)")
            return nil
        }
    }

    @MainActor
    public var isLiveSyncActive: Bool {
        if case .connected = role { return true }
        return false
    }

    @MainActor
    private func makeSession() -> MCSession {
        let session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }

    @MainActor
    private func broadcastCurrentStateIfConnected() {
        guard let session, !session.connectedPeers.isEmpty else { return }
        let snapshot = MatchSyncCodec.current(gameSystemId: syncGameSystemId)
        switch MatchSyncCodec.encodeWireData(snapshot) {
        case let .failure(error):
            reportUserError(
                String(localized: "Could not prepare match state to send."),
                logMessage: "Broadcast encode failed — \(error.logDescription)"
            )
        case let .success(data):
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                MatchSyncLogger.logBroadcast(
                    gameSystemId: syncGameSystemId,
                    battleRound: snapshot.trackerState.battleRound,
                    byteCount: data.count,
                    peerCount: session.connectedPeers.count
                )
            } catch {
                reportUserError(
                    String(localized: "Sync send failed. Try stopping and re-hosting."),
                    logMessage: "Broadcast send failed peers=\(session.connectedPeers.count)",
                    error: error
                )
            }
        }
    }

    @MainActor
    private func applyRemoteSnapshot(_ snapshot: MatchSyncSnapshot, peerName: String) {
        if let error = MatchSyncCodec.apply(
            snapshot,
            expectedGameSystemId: syncGameSystemId,
            notifyUI: true,
            source: "nearby:\(peerName)"
        ) {
            reportUserError(
                error.localizedMessage,
                logMessage: "Remote apply rejected peer=\(peerName) — \(error.logDescription)"
            )
            return
        }
        setStatus(String(localized: "Synced from \(peerName)."))
    }

    @MainActor
    private func handlePeerDisconnected() {
        if let code = hostCode, advertiser != nil {
            setRole(.hosting(code: code))
            setStatus(
                String(localized: "Player disconnected. Waiting for another player with code \(code).")
            )
            MatchSyncLogger.sessionWarning("Peer disconnected — resumed hosting code=\(code)")
            return
        }
        if browser != nil {
            setRole(.joining)
            setStatus(String(localized: "Disconnected from host. Still searching…"))
            MatchSyncLogger.sessionWarning("Peer disconnected — still browsing for host")
            return
        }
        setRole(.idle)
        setStatus(String(localized: "Disconnected."))
        MatchSyncLogger.sessionWarning("Peer disconnected — idle")
    }

    @MainActor
    private func setRole(_ newRole: Role) {
        guard role != newRole else { return }
        MatchSyncLogger.sessionInfo("Role \(roleLabel(role)) → \(roleLabel(newRole))")
        role = newRole
    }

    @MainActor
    private func setStatus(_ message: String?) {
        statusMessage = message
    }

    @MainActor
    private func reportUserError(_ message: String, logMessage: String, error: Error? = nil) {
        setStatus(message)
        MatchSyncLogger.sessionError(logMessage, error: error)
        logSyncFailure(logMessage: logMessage)
    }

    @MainActor
    private func logAnalytics(eventName: String, metadata: [String: String]) {
        analyticsHandler?(eventName, metadata)
    }

    @MainActor
    private func logSyncFailure(logMessage: String) {
        var metadata: [String: String] = [
            "gameSystemId": syncGameSystemId,
            "source": "nearby"
        ]
        if logMessage.contains("Paste") {
            metadata["operation"] = "paste"
        } else if logMessage.contains("Broadcast") {
            metadata["operation"] = "broadcast"
        } else if logMessage.contains("Advertiser") {
            metadata["operation"] = "host"
        } else if logMessage.contains("Browser") {
            metadata["operation"] = "join"
        } else if logMessage.contains("Wire receive") {
            metadata["operation"] = "receive"
        } else if logMessage.contains("Remote apply") {
            metadata["operation"] = "apply"
        } else {
            metadata["operation"] = "sync"
        }
        metadata["errorCode"] = String(logMessage.suffix(100))
        logAnalytics(eventName: "match_sync_failed", metadata: metadata)
    }

    private func roleLabel(_ role: Role) -> String {
        switch role {
        case .idle: "idle"
        case let .hosting(code): "hosting(\(code))"
        case .joining: "joining"
        case let .connected(peer): "connected(\(peer))"
        }
    }

    private static func generateJoinCode() -> String {
        let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<4).map { _ in alphabet.randomElement()! })
    }

    private static func peerDisplayName() -> String {
        #if canImport(UIKit)
        let trimmed = UIDevice.current.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Tabletome" }
        return String(trimmed.prefix(32))
        #else
        return "Tabletome"
        #endif
    }
}

extension NearbyMatchSyncService: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        let name = peerID.displayName
        pendingInvitationHandler = invitationHandler
        Task { @MainActor in
            pendingJoinPeerName = name
            setStatus(String(localized: "\(name) wants to join. Approve or decline."))
            MatchSyncLogger.sessionInfo("Join invitation received peer=\(name)")
        }
    }

    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        Task { @MainActor in
            reportUserError(
                String(localized: "Could not start hosting. Check local network permission and try again."),
                logMessage: "Advertiser failed to start",
                error: error
            )
            stop()
        }
    }
}

extension NearbyMatchSyncService: MCNearbyServiceBrowserDelegate {
    public func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        let name = peerID.displayName
        Task { @MainActor in
            guard role == .joining,
                  let hostCode,
                  let session else { return }
            let discoveredCode = info?["code"]?.uppercased()
            guard discoveredCode == hostCode else {
                MatchSyncLogger.sessionInfo(
                    "Ignored peer=\(name) code=\(discoveredCode ?? "nil") expected=\(hostCode)"
                )
                return
            }
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
            setStatus(String(localized: "Inviting \(name)…"))
            MatchSyncLogger.sessionInfo("Inviting peer=\(name) code=\(hostCode)")
        }
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        MatchSyncLogger.sessionInfo("Lost peer=\(peerID.displayName)")
    }

    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        Task { @MainActor in
            reportUserError(
                String(localized: "Could not search for host. Check local network permission and try again."),
                logMessage: "Browser failed to start",
                error: error
            )
            stop()
        }
    }
}

extension NearbyMatchSyncService: MCSessionDelegate {
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let name = peerID.displayName
        Task { @MainActor in
            switch state {
            case .connected:
                setRole(.connected(peerName: name))
                setStatus(String(localized: "Connected to \(name). Changes sync automatically."))
                MatchSyncLogger.sessionInfo("Connected peer=\(name)")
                logAnalytics(
                    eventName: "match_sync_connected",
                    metadata: [
                        "gameSystemId": syncGameSystemId,
                        "participantCount": "1",
                        "operation": "connect"
                    ]
                )
                broadcastCurrentStateIfConnected()
            case .connecting:
                setStatus(String(localized: "Connecting…"))
                MatchSyncLogger.sessionInfo("Connecting peer=\(name)")
            case .notConnected:
                MatchSyncLogger.sessionInfo("Not connected peer=\(name) priorRole=\(roleLabel(role))")
                if case .connected = role {
                    handlePeerDisconnected()
                    return
                }
                if case .hosting = role {
                    return
                }
                if case .joining = role {
                    return
                }
                setRole(.idle)
            @unknown default:
                MatchSyncLogger.sessionWarning("Unknown session state for peer=\(name)")
            }
        }
    }

    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let name = peerID.displayName
        Task { @MainActor in
            switch MatchSyncCodec.decodeWireData(data) {
            case let .failure(error):
                reportUserError(
                    String(localized: "Received unreadable sync data from \(name)."),
                    logMessage: "Wire receive failed peer=\(name) bytes=\(data.count) — \(error.logDescription)"
                )
            case let .success(snapshot):
                applyRemoteSnapshot(snapshot, peerName: name)
            }
        }
    }

    public func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {}

    public func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {}

    public func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {}
}
