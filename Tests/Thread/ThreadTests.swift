import XCTest
@testable import Thread

class ThreadTests: XCTestCase {
    func testExecution() {
        let arr = [1,2,3,4,5]
        var sum: Int?

        _ = Thread {
            sum = arr.reduce(0, combine: +)
        }

        sleep(1)

        XCTAssertEqual(sum, 15)
    }

    func testDone() {
        let arr = [1,2,3,4,5]
        var sum: Int?

        let thread = Thread {
            sum = arr.reduce(0, combine: +)
        }

        //TODO: set a timeout that cancels the thread (we want
        // the test to fail, after all)
        while !thread.done {
            // 10ms
            usleep(10_000)
        }

        XCTAssertEqual(sum, 15)
    }

    func testJoin() {
        let arr = [1,2,3,4,5]

        let sum = Thread {
            return arr.reduce(0, combine: +)
        }.join()

        XCTAssertEqual(sum, 15)
    }
}

extension ThreadTests {
    static var allTests : [(String, (ThreadTests) -> () throws -> Void)] {
        return [
            ("testExecution", testExecution),
            ("testDone", testDone),
            ("testJoin", testJoin)
        ]
    }
}
