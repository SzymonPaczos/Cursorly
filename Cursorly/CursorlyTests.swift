import XCTest
@testable import Cursorly

final class CursorlyTests: XCTestCase {

    func testCursorEventEncoding() throws {
        // Given
        let originalEvent = CursorEvent.move(dx: 10.5, dy: -5.0)
        
        // When
        let data = try JSONEncoder().encode(originalEvent)
        let decodedEvent = try JSONDecoder().decode(CursorEvent.self, from: data)
        
        // Then
        XCTAssertEqual(originalEvent.type, decodedEvent.type)
        XCTAssertEqual(originalEvent.x, decodedEvent.x)
        XCTAssertEqual(originalEvent.y, decodedEvent.y)
    }
    
    func testClickEvent() throws {
        // Given
        let clickEvent = CursorEvent.click(button: "right")
        
        // Then
        XCTAssertEqual(clickEvent.type, .click)
        XCTAssertEqual(clickEvent.additionalData, "right")
        XCTAssertEqual(clickEvent.x, 0)
    }
}
