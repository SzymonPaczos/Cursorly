import SwiftUI

struct ConnectionManualView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "network")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: 16) {
                Text("Tryb ręczny")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Połączenie przez IP")
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
        .navigationTitle("Ręczne połączenie")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        ConnectionManualView()
    }
} 