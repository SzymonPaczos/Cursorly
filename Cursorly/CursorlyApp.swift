import SwiftUI

@main
struct CursorlyApp: App {
    @StateObject private var connectivityManager = ConnectivityManager()
    
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            NavigationStack {
                WelcomeView()
            }
            .environmentObject(connectivityManager)
            #elseif os(macOS)
            MacWelcomeView()
                .environmentObject(connectivityManager)
            #endif
        }
            #endif
        }
        
        #if os(macOS)
        MenuBarExtra {
            Button("Status: \(connectivityManager.connectedPeers.isEmpty ? "Oczekiwanie..." : "Połączono: \(connectivityManager.connectedPeers.first?.displayName ?? "")")") {    
            }
            .disabled(true)
            
            Divider()
            
            Button("Zakończ") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            let isConnected = !connectivityManager.connectedPeers.isEmpty
            Image(systemName: isConnected ? "cursorarrow.rays" : "cursorarrow")
        }
        #endif
    }
} 