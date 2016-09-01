//
//  StringTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 1/22/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class StringTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMandatoryString() {
        do {
            let container = try StringContainer(dictionary: ["id": "1"])
            XCTAssertNotNil(container.id)
        } catch {
            Log.error(error)
            XCTFail()
        }
    }
    
    func testMandatoryStringNil() {
        do {
            _ = try StringContainer(dictionary: ["name": "1"])
            XCTFail()
        } catch { }
    }
    
    func testInvalidString() {
        do {
            _ = try StringContainer(dictionary: ["id": 1, "name": "1"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalStringNil() {
        do {
            let container = try StringContainer(dictionary: ["id": "1"])
            XCTAssertNotNil(container)
            XCTAssertNil(container.name)
        } catch { XCTFail() }
    }
    
    func testOptionalStringNotNil() {
        do {
            let container = try StringContainer(dictionary: ["id": "1", "name": "one"])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.name)
        } catch { XCTFail() }
    }
    
    func testChangeString() {
        do {
            let container = try StringContainer(dictionary: ["id": "1", "value": "one"])
            XCTAssertNotNil(container)
            XCTAssertEqual(container.value, "one")
        } catch { XCTFail() }
    }
    
    func testIgnoreString() {
        do {
            let container = try StringContainer(dictionary: ["id": "1", "ignored": "two"])
            XCTAssertNotNil(container)
            XCTAssertEqual(container.ignored, "2")
        } catch { XCTFail() }
    }
    
    func testDescriptionString() {
        do {
            let container = try StringContainer(dictionary: ["id": "1", "description": "1 - One"])
            XCTAssertNotNil(container)
            XCTAssertEqual(container.description, "1 - One")
        } catch { XCTFail() }
    }
    
//    MARK: [String]
    
    func testMandatoryStringArray() {
        do {
            let container = try StringArrayContainer(dictionary: ["ids": ["1", "2", "3"]])
            XCTAssertNotNil(container.ids)
        } catch {
            Log.error(error)
            XCTFail()
        }
    }
    
    func testMandatoryStringArrayNil() {
        do {
            _ = try StringArrayContainer(dictionary: ["id": "1"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalStringArrayNil() {
        do {
            let container = try StringArrayContainer(dictionary: ["ids": ["1", "2", "3"]])
            XCTAssertNotNil(container)
            XCTAssertNil(container.names)
        } catch { XCTFail() }
    }
    
    func testInvalidStringArray() {
        do {
            _ = try StringArrayContainer(dictionary: ["ids": ["1", 2, 3]])
            XCTFail()
        } catch { }
    }
    
    func testOptionalStringArrayNotNil() {
        do {
            let container = try StringArrayContainer(dictionary: ["ids": ["1", "2", "3"], "names": ["one", "two"]])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.names)
        } catch { XCTFail() }
    }
}

class StringContainer: AbstractModel {
    var id: String!
    var name: String?
    var value: String = "1"
    var ignored: String = "2"
    
    var _description: String! = ""
    override var description: String { return _description }

    override class var ignoredProperties: [String] { return ["ignored"] }
    
    override class var descriptionProperty: String { return "_description" }
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["id", "ignored"].contains(property)
    }
}

class StringArrayContainer: AbstractModel {
    var ids: [String]!
    var names: [String]?
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["ids"].contains(property)
    }
}
