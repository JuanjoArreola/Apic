import XCTest
import Apic

class DateTests: XCTestCase {
    
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
                {"object": "2016-01-23 18:30:00Z",
                 "status": "OK"
                }
                """
        let data = json.data(using: .utf8)
        do {
            let date: Date = try parser.object(from: data, response: nil, error: nil)
            XCTAssertEqual(date, Date(timeIntervalSinceReferenceDate: 475266600.0))
        } catch {
            print(error)
            XCTFail()
        }
    }
    
}

extension DefaultResponseParser: CustomDateParsing {
    public var dateFormats: [String] {
        return ["y-MM-dd HH:mm:ssZ"]
    }
}
