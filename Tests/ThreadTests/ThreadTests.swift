import XCTest
@testable import Thread

class ThreadTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Thread().text, "Hello, World!")
    }


    static var allTests : [(String, (ThreadTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
