import Foundation
import MultipeerConnectivity
import SwiftUI

class ConnectivityManager: NSObject, ObservableObject {
    private let serviceType = "cursorly-ctrl"
    
    #if os(iOS)
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    #elseif os(macOS)
    let myPeerId = MCPeerID(displayName: Host.current().localizedName ?? "Mac")
    #endif
    
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    @Published var connectedPeers: [MCPeerID] = []
    @Published var availablePeers: [MCPeerID] = []
    @Published var pairingCode: String = ""
    
    var session: MCSession
    var isHosting: Bool = false
    
    override init() {
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        
        super.init()
        
        self.session.delegate = self
        self.serviceAdvertiser.delegate = self
        self.serviceBrowser.delegate = self
    }
    
    func startHosting() {
        print("Starting hosting...")
        generatePairingCode()
        isHosting = true
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    private func generatePairingCode() {
        // Generujemy losowy 4-cyfrowy kod
        let code = String(format: "%04d", Int.random(in: 0...9999))
        self.pairingCode = code
        print("Generated pairing code: \(code)")
    }
    
    func stopHosting() {
        print("Stopping hosting...")
        isHosting = false
        serviceAdvertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing() {
        print("Starting browsing...")
        serviceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        print("Stopping browsing...")
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func invitePeer(_ peerID: MCPeerID, code: String) {
        print("Inviting peer: \(peerID.displayName) with code: \(code)")
        if let contextData = code.data(using: .utf8) {
            serviceBrowser.invitePeer(peerID, to: session, withContext: contextData, timeout: 10)
        }
    }
    
    func send(event: CursorEvent) {
        guard !session.connectedPeers.isEmpty else { return }
        
        do {
            let data = try JSONEncoder().encode(event)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending data: \(error.localizedDescription)")
        }
    }
}

extension ConnectivityManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
            switch state {
            case .connected:
                print("Connected to: \(peerID.displayName)")
            case .connecting:
                print("Connecting to: \(peerID.displayName)")
            case .notConnected:
                print("Disconnected from: \(peerID.displayName)")
            @unknown default:
                fatalError("Unknown state")
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let event = try JSONDecoder().decode(CursorEvent.self, from: data)
            print("Received event: \(event.type) from \(peerID.displayName)")
            
            #if os(macOS)
            DispatchQueue.main.async {
                self.simulateMouse(event: event)
            }
            #endif
            
        } catch {
            print("Error decoding data: \(error.localizedDescription)")
        }
    }
    
    #if os(macOS)
    private func simulateMouse(event: CursorEvent) {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }
        let currentPos = CGEvent(source: nil)?.location ?? .zero
        
        switch event.type {
        case .move:
            let newPos = CGPoint(x: currentPos.x + event.x, y: currentPos.y + event.y)
            let moveEvent = CGEvent(mouseEventSource: source, mouseType: .mouseMoved, mouseCursorPosition: newPos, mouseButton: .left)
            moveEvent?.post(tap: .cghidEventTap)
            
        case .click:
            let button: CGMouseButton = (event.additionalData == "right") ? .right : .left
            let typeDown: CGEventType = (button == .right) ? .rightMouseDown : .leftMouseDown
            let typeUp: CGEventType = (button == .right) ? .rightMouseUp : .leftMouseUp
            
            let clickDown = CGEvent(mouseEventSource: source, mouseType: typeDown, mouseCursorPosition: currentPos, mouseButton: button)
            let clickUp = CGEvent(mouseEventSource: source, mouseType: typeUp, mouseCursorPosition: currentPos, mouseButton: button)
            
            clickDown?.post(tap: .cghidEventTap)
            clickUp?.post(tap: .cghidEventTap)
            
        case .scroll:
            // Scroll 1 unit = 1 line (roughly). We need to scale.
            // event.y is usually small delta. 
            let sensitivity: Int32 = 5
            let scrollY = Int32(event.y * CGFloat(sensitivity))
            let scrollX = Int32(event.x * CGFloat(sensitivity))
            
            // Note: wheelCount: 2 (Y, X). In scrollWheelEvent, Y comes first.
            if let scrollEvent = CGEvent(scrollWheelEvent2Source: source, units: .pixel, wheelCount: 2, wheel1: scrollY, wheel2: scrollX, wheel3: 0) {
                 scrollEvent.post(tap: .cghidEventTap)
            }

        case .keyboard:
            guard let text = event.additionalData else { return }
            // Simulating text entry is complex safely.
            // For MVP, we use AppleScript to support emoji and special chars easily.
            let script = "tell application \"System Events\" to keystroke \"\(text)\""
            if let scriptObject = NSAppleScript(source: script) {
                var error: NSDictionary?
                scriptObject.executeAndReturnError(&error)
                if let error = error {
                    print("Keyboard Error: \(error)")
                }
            }
            
        case .media:
            guard let action = event.additionalData else { return }
            // Map actions to system keys
            // 0: Sound up, 1: Sound down, 2: Mute
            // 16: Play, 19: Next, 20: Prev
            var keyCode: Int32 = -1
            
            switch action {
            case "playpause": keyCode = 16
            case "next": keyCode = 19
            case "prev": keyCode = 20
            case "volup": keyCode = 0
            case "voldown": keyCode = 1
            case "mute": keyCode = 7
            default: break
            }
            
            if keyCode != -1 {
                let systemKey = NXSystemDefined
                // Simulation of Media Keys via IOKit/Quartz is tricky in pure CGEvent without specialized flags.
                // Using AppleScript for Media keys is often more reliable for High Level control.
                 let script = "tell application \"System Events\" to key code \(keyCode) using command down" // No command for media usually?
                 // Actually media keys are special. Let's use specific script for Music/System
                 // Better standard way:
                 // let loc = CGEventTapLocation.cghidEventTap
                 // let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(keyCode), keyDown: true)
                 // keyDown?.flags = .maskCommand // ??
                 // Media keys are hardware dependent.
                 
                 // Fallback to AppleScript for simplicity in MVP:
                 var appleScriptCmd = ""
                 switch action {
                 case "playpause": appleScriptCmd = "key code 100" // F8/Play
                 case "next": appleScriptCmd = "key code 101" // F9
                 case "prev": appleScriptCmd = "key code 98" // F7
                 case "volup": appleScriptCmd = "key code 111" // F12
                 case "voldown": appleScriptCmd = "key code 103" // F11
                 case "mute": appleScriptCmd = "key code 109" // F10
                 default: break
                 }
                 
                 if !appleScriptCmd.isEmpty {
                     let script = "tell application \"System Events\" to \(appleScriptCmd)"
                     NSAppleScript(source: script)?.executeAndReturnError(nil)
                 }
            }
        }
    }
    #endif
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
    // Obsługa certyfikatów SSL/TLS
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        print("Verifying secure connection (TLS/SSL) from: \(peerID.displayName)")
        if let certs = certificate as? [SecCertificate], !certs.isEmpty {
            // W prawdziwej produkcji weryfikowalibyśmy tu podpis CA lub Pinning klucza
            // Ponieważ MultipeerConnectivity używa self-signed certyfikatów dla peerów, akceptujemy obecność certyfikatu.
            print("Certificate present. Encryption handshake valid.")
            certificateHandler(true)
        } else {
            print("No certificate received. Rejecting connection.")
            certificateHandler(false)
        }
    }
}

extension ConnectivityManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received invitation from: \(peerID.displayName)")
        
        // Weryfikacja kodu PIN
        if let context = context, let receivedCode = String(data: context, encoding: .utf8) {
            if receivedCode == self.pairingCode {
                print("Code matches! Accepting.")
                invitationHandler(true, session)
            } else {
                print("Invalid code received: \(receivedCode). Expected: \(self.pairingCode). Rejecting.")
                invitationHandler(false, nil)
            }
        } else {
            print("No code provided. Rejecting.")
            invitationHandler(false, nil)
        }
    }
}

extension ConnectivityManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID.displayName)")
        DispatchQueue.main.async {
            if !self.availablePeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
        DispatchQueue.main.async {
            self.availablePeers.removeAll(where: { $0 == peerID })
        }
    }
}
