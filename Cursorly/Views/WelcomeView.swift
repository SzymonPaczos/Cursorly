import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Tytuł i opis
            VStack(spacing: 16) {
                Text("Cursorly – połącz z komputerem")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text("Zamień iPhone'a w bezprzewodową myszkę")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Przyciski połączenia
            VStack(spacing: 16) {
                NavigationLink(destination: ConnectionAutoView()) {
                    ConnectionButton(
                        title: "Połącz automatycznie (Bluetooth/Wi-Fi)",
                        icon: "antenna.radiowaves.left.and.right",
                        color: .blue
                    )
                }
                
                NavigationLink(destination: ConnectionManualView()) {
                    ConnectionButton(
                        title: "Połącz przez IP ręcznie",
                        icon: "network",
                        color: .green
                    )
                }
                
                NavigationLink(destination: ConnectionPremiumView()) {
                    ConnectionButton(
                        title: "Połącz przez Internet (premium)",
                        icon: "globe",
                        color: .orange
                    )
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

struct ConnectionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
} 