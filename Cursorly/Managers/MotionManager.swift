import Foundation
#if os(iOS)
import CoreMotion
#endif
import SwiftUI

#if os(iOS)
class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    // Czułość mychy
    @AppStorage("airMouseSensitivity") private var sensitivity: Double = 15.0
    
    // Callback do wysyłania zdarzeń
    var onMove: ((CGFloat, CGFloat) -> Void)?
    
    @Published var isActive: Bool = false {
        didSet {
            if isActive {
                startUpdates()
            } else {
                stopUpdates()
            }
        }
    }
    
    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device Motion not available")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 Hz
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] (data, error) in
            guard let self = self, let data = data else { return }
            
            // Używamy rotationRate (żyroskop)
            let rotation = data.rotationRate
            
            // Wykrywanie czy telefon leży płasko (Smart Pause)
            // Grawitacja na osi Z bliska 1.0 lub -1.0 oznacza, że ekran jest poziomo
            let isFlat = abs(data.gravity.z) > 0.9
            
            if isFlat {
                // Jeśli leży płasko, ignorujemy żyroskop (nie przesuwamy kursora)
                return
            }
            
            // Mapowanie obrotu na ruch kursora
            // Oś Z (yaw) -> Ruch w poziomie (X)
            // Oś X (pitch) -> Ruch w pionie (Y)
            
            let dx = CGFloat(-rotation.z * self.sensitivity)
            let dy = CGFloat(-rotation.x * self.sensitivity)
            
            // Ignorujemy minimalne drgania (deadzone)
            if abs(dx) > 0.1 || abs(dy) > 0.1 {
                DispatchQueue.main.async {
                    self.onMove?(dx, dy)
                }
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
#else
// macOS placeholder - motion tracking not available
class MotionManager: ObservableObject {
    @Published var isActive: Bool = false
    var onMove: ((CGFloat, CGFloat) -> Void)?
    
    func startUpdates() {
        print("Motion tracking not available on macOS")
    }
    
    func stopUpdates() {}
}
#endif
