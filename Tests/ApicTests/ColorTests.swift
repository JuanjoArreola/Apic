//
//  ColorTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 1/23/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

#if os(OSX)
    typealias Color = NSColor
#else
    typealias Color = UIColor
#endif

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
            _ = try ColorContainer(dictionary: [:])
            XCTFail()
        } catch { }
    }
    
    func testInvalidColor() {
        do {
            _ = try ColorContainer(dictionary: ["main": "00"])
            XCTFail()
        } catch { }
    }
    
    func testInvalidValue() {
        do {
            _ = try ColorContainer(dictionary: ["main": 255])
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
            XCTAssertEqual(container.defaultColor, Color(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.0))
        } catch { XCTFail() }
    }
    
    func testCompatibleColorFormat() {
        do {
            let container = try ColorContainer(dictionary: ["main": "#FF00FF00"])
            XCTAssertNotNil(container)
            XCTAssertEqual(container.main, Color(red: 1.0, green: 0.0, blue: 1.0, alpha: 0.0))
        } catch { XCTFail() }
    }
    
}

class ColorContainer: AbstractModel {
    var main: Color!
    var secondary: Color?
    var defaultColor = Color(white: 0.0, alpha: 1.0)
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["main"].contains(property)
    }
}