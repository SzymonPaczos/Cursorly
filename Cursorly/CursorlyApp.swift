import SwiftUI

@main
struct CursorlyApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            NavigationStack {
                WelcomeView()
            }
            #elseif os(macOS)
            MacWelcomeView()
            #endif
        }
    }
} 