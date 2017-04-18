//
//  NSCodingTests.swift
//  Apic
//
//  Created by Juan Jose Arreola on 17/04/17.
//
//

import XCTest
import Apic

class NSCodingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        DefaultTypeResolver.shared.register(types: Status.self, Response.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    @available(OSX 10.12, *)
    func testSerialize() {
        let obj = Serializable()
        obj.id = "1"
        obj.name = "test"
        obj.options = [1, 2]
        obj.status = .canceled
        obj.history = [.ok, .canceled]
        obj.response = Response(id: "2", status: .ok)
        obj.previous = [Response(id: "4", status: .canceled)]
        
        let data = NSKeyedArchiver.archivedData(withRootObject: obj)
        
        let result = NSKeyedUnarchiver.unarchiveObject(with: data) as? Serializable
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.id, obj.id)
        XCTAssertEqual(result!.name, obj.name)
        XCTAssertEqual(result!.count, obj.count)
        XCTAssertEqual(result!.option, obj.option)
        XCTAssertEqual(result!.options, obj.options)
        XCTAssertEqual(result!.status, obj.status)
        XCTAssertEqual(result!.history, obj.history)
        XCTAssertEqual(result!.response, obj.response)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}


enum Status: IntInitializable {
    case error, ok, canceled
    
    init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .error
        case 1: self = .ok
        case 2: self = .canceled
        default:
            return nil
        }
    }
    
    var rawValue: Int {
        switch self {
        case .error: return 0
        case .ok: return 1
        case .canceled: return 2
        }
    }
}

class Response: AbstractModel {
    var id: String!
    var status: Status!
    
    convenience init(id: String, status: Status) {
        self.init()
        self.id = id
        self.status = status
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Response else { return false }
        return id == other.id
    }
    
    override func value(forKey key: String) -> Any? {
        switch key {
        case "status": return status.rawValue
        default:
            return super.value(forKey: key)
        }
    }
    
    override func assign(value: Any, forProperty property: String) throws {
        switch property {
        case "status": status = value as! Status
        default:
            try super.assign(value: value, forProperty: property)
        }
    }
}

class Serializable: AbstractModel {
    
    var id: String = ""
    var name: String?
    var count: Int = 0
    var option: Int? = 0
    
    var options: [Int] = []
    
    var status: Status! = .ok
    var history: [Status] = []
    
    var response: Response!
    var previous: [Response]?
    
    override func assign(value: Any, forProperty property: String) throws {
        switch property {
        case "option": option = value as? Int
        case "status": status = value as! Status
        case "history": history = value as! [Status]
        default:
            try super.assign(value: value, forProperty: property)
        }
    }
    
    override func value(forKey key: String) -> Any? {
        switch key {
        case "option": return option
        case "status": return status.rawValue
        case "history": return history.map({ $0.rawValue })
        default:
            return super.value(forKey: key)
        }
    }
    
}
