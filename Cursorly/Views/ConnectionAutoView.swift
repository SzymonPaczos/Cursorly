import SwiftUI

#if canImport(MultipeerConnectivity)
import MultipeerConnectivity
#endif

// Fallback stubs to allow this view to compile if other parts are missing.
// Remove these when real implementations exist elsewhere in the project.
#if !canImport(MultipeerConnectivity)
// Minimal stand-in for MCPeerID used by the list.
struct MCPeerID: Hashable, Identifiable {
    let displayName: String
    var id: String { displayName }
}
#endif

// Placeholder views if not defined in the project yet.
private struct _MagicMousePlaceholder: View {
    var body: some View { Text("MagicMouseView missing").foregroundStyle(.secondary) }
}

private struct _SettingsPlaceholder: View {
    var body: some View { Text("SettingsView missing").foregroundStyle(.secondary) }
}

// Lightweight QR scanner placeholder that returns the code via a text field for now.
private struct _QRScannerPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    @State private var code: String = ""
    let onCode: (String) -> Void
    var body: some View {
        VStack(spacing: 16) {
            Text("QRScannerView missing").font(.headline)
            TextField("Wklej kod QR", text: $code)
                .textFieldStyle(.roundedBorder)
            HStack {
                Button("Anuluj") { dismiss() }
                Spacer()
                Button("Użyj kodu") {
                    onCode(code)
                    dismiss()
                }
            }
        }
        .padding()
        .frame(minWidth: 320)
    }
}

struct ConnectionAutoView: View {
    @EnvironmentObject var connectivityManager: ConnectivityManager
    @State private var showingPINAlert = false
    @State private var showingSettings = false
    @State private var showingScanner = false
    #if canImport(MultipeerConnectivity)
    @State private var selectedPeer: MCPeerID?
    #else
    @State private var selectedPeer: MCPeerID?
    #endif
    @State private var pinCode = ""

    var body: some View {
        VStack(spacing: 30) {
            if !(connectivityManager.connectedPeers.isEmpty) {
                // Connected – show Magic Mouse interface
                // Use placeholder if MagicMouseView is unavailable
                Group {
                    #if canImport(MultipeerConnectivity)
                    // Replace with real MagicMouseView when available
                    _MagicMousePlaceholder()
                    #else
                    _MagicMousePlaceholder()
                    #endif
                }
            } else {
                // Discovery view
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)

                        Button(action: { showingScanner = true }) {
                            VStack {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.blue)
                                Text("Skanuj")
                                    .font(.caption)
                            }
                        }
                        .padding(.leading, 20)
                    }
                    .padding(.top, 40)

                    Text("Szukam komputerów...")
                        .font(.title2)

                    List(connectivityManager.availablePeers, id: \.self) { peer in
                        Button(action: {
                            self.selectedPeer = peer
                            self.pinCode = ""
                            self.showingPINAlert = true
                        }) {
                            HStack {
                                Image(systemName: "desktopcomputer")
                                Text(peer.displayName)
                                Spacer()
                                Image(systemName: "lock")
                            }
                        }
                    }
                    #if os(iOS)
                    .listStyle(.insetGrouped)
                    #else
                    .listStyle(.inset)
                    #endif
                }
            }
        }
        .navigationTitle("Automatyczne połączenie")
        // Avoid iOS-only navigation modifiers on macOS
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            _SettingsPlaceholder()
        }
        .sheet(isPresented: $showingScanner) {
            _QRScannerPlaceholder { code in
                let components = code.split(separator: "|")
                if components.count >= 2 {
                    let pin = String(components[0])
                    let name = String(components[1])
                    if let peer = connectivityManager.availablePeers.first(where: { $0.displayName == name }) {
                        print("Auto-connecting via QR to \(name)")
                        connectivityManager.invitePeer(peer, code: pin)
                    } else {
                        print("Peer \(name) not found yet.")
                    }
                }
            }
        }
        .alert("Wpisz kod PIN", isPresented: $showingPINAlert) {
            TextField("Kod z ekranu Maca", text: $pinCode)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif
            Button("Anuluj", role: .cancel) { }
            Button("Połącz") {
                if let peer = selectedPeer {
                    connectivityManager.invitePeer(peer, code: pinCode)
                }
            }
        } message: {
            Text("Wpisz 4-cyfrowy kod wyświetlany na ekranie Maca.")
        }
        .onAppear {
            connectivityManager.startBrowsing()
        }
        .onDisappear {
            connectivityManager.stopBrowsing()
        }
    }
}

#Preview {
    NavigationStack {
        ConnectionAutoView()
            .environmentObject(ConnectivityManager())
    }
}
