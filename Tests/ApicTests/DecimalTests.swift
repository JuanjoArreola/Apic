//
//  DecimalTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 1/23/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class DecimalTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMandatoryDecimal() {
        do {
            let container = try DecimalContainer(dictionary: ["price": 100.0])
            XCTAssertNotNil(container.price)
        } catch { XCTFail() }
    }
    
    func testMandatoryDecimalNil() {
        do {
            _ = try DecimalContainer(dictionary: [:])
            XCTFail()
        } catch { }
    }
    
    func testInvalidDecimal() {
        do {
            _ = try DecimalContainer(dictionary: ["price": "_0"])
            XCTFail()
        } catch { }
    }
    
    func testInvalidValue() {
        do {
            _ = try DecimalContainer(dictionary: ["price": Date()])
            XCTFail()
        } catch { }
    }
    
    func testOptionalDecimalNil() {
        do {
            let container = try DecimalContainer(dictionary: ["price": 100.0])
            XCTAssertNotNil(container)
            XCTAssertNil(container.tax)
        } catch { XCTFail() }
    }
    
    func testOptionalDecimalNotNil() {
        do {
            let container = try DecimalContainer(dictionary: ["price": 100.0, "tax": 20.0])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.tax)
        } catch { XCTFail() }
    }
    
    func testChangeDecimal() {
        do {
            let container = try DecimalContainer(dictionary: ["price": 100.0, "shipping": 16.0])
            XCTAssertNotNil(container)
            XCTAssertEqual(container.shipping, NSDecimalNumber(value: 16.0))
        } catch { XCTFail() }
    }
    
    func testDecimalCompatibleType() {
        do {
            let container = try DecimalContainer(dictionary: ["price": "100.0", "tax": 20, "shipping": true])
            XCTAssertNotNil(container)
            XCTAssertEqual(container.price, NSDecimalNumber(value: 100.0))
            XCTAssertEqual(container.tax, NSDecimalNumber(value: 20.0))
            XCTAssertEqual(container.shipping, NSDecimalNumber(value: 1.0))
        } catch { XCTFail() }
    }
    
    func testArrayOfDecimals() {
        do {
            let container = try DecimalContainer(dictionary: ["price": 100.0, "prices": [1.1, 2.2, 4.4]])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.prices)
            XCTAssertEqual(container.prices?.count, 3)
        } catch {
            XCTFail()
        }
    }
    
}

class DecimalContainer: AbstractModel {
    var price: NSDecimalNumber!
    var tax: NSDecimalNumber?
    var shipping = NSDecimalNumber(value: 8.0)
    
    var prices: [NSDecimalNumber]?
}
