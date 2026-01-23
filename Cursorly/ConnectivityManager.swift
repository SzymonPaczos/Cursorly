import Foundation
import Combine

final class ConnectivityManager: ObservableObject {
    struct Peer: Identifiable, Equatable {
        let id = UUID()
        let displayName: String
    }
    
    @Published var connectedPeers: [Peer] = []
    
    // Convenience initializer for testing/demo
    init(connectedDisplayName: String? = nil) {
        if let name = connectedDisplayName {
            self.connectedPeers = [Peer(displayName: name)]
        }
    }
}
