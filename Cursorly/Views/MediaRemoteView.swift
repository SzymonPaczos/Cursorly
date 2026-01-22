import SwiftUI

struct MediaRemoteView: View {
    @EnvironmentObject var connectivityManager: ConnectivityManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.12, blue: 0.12)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                // Header
                HStack {
                    Spacer()
                    Text("Media Control")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Volume Controls
                HStack(spacing: 40) {
                    MediaButton(icon: "speaker.wave.1.fill", label: "Vol -") {
                        connectivityManager.send(event: .media(action: "voldown"))
                    }
                    
                    MediaButton(icon: "speaker.slash.fill", label: "Mute", color: .red.opacity(0.8)) {
                        connectivityManager.send(event: .media(action: "mute"))
                    }
                    
                    MediaButton(icon: "speaker.wave.3.fill", label: "Vol +") {
                        connectivityManager.send(event: .media(action: "volup"))
                    }
                }
                
                // Playback Controls
                HStack(spacing: 30) {
                    MediaButton(icon: "backward.fill", size: 30) {
                        connectivityManager.send(event: .media(action: "prev"))
                    }
                    
                    MediaButton(icon: "playpause.fill", size: 50, color: .orange) {
                        connectivityManager.send(event: .media(action: "playpause"))
                    }
                    
                    MediaButton(icon: "forward.fill", size: 30) {
                        connectivityManager.send(event: .media(action: "next"))
                    }
                }
                
                Spacer()
                Spacer()
            }
            .padding()
        }
    }
}

struct MediaButton: View {
    var icon: String
    var label: String? = nil
    var size: CGFloat = 24
    var color: Color = .white.opacity(0.2)
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: size * 2.5, height: size * 2.5)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                    
                    Image(systemName: icon)
                        .font(.system(size: size))
                        .foregroundColor(.white)
                }
                if let label = label {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    MediaRemoteView()
        .environmentObject(ConnectivityManager())
}
