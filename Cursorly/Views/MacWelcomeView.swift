import SwiftUI
#if os(macOS)
import ApplicationServices
#endif

 struct MacWelcomeView: View {
    @EnvironmentObject var connectivityManager: ConnectivityManager
    @State private var isAccessibilityTrusted: Bool = false
    let checkTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                Spacer()
                
                // Tytuł i opis
                VStack(spacing: 16) {
                    Text("Cursorly – Serwer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    if connectivityManager.isHosting {
                        VStack(spacing: 10) {
                            Label("Nasłuchiwanie połączeń...", systemImage: "antenna.radiowaves.left.and.right")
                                .foregroundColor(.green)
                            
                            Text("KOD PAROWANIA:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 10)
                            
                            Text(connectivityManager.pairingCode)
                                .font(.system(size: 48, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(10)
                        }
                    } else {
                        Text("Serwer zatrzymany")
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Lista podłączonych urządzeń
                VStack(spacing: 20) {
                    Text("Podłączone urządzenia:")
                        .font(.headline)
                    
                    if connectivityManager.connectedPeers.isEmpty {
                        Text("Brak połączonych urządzeń")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(connectivityManager.connectedPeers, id: \.self) { peer in
                            HStack {
                                Image(systemName: "iphone")
                                Text(peer.displayName)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            .blur(radius: isAccessibilityTrusted ? 0 : 5)
            
            // Overlay z instrukcją
            if !isAccessibilityTrusted {
                VStack(spacing: 20) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Wymagane Uprawnienia")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Aby sterować kursorem, aplikacja potrzebuje dostępu do funkcji Dostępności.")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "1.circle.fill")
                            Text("Kliknij przycisk poniżej, aby otworzyć Ustawienia.")
                        }
                        HStack {
                            Image(systemName: "2.circle.fill")
                            Text("Włącz przełącznik przy 'Cursorly'.")
                        }
                        HStack {
                            Image(systemName: "3.circle.fill")
                            Text("Aplikacja wykryje zmianę automatycznie.")
                        }
                    }
                    .font(.callout)
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(10)
                    
                    Button("Otwórz Ustawienia Systemowe") {
                        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                        NSWorkspace.shared.open(url)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(40)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .shadow(radius: 20)
            }
        }
        .frame(minWidth: 500, minHeight: 400) // Trochę większe okno na instrukcje
        .padding()
        .onAppear {
            checkPermission()
            connectivityManager.startHosting()
        }
        .onDisappear {
            connectivityManager.stopHosting()
        }
        .onChange(of: connectivityManager.connectedPeers) { peers in
            if !peers.isEmpty && isAccessibilityTrusted {
                // Zminimalizuj okno po połączeniu (tylko jeśli uprawnienia są ok)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    NSApp.windows.first?.miniaturize(nil)
                }
            }
        }
        .onReceive(checkTimer) { _ in
            checkPermission()
        }
    }
    
    private func checkPermission() {
        #if os(macOS)
        isAccessibilityTrusted = AXIsProcessTrusted()
        #endif
    }
}

#Preview {
    MacWelcomeView()
} 