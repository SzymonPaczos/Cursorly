import SwiftUI

struct ConnectionAutoView: View {
    @EnvironmentObject var connectivityManager: ConnectivityManager
    @State private var showingPINAlert = false
    @State private var showingSettings = false
    @State private var showingScanner = false
    @State private var selectedPeer: MCPeerID?
    @State private var pinCode = ""
    
    var body: some View {
        VStack(spacing: 30) {
            
            if !connectivityManager.connectedPeers.isEmpty {
                // Połączono - wyświetl interfejs Magic Mouse
                MagicMouseView()
                    .navigationBarHidden(true)
                
            } else {
                // Widok wyszukiwania
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Button(action: { showingScanner = true }) {
                            VStack {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
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
                    .listStyle(.insetGrouped)
                }
            }
        }
        .navigationTitle("Automatyczne połączenie")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingScanner) {
            QRScannerView { code in
                // Format kodu: "1234|NazwaMaca"
                let components = code.split(separator: "|")
                if components.count >= 2 {
                    let pin = String(components[0])
                    let name = String(components[1])
                    
                    // Znajdź peera o tej nazwie
                    if let peer = connectivityManager.availablePeers.first(where: { $0.displayName == name }) {
                        print("Auto-connecting via QR to \(name)")
                        connectivityManager.invitePeer(peer, code: pin)
                    } else {
                        // Jeśli nie znaleziono, można np. poczekać lub wyświetlić błąd
                        print("Peer \(name) not found yet.")
                    }
                }
            }
        }
        .alert("Wpisz kod PIN", isPresented: $showingPINAlert) {
            TextField("Kod z ekranu Maca", text: $pinCode)
                .keyboardType(.numberPad)
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
    }
} 