import SwiftUI

struct MagicMouseView: View {
    @EnvironmentObject var connectivityManager: ConnectivityManager
    @StateObject private var motionManager = MotionManager()
    @AppStorage("isAirMouseEnabled") private var isAirMouseEnabled = false
    
    var body: some View {
        ZStack {
            // Tło (biurko)
            Color(red: 0.1, green: 0.1, blue: 0.1)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    // Skonfiguruj callback
                    motionManager.onMove = { dx, dy in
                        connectivityManager.send(event: .move(dx: dx, dy: dy))
                    }
                    // Włącz jeśli ustawienie aktywne
                    if isAirMouseEnabled {
                        motionManager.isActive = true
                    }
                }
                .onDisappear {
                    motionManager.isActive = false
                }
                .onChange(of: isAirMouseEnabled) { newValue in
                    motionManager.isActive = newValue
                }
            
            // Kształt Myszki
            VStack(spacing: 0) {
                // Górna część (Przyciski)
                HStack(spacing: 2) {
                    // Lewy Przycisk
                    ButtonZone(title: "", color: .white.opacity(0.95)) {
                        connectivityManager.send(event: .click(button: "left"))
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                    
                    // Prawy Przycisk
                    ButtonZone(title: "", color: .white.opacity(0.95)) {
                        connectivityManager.send(event: .click(button: "right"))
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
                .frame(height: 180)
                .overlay(
                    // Scroll Wheel (Wizualny) na środku
                    Capsule()
                        .fill(LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                        .frame(width: 40, height: 100)
                        .overlay(
                            VStack(spacing: 6) {
                                ForEach(0..<10) { _ in
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.4))
                                        .frame(height: 2)
                                }
                            }
                        )
                        .padding(.top, 20)
                , alignment: .top)
                
                // Dolna część (Gładzik)
                TouchpadSurface(connectivityManager: connectivityManager)
            }
            .cornerRadius(40)
            .padding(20)
            .shadow(color: .white.opacity(0.1), radius: 20, x: 0, y: 0)
        }
    }
}

struct TouchpadSurface: View {
    @ObservedObject var connectivityManager: ConnectivityManager
    @State private var previousDragValue: DragGesture.Value?
    
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.9))
            .overlay(
                VStack {
                    Image(systemName: "applelogo")
                        .font(.title)
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.top, 50)
                    Spacer()
                    Text("Gładzik")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.bottom, 20)
                }
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if let previous = previousDragValue {
                            let dx = value.location.x - previous.location.x
                            let dy = value.location.y - previous.location.y
                            connectivityManager.send(event: .move(dx: dx, dy: dy))
                        }
                        previousDragValue = value
                    }
                    .onEnded { _ in
                        previousDragValue = nil
                    }
            )
    }
}

struct ButtonZone: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Rectangle()
            .fill(color)
            .overlay(Text(title).foregroundColor(.gray))
            .onTapGesture {
                action()
            }
    }
}

#Preview {
    MagicMouseView()
        .environmentObject(ConnectivityManager())
}
