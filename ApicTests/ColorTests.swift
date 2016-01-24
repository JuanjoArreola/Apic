//
//  ColorTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 1/23/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class ColorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMandatoryColor() {
        do {
            let container = try ColorContainer(dictionary: ["main": "FFFFFF"])
            XCTAssertNotNil(container.main)
        } catch { XCTFail() }
    }
    
    func testMandatoryColorNil() {
        do {
            try ColorContainer(dictionary: [:])
            XCTFail()
        } catch { }
    }
    
    func testInvalidColor() {
        do {
            try ColorContainer(dictionary: ["main": "00"])
            XCTFail()
        } catch { }
    }
    
    func testInvalidValue() {
        do {
            try ColorContainer(dictionary: ["main": 255])
            XCTFail()
        } catch { }
    }
    
    func testOptionalColorNil() {
        do {
            let container = try ColorContainer(dictionary: ["main": "FFFFFF"])
            XCTAssertNotNil(container)
            XCTAssertNil(container.secondary)
        } catch { XCTFail() }
    }
    
    func testOptionalColorNotNil() {
        do {
            let container = try ColorContainer(dictionary: ["main": "FFFFFF", "secondary": "FF0000"])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.secondary)
        } catch { XCTFail() }
    }
    
    func testChangeColor() {
        do {
            let container = try ColorContainer(dictionary: ["main": "FFFFFF", "defaultColor": "FFFF0000"])
            XCTAssertNotNil(container)
            XCTAssertEqual(container.defaultColor, UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.0))
        } catch { XCTFail() }
    }
    
    func testCompatibleColorFormat() {
        do {
            let container = try ColorContainer(dictionary: ["main": "#FF00FF00"])
            XCTAssertNotNil(container)
            XCTAssertEqual(container.main, UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 0.0))
        } catch { XCTFail() }
    }
    
}

class ColorContainer: AbstractModel {
    var main: UIColor!
    var secondary: UIColor?
    var defaultColor = UIColor(white: 0.0, alpha: 1.0)
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return ["main"].contains(property)
    }
}