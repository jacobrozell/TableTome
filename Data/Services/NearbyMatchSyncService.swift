import Foundation
@preconcurrency import MultipeerConnectivity
import TabletomeDomain

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

    private static let serviceType = "tabletome-match"
    private let peerID: MCPeerID
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var hostCode: String?
    private nonisolated(unsafe) var observer: NSObjectProtocol?
    private nonisolated(unsafe) var pendingInvitationHandler: ((Bool, MCSession?) -> Void)?

    public override init() {
        peerID = MCPeerID(displayName: "Tabletome")
        super.init()
        observer = NotificationCenter.default.addObserver(
            forName: .matchSyncStateDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
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
        role = .hosting(code: code)
        statusMessage = String(localized: "Waiting for another player to join with code \(code).")
    }

    @MainActor
    public func startJoining(code: String) {
        stop()
        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard normalized.count == 4 else {
            statusMessage = String(localized: "Enter the 4-character code from the host device.")
            return
        }
        hostCode = normalized
        let session = makeSession()
        self.session = session
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: Self.serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        role = .joining
        statusMessage = String(localized: "Searching for host \(normalized)…")
    }

    @MainActor
    public func stop() {
        declineJoinRequest()
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session?.disconnect()
        advertiser = nil
        browser = nil
        session = nil
        hostCode = nil
        role = .idle
        statusMessage = nil
    }

    @MainActor
    public func acceptJoinRequest() {
        guard let pendingInvitationHandler else { return }
        let peerName = pendingJoinPeerName
        pendingInvitationHandler(true, session)
        self.pendingInvitationHandler = nil
        pendingJoinPeerName = nil
        if let peerName {
            statusMessage = String(localized: "Connecting to \(peerName)…")
        }
    }

    @MainActor
    public func declineJoinRequest() {
        pendingInvitationHandler?(false, nil)
        pendingInvitationHandler = nil
        pendingJoinPeerName = nil
    }

    @MainActor
    public func applyPasteCode(_ pasted: String) -> Bool {
        guard let snapshot = MatchSyncCodec.decode(pasted) else { return false }
        MatchSyncCodec.apply(snapshot)
        statusMessage = String(localized: "Match imported from paste code.")
        return true
    }

    @MainActor
    public var exportPasteCode: String? {
        MatchSyncCodec.encode(MatchSyncCodec.current(gameSystemId: syncGameSystemId))
    }

    @MainActor
    private func makeSession() -> MCSession {
        let session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }

    @MainActor
    private func broadcastCurrentStateIfConnected() {
        guard let session, !session.connectedPeers.isEmpty,
              let data = try? JSONEncoder().encode(MatchSyncCodec.current(gameSystemId: syncGameSystemId)) else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    private static func generateJoinCode() -> String {
        let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<4).map { _ in alphabet.randomElement()! })
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
            statusMessage = String(localized: "\(name) wants to join. Approve or decline.")
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
                  info?["code"]?.uppercased() == hostCode,
                  let session else { return }
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
            statusMessage = String(localized: "Inviting \(name)…")
        }
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}

extension NearbyMatchSyncService: MCSessionDelegate {
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let name = peerID.displayName
        Task { @MainActor in
            switch state {
            case .connected:
                role = .connected(peerName: name)
                statusMessage = String(localized: "Connected to \(name). Changes sync automatically.")
                broadcastCurrentStateIfConnected()
            case .connecting:
                statusMessage = String(localized: "Connecting…")
            case .notConnected:
                if case .connected = role {
                    statusMessage = String(localized: "Disconnected.")
                }
                if case .hosting = role {
                    return
                }
                if case .joining = role {
                    return
                }
                role = .idle
            @unknown default:
                break
            }
        }
    }

    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let name = peerID.displayName
        Task { @MainActor in
            guard let snapshot = try? JSONDecoder().decode(MatchSyncSnapshot.self, from: data) else { return }
            MatchSyncCodec.apply(snapshot)
            statusMessage = String(localized: "Synced from \(name).")
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
