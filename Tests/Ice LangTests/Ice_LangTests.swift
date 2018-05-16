import XCTest
@testable import Ice_Lang

final class Ice_LangTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Ice_Lang().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
