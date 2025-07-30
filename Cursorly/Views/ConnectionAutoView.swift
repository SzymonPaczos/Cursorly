import SwiftUI

struct ConnectionAutoView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 16) {
                Text("Tryb automatyczny")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Połączenie Bluetooth/Wi-Fi")
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
        .navigationTitle("Automatyczne połączenie")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        ConnectionAutoView()
    }
} 