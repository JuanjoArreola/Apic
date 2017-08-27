import XCTest
import Apic4

class DecimalTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let parser = DefaultResponseParser()
        let json = """
                {"object": 80.50, "status": "OK"}
                """
        let data = json.data(using: .utf8)
        do {
            let number: Decimal = try parser.object(from: data, response: nil, error: nil)
            XCTAssertEqual(number, Decimal(floatLiteral: 80.5))
        } catch {
            print(error)
            XCTFail()
        }
    }
}
