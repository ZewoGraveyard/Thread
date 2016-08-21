import XCTest
import Foundation
@testable import Thread

class LockTests: XCTestCase {
    func testWaitsForCondition() {
        let start = NSDate().timeIntervalSince1970

        let condition = Condition()
        let lock = Lock()
        _ = Thread<Void> {
            sleep(1)
            condition.resolve()
        }

        lock.acquire {
            lock.wait(for: condition)
        }

        let duration = NSDate().timeIntervalSince1970 - start
        XCTAssertGreaterThan(duration, 1)
    }

    func testLockEnsuresThreadSafety() {
        // if it doesnt crash, it succeeds

        let lock = Lock()
        var results = [Int]()

        _ = Thread {
            for i in 1...10000 {
                lock.acquire {
                    results.append(i)
                }
            }
        }
        _ = Thread {
            for i in 1...10000 {
                lock.acquire {
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
