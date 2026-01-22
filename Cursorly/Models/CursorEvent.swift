import Foundation

enum CursorEventType: String, Codable {
    case move
    case click
    case scroll
    case keyboard
    case media
}

struct CursorEvent: Codable {
    let type: CursorEventType
    let x: CGFloat
    let y: CGFloat
    let additionalData: String? // Np. "left", "right", text, key code
    
    // Helpery do tworzenia zdarzeń
    static func move(dx: CGFloat, dy: CGFloat) -> CursorEvent {
        return CursorEvent(type: .move, x: dx, y: dy, additionalData: nil)
    }
    
    static func click(button: String) -> CursorEvent {
        return CursorEvent(type: .click, x: 0, y: 0, additionalData: button)
    }
    
    static func scroll(dx: CGFloat, dy: CGFloat) -> CursorEvent {
        return CursorEvent(type: .scroll, x: dx, y: dy, additionalData: nil)
    }
    
    static func keyboard(text: String) -> CursorEvent {
        return CursorEvent(type: .keyboard, x: 0, y: 0, additionalData: text)
    }
    
    static func media(action: String) -> CursorEvent {
        return CursorEvent(type: .media, x: 0, y: 0, additionalData: action)
    }
}
