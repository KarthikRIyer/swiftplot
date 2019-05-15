import XCTest
@testable import swiftplot

final class swiftplotTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(swiftplot().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
