import SwiftUI

struct ConnectionPremiumView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "globe")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            VStack(spacing: 16) {
                Text("Tryb premium")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Połączenie przez Internet")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Jeszcze w budowie")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .navigationTitle("Premium połączenie")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        ConnectionPremiumView()
    }
} 