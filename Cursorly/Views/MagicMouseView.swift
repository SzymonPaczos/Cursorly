import SwiftUI

struct MagicMouseView: View {
    @EnvironmentObject var connectivityManager: ConnectivityManager
    @StateObject private var motionManager = MotionManager()
    @AppStorage("isAirMouseEnabled") private var isAirMouseEnabled = false
    
    @State private var isKeyboardVisible = false
    @State private var textInput: String = ""
    @State private var showMedia = false

    var body: some View {
        ZStack {
            // Tło (biurko)
            Color(red: 0.1, green: 0.1, blue: 0.1)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    motionManager.onMove = { dx, dy in
                        connectivityManager.send(event: .move(dx: dx, dy: dy))
                    }
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
            
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    Button(action: { isKeyboardVisible.toggle() }) {
                        Image(systemName: "keyboard")
                            .font(.title2)
                            .foregroundColor(isKeyboardVisible ? .orange : .white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: { showMedia.toggle() }) {
                        Image(systemName: "hifispeaker.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // HIDDEN TEXT FIELD FOR KEYBOARD
                if isKeyboardVisible {
                    TextField("Type here...", text: $textInput)
                        .onChange(of: textInput) { newValue in
                            guard !newValue.isEmpty else { return }
                            // Send last char or whole string?
                            // Sending whole string is safer for "typing" logic if we clear it.
                            // But usually we want character by character.
                            // Here we just send the new part.
                            if let lastChar = newValue.last {
                                connectivityManager.send(event: .keyboard(text: String(lastChar)))
                            }
                            // Clear immediately to keep input stream fresh
                            textInput = ""
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

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
                .frame(height: 140) // Slightly smaller to make room
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
        .sheet(isPresented: $showMedia) {
            MediaRemoteView()
        }
    }
}

struct TouchpadSurface: View {
    @ObservedObject var connectivityManager: ConnectivityManager
    @State private var previousDragValue: DragGesture.Value?
    
    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(Color.white.opacity(0.9))
                .overlay(
                    HStack(spacing: 0) {
                        // Main Touch Area
                        Color.clear
                        
                        // Scroll Strip Visual Indicator
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 40)
                            .overlay(
                                Image(systemName: "arrow.up.arrow.down")
                                    .foregroundColor(.gray.opacity(0.3))
                            )
                    }
                )
                .overlay(
                    VStack {
                        Image(systemName: "applelogo")
                            .font(.title)
                            .foregroundColor(.gray.opacity(0.3))
                            .padding(.top, 50)
                            .opacity(0.5)
                        Spacer()
                    }
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if let previous = previousDragValue {
                                let dx = value.location.x - previous.location.x
                                let dy = value.location.y - previous.location.y
                                
                                // Check if touch is on the right edge (Scroll Strip)
                                let isScrollZone = value.startLocation.x > (geo.size.width - 50)
                                
                                if isScrollZone {
                                    // Send Scroll Event
                                    connectivityManager.send(event: .scroll(dx: dx, dy: dy))
                                } else {
                                    // Send Move Event
                                    connectivityManager.send(event: .move(dx: dx, dy: dy))
                                }
                            }
                            previousDragValue = value
                        }
                        .onEnded { _ in
                            previousDragValue = nil
                        }
                )
        }
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
