import XCTest
import Foundation
@testable import Thread

class LockTests: XCTestCase {
    func testWaitsForCondition() throws {
        let start = NSDate().timeIntervalSince1970

        let condition = try Condition()
        let lock = try Lock()
        _ = try Thread {
            sleep(1)
            condition.resolve()
        }

        try lock.acquire {
            lock.wait(for: condition)
        }

        let duration = NSDate().timeIntervalSince1970 - start
        XCTAssertGreaterThan(duration, 1)
    }

    func testLockEnsuresThreadSafety() throws {
        // if it doesnt crash, it succeeds

        let lock = try Lock()
        var results = [Int]()

        _ = try Thread {
            for i in 1...10000 {
                try lock.acquire {
                    results.append(i)
                }
            }
        }
        _ = try Thread {
            for i in 1...10000 {
                try lock.acquire {
                    results.append(i)
                }
            }
        }

        sleep(1)
    }
}

extension LockTests {
    static var allTests : [(String, (LockTests) -> () throws -> Void)] {
        return [
           ("testWaitsForCondition", testWaitsForCondition),
           ("testLockEnsuresThreadSafety", testLockEnsuresThreadSafety)
        ]
    }
}
