//
//  FloatTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 1/23/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class FloatTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMandatoryFloat() {
        do {
            let container = try FloatContainer(dictionary: ["id": 1.0])
            XCTAssertNotNil(container.id)
        } catch { XCTFail() }
    }
    
    func testMandatoryFloatCompatibleType() {
        do {
            let container = try FloatContainer(dictionary: ["id": "1.0"])
            XCTAssertEqual(container.id, 1)
        } catch { XCTFail() }
    }
    
    func testMandatoryFloatNil() {
        do {
            _ = try FloatContainer(dictionary: ["name": "1.0"])
            XCTFail()
        } catch { }
    }
    
    func testInvalidFloat() {
        do {
            _ = try FloatContainer(dictionary: ["id": "one"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalFloatNil() {
        do {
            let container = try FloatContainer(dictionary: ["id": 1.0])
            XCTAssertNotNil(container)
            XCTAssertNil(container.option)
        } catch { XCTFail() }
    }
    
    func testOptionalFloatNotNil() {
        do {
            let container = try FloatContainer(dictionary: ["id": 1.0, "option": 4.0])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.option)
        } catch { XCTFail() }
    }
    
    func testChangeFloat() {
        do {
            let container = try FloatContainer(dictionary: ["id": 1.0, "value": 2.0])
            XCTAssertNotNil(container)
            XCTAssertEqual(container.value, 2.0)
        } catch { XCTFail() }
    }
    
    //    MARK: [Float]
    
    func testMandatoryFloatArray() {
        do {
            let container = try FloatArrayContainer(dictionary: ["ids": [1.0, 2.0, 3.0]])
            XCTAssertEqual(container.ids, [1.0, 2.0, 3.0])
        } catch {
            XCTFail()
        }
    }
    
    func testMandatoryFloatArrayNil() {
        do {
            _ = try FloatArrayContainer(dictionary: ["id": "1"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalFloatArrayNil() {
        do {
            let container = try FloatArrayContainer(dictionary: ["ids": [1.0, 2.0, 3.0]])
            XCTAssertNotNil(container)
            XCTAssertNil(container.values)
        } catch { XCTFail() }
    }
    
    func testInvalidFloatArray() {
        do {
            _ = try FloatArrayContainer(dictionary: ["ids": ["one", "two"]])
            XCTFail()
        } catch { }
    }
    
    func testInvalidArray() {
        do {
            _ = try FloatArrayContainer(dictionary: ["ids": "one"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalFloatArrayNotNil() {
        do {
            let container = try FloatArrayContainer(dictionary: ["ids": [1.0, 2.0, 3.0], "values": [4.0, 5.0, 6.0]])
            XCTAssertNotNil(container.values)
            XCTAssertEqual(container.values!, [4.0, 5.0, 6.0])
        } catch {
            XCTFail()
        }
    }
    
    func testFloatArrayCompatibleType() {
        do {
            let container = try FloatArrayContainer(dictionary: ["ids": ["1.0", "2.0", "3.0"]])
            XCTAssertEqual(container.ids, [1.0, 2.0, 3.0])
        } catch {
            XCTFail()
        }
    }
    
    func testChangeFloatArray() {
        do {
            let container = try FloatArrayContainer(dictionary: ["ids": [1.0, 2.0, 3.0], "options": [3.0, 4.0]])
            XCTAssertEqual(container.options, [3.0, 4.0])
        } catch {
            XCTFail()
        }
    }
}

class FloatContainer: AbstractModel {
    var id: Float = 0.0
    var option: Float?
    var value: Float = 1.0
    
    override func assign(value: Any?, forProperty property: String) throws {
        if property == "option" { option = value as? Float}
        else {
            try super.assign(value: value, forProperty: property)
        }
    }
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["id"].contains(property)
    }
}

class FloatArrayContainer: AbstractModel {
    var ids: [Float]!
    var values: [Float]?
    var options: [Float] = [1.0, 2.0]
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["ids"].contains(property)
    }
}
