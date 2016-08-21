import XCTest
@testable import ThreadTestSuite

XCTMain([
     testCase(ThreadTests.allTests),
     testCase(LockTests.allTests)
])
