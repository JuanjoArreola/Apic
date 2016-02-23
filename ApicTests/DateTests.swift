//
//  DateTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 1/23/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class DateTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    YYYY-MM-dd'T' HH:mm:ssZ
    func testMandatoryDate() {
        do {
            let container = try DateContainer(dictionary: ["created": "2016-01-23 18:30:00Z"])
            XCTAssertNotNil(container.created)
        } catch { XCTFail() }
    }
    
    func testMandatoryDateNil() {
        do {
            try DateContainer(dictionary: [:])
            XCTFail()
        } catch { }
    }
    
    func testInvalidDate() {
        do {
            try DateContainer(dictionary: ["created": "2016-01-23_18:30:00Z"])
            XCTFail()
        } catch { }
    }
    
    func testInvalidValue() {
        do {
            try DateContainer(dictionary: ["created": 1])
            XCTFail()
        } catch { }
    }
    
    func testOptionalDateNil() {
        do {
            let container = try DateContainer(dictionary: ["created": "2016-01-23 18:30:00Z"])
            XCTAssertNotNil(container)
            XCTAssertNil(container.lastEdit)
        } catch { XCTFail() }
    }
    
    func testOptionalDateNotNil() {
        do {
            let container = try DateContainer(dictionary: ["created": "2016-01-23 18:30:00Z", "lastEdit": "2016-01-23 18:40:00Z"])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.lastEdit)
        } catch { XCTFail() }
    }
    
    func testChangeDate() {
        do {
            let container = try DateContainer(dictionary: ["created": "2016-01-23 18:30:00Z", "lastAccess": "2016-01-23 18:40:00Z"])
            XCTAssertNotNil(container)
            XCTAssertNotEqual(container.lastAccess, NSDate(timeIntervalSince1970: 0))
        } catch { XCTFail() }
    }
    
}

class DateContainer: AbstractModel {
    var created: NSDate!
    var lastEdit: NSDate?
    var lastAccess: NSDate = NSDate(timeIntervalSince1970: 0)
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return ["created"].contains(property)
    }
}
