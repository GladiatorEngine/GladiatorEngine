import XCTest
@testable import Engine

final class EngineTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Engine().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
