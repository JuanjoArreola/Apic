//
//  IntTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 1/23/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class IntTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMandatoryInt() {
        do {
            let container = try IntContainer(dictionary: ["id": 1])
            XCTAssertNotNil(container.id)
        } catch { XCTFail() }
    }
    
    func testMandatoryIntCompatibleType() {
        do {
            let container = try IntContainer(dictionary: ["id": "1"])
            XCTAssertEqual(container.id, 1)
        } catch { XCTFail() }
    }
    
    func testMandatoryIntNil() {
        do {
            _ = try IntContainer(dictionary: ["name": "1"])
            XCTFail()
        } catch { }
    }
    
    func testInvalidInt() {
        do {
            _ = try IntContainer(dictionary: ["id": "one"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalIntNil() {
        do {
            let container = try IntContainer(dictionary: ["id": 1])
            XCTAssertNotNil(container)
            XCTAssertNil(container.option)
        } catch { XCTFail() }
    }
    
    func testOptionalIntNotNil() {
        do {
            let container = try IntContainer(dictionary: ["id": 1, "option": 4])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.option)
        } catch { XCTFail() }
    }
    
    func testUnwrappedIntNotNil() {
        do {
            let container = try IntContainer(dictionary: ["id": 1, "level": 6])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.level)
        } catch { XCTFail() }
    }
    
    func testChangeInt() {
        do {
            let container = try IntContainer(dictionary: ["id": 1, "value": 2])
            XCTAssertNotNil(container)
            XCTAssertEqual(container.value, 2)
        } catch { XCTFail() }
    }
    
    //    MARK: [Int]
    
    func testMandatoryIntArray() {
        do {
            let container = try IntArrayContainer(dictionary: ["ids": [1, 2, 3]])
            XCTAssertEqual(container.ids, [1, 2, 3])
        } catch {
            XCTFail()
        }
    }
    
    func testMandatoryIntArrayNil() {
        do {
            _ = try IntArrayContainer(dictionary: ["id": "1"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalIntArrayNil() {
        do {
            let container = try IntArrayContainer(dictionary: ["ids": [1, 2, 3]])
            XCTAssertNotNil(container)
            XCTAssertNil(container.values)
        } catch { XCTFail() }
    }
    
    func testInvalidIntArray() {
        do {
            _ = try IntArrayContainer(dictionary: ["ids": ["one", "two"]])
            XCTFail()
        } catch { }
    }
    
    func testInvalidArray() {
        do {
            _ = try IntArrayContainer(dictionary: ["ids": "one"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalIntArrayNotNil() {
        do {
            let container = try IntArrayContainer(dictionary: ["ids": [1, 2, 3], "values": [4, 5, 6]])
            XCTAssertNotNil(container.values)
            XCTAssertEqual(container.values!, [4, 5, 6])
        } catch {
            XCTFail()
        }
    }
    
    func testChangeIntArray() {
        do {
            let container = try IntArrayContainer(dictionary: ["ids": [1, 2, 3], "options": [3, 4]])
            XCTAssertEqual(container.options, [3, 4])
        } catch {
            XCTFail()
        }
    }
}

class IntContainer: AbstractModel {
    var id: Int!
    var option: Int?
    var level: Int! = 0
    var value: Int = 1
    
    override func assign(value: Any, forProperty property: String) throws {
        if property == "option" { option = value as? Int}
        else if property == "level" { level = value as! Int}
        else if property == "id" { id = value as! Int}
        else {
            try super.assign(value: value, forProperty: property)
        }
    }
}

class IntArrayContainer: AbstractModel {
    var ids: [Int]!
    var values: [Int]?
    var options: [Int] = [1, 2]
}
