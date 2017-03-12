//
//  UndefinedTypeTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 1/24/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class UndefinedTypeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLocationNil() {
        do {
            let container = try LocationContainer(dictionary: ["location": "19.0,-22.4"])
            XCTAssertNil(container.location)
        } catch { }
    }
    
    func testSelfAssignProperty() {
        do {
            let container = try LocationContainer(dictionary: ["previousLocation": "19.0,-22.4"])
            XCTAssertNotNil(container.previousLocation)
        } catch { }
    }
    
}

class LocationContainer: AbstractModel {
    var location: SimpleLocation!
    var previousLocation: SimpleLocation?
    
    override func assign(undefinedValue: Any, forProperty property: String) throws {
        if property == "previousLocation" {
            let location = SimpleLocation()
            location.lat = 19.0
            location.long = -22.4
            previousLocation = location
        } else {
            try super.assign(undefinedValue: undefinedValue, forProperty: property)
        }
    }
}

class SimpleLocation {
    var lat: Double = 0.0
    var long: Double = 0.0
}
