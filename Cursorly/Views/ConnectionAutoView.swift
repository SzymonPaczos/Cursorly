import SwiftUI

struct ConnectionAutoView: View {
    @EnvironmentObject var connectivityManager: ConnectivityManager
    @State private var showingPINAlert = false
    @State private var showingSettings = false
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
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
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