import SwiftUI

struct MacWelcomeView: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Tytuł i opis
            VStack(spacing: 16) {
                Text("Cursorly – aplikacja desktopowa")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text("Wersja macOS - w budowie")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Placeholder dla przyszłych funkcjonalności
            VStack(spacing: 20) {
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Aplikacja desktopowa będzie dostępna wkrótce")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(minWidth: 400, minHeight: 300)
        .padding()
    }
}

#Preview {
    MacWelcomeView()
} 