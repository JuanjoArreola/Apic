//
//  DoubleTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 1/23/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class DoubleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMandatoryDouble() {
        do {
            let container = try DoubleContainer(dictionary: ["id": 1.0])
            XCTAssertNotNil(container.id)
        } catch { XCTFail() }
    }
    
    func testMandatoryDoubleCompatibleType() {
        do {
            let container = try DoubleContainer(dictionary: ["id": "1.0"])
            XCTAssertEqual(container.id, 1)
        } catch { XCTFail() }
    }
    
    func testMandatoryDoubleNil() {
        do {
            try DoubleContainer(dictionary: ["name": "1.0"])
            XCTFail()
        } catch { }
    }
    
    func testInvalidDouble() {
        do {
            try DoubleContainer(dictionary: ["id": "one"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalDoubleNil() {
        do {
            let container = try DoubleContainer(dictionary: ["id": 1.0])
            XCTAssertNotNil(container)
            XCTAssertNil(container.option)
        } catch { XCTFail() }
    }
    
    func testOptionalDoubleNotNil() {
        do {
            let container = try DoubleContainer(dictionary: ["id": 1.0, "option": 4.0])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.option)
        } catch { XCTFail() }
    }
    
    func testChangeDouble() {
        do {
            let container = try DoubleContainer(dictionary: ["id": 1.0, "value": 2.0])
            XCTAssertNotNil(container)
            XCTAssertEqual(container.value, 2.0)
        } catch { XCTFail() }
    }
    
    //    MARK: [Double]
    
    func testMandatoryDoubleArray() {
        do {
            let container = try DoubleArrayContainer(dictionary: ["ids": [1.0, 2.0, 3.0]])
            XCTAssertEqual(container.ids, [1.0, 2.0, 3.0])
        } catch {
            XCTFail()
        }
    }
    
    func testMandatoryDoubleArrayNil() {
        do {
            try DoubleArrayContainer(dictionary: ["id": "1"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalDoubleArrayNil() {
        do {
            let container = try DoubleArrayContainer(dictionary: ["ids": [1.0, 2.0, 3.0]])
            XCTAssertNotNil(container)
            XCTAssertNil(container.values)
        } catch { XCTFail() }
    }
    
    func testInvalidDoubleArray() {
        do {
            try DoubleArrayContainer(dictionary: ["ids": ["one", "two"]])
            XCTFail()
        } catch { }
    }
    
    func testInvalidArray() {
        do {
            try DoubleArrayContainer(dictionary: ["ids": "one"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalDoubleArrayNotNil() {
        do {
            let container = try DoubleArrayContainer(dictionary: ["ids": [1.0, 2.0, 3.0], "values": [4.0, 5.0, 6.0]])
            XCTAssertNotNil(container.values)
            XCTAssertEqual(container.values!, [4.0, 5.0, 6.0])
        } catch {
            XCTFail()
        }
    }
    
    func testDoubleArrayCompatibleType() {
        do {
            let container = try DoubleArrayContainer(dictionary: ["ids": ["1.0", "2.0", "3.0"]])
            XCTAssertEqual(container.ids, [1.0, 2.0, 3.0])
        } catch {
            XCTFail()
        }
    }
    
    func testChangeDoubleArray() {
        do {
            let container = try DoubleArrayContainer(dictionary: ["ids": [1.0, 2.0, 3.0], "options": [3.0, 4.0]])
            XCTAssertEqual(container.options, [3.0, 4.0])
        } catch {
            XCTFail()
        }
    }
}

class DoubleContainer: AbstractModel {
    var id: Double = 0.0
    var option: Double?
    var value: Double = 1.0
    
    override func assignValue(value: AnyObject, forProperty property: String) throws {
        if property == "option" { option = value as? Double}
        else {
            try super.assignValue(value, forProperty: property)
        }
    }
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return ["id"].contains(property)
    }
}

class DoubleArrayContainer: AbstractModel {
    var ids: [Double]!
    var values: [Double]?
    var options: [Double] = [1.0, 2.0]
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return ["ids"].contains(property)
    }
}