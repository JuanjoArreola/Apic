//
//  BoolTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 1/23/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class BoolTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMandatoryBool() {
        do {
            let container = try BoolContainer(dictionary: ["hasId": true])
            XCTAssertNotNil(container.hasId)
        } catch { XCTFail() }
    }
    
    func testMandatoryBoolCompatibleType() {
        do {
            let container = try BoolContainer(dictionary: ["hasId": "true"])
            XCTAssertEqual(container.hasId, true)
        } catch { XCTFail() }
    }
    
    func testMandatoryBoolNil() {
        do {
            _ = try BoolContainer(dictionary: ["id": true])
            XCTFail()
        } catch { }
    }
    
    func testInvalidBool() {
        do {
            _ = try BoolContainer(dictionary: ["hasId": "one"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalBoolNil() {
        do {
            let container = try BoolContainer(dictionary: ["hasId": true])
            XCTAssertNotNil(container)
            XCTAssertNil(container.option)
        } catch { XCTFail() }
    }
    
    func testOptionalBoolNotNil() {
        do {
            let container = try BoolContainer(dictionary: ["hasId": 1.0, "option": true])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.option)
        } catch { XCTFail() }
    }
    
    func testChangeBool() {
        do {
            let container = try BoolContainer(dictionary: ["hasId": true, "value": true])
            XCTAssertNotNil(container)
            XCTAssertEqual(container.value, true)
        } catch { XCTFail() }
    }
    
    //    MARK: [Bool]
    
    func testMandatoryBoolArray() {
        do {
            let container = try BoolArrayContainer(dictionary: ["hasIds": [true, true, false]])
            XCTAssertEqual(container.hasIds, [true, true, false])
        } catch {
            XCTFail()
        }
    }
    
    func testMandatoryBoolArrayNil() {
        do {
            _ = try BoolArrayContainer(dictionary: ["ids": [true, true, false]])
            XCTFail()
        } catch { }
    }
    
    func testOptionalBoolArrayNil() {
        do {
            let container = try BoolArrayContainer(dictionary: ["hasIds": [true, true, false]])
            XCTAssertNotNil(container)
            XCTAssertNil(container.values)
        } catch { XCTFail() }
    }
    
    func testInvalidBoolArray() {
        do {
            _ = try BoolArrayContainer(dictionary: ["hasIds": ["one", "two"]])
            XCTFail()
        } catch { }
    }
    
    func testInvalidArray() {
        do {
            _ = try BoolArrayContainer(dictionary: ["hasIds": "one"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalBoolArrayNotNil() {
        do {
            let container = try BoolArrayContainer(dictionary: ["hasIds": [true, true, false], "values": [true, false]])
            XCTAssertNotNil(container.values)
            XCTAssertEqual(container.values!, [true, false])
        } catch {
            XCTFail()
        }
    }
    
    func testBoolArrayCompatibleType() {
        do {
            let container = try BoolArrayContainer(dictionary: ["hasIds": ["true", "True", "1", 1, "false", "False", "0", 0]])
            XCTAssertEqual(container.hasIds, [true, true, true, true, false, false, false, false])
        } catch {
            XCTFail()
        }
    }
    
    func testChangeBoolArray() {
        do {
            let container = try BoolArrayContainer(dictionary: ["hasIds": [true, true], "options": [true, true]])
            XCTAssertEqual(container.options, [true, true])
        } catch {
            XCTFail()
        }
    }
}

class BoolContainer: AbstractModel {
    var hasId: Bool = false
    var option: Bool?
    var value: Bool = false
    
    override func assign(value: Any?, forProperty property: String) throws {
        if property == "option" { option = value as? Bool}
        else {
            try super.assign(value: value, forProperty: property)
        }
    }
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["hasId"].contains(property)
    }
}

class BoolArrayContainer: AbstractModel {
    var hasIds: [Bool]!
    var values: [Bool]?
    var options: [Bool] = [true, false]
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["hasIds"].contains(property)
    }
}
