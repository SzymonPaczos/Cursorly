import Foundation

enum CursorEventType: String, Codable {
    case move
    case click
    case scroll
}

struct CursorEvent: Codable {
    let type: CursorEventType
    let x: CGFloat
    let y: CGFloat
    let additionalData: String? // Np. "left", "right" dla kliknięć
    
    // Helpery do tworzenia zdarzeń
    static func move(dx: CGFloat, dy: CGFloat) -> CursorEvent {
        return CursorEvent(type: .move, x: dx, y: dy, additionalData: nil)
    }
    
    static func click(button: String) -> CursorEvent {
        return CursorEvent(type: .click, x: 0, y: 0, additionalData: button)
    }
}
