import XCTest
@testable import Apic

class ApicTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Apic().text, "Hello, World!")
    }


    static var allTests : [(String, (ApicTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
