//
//  InheritanceTest.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 2/1/17.
//  Copyright © 2017 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class InheritanceTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNSCoding() {
        do {
            let figure = try Triangle(dictionary: ["sides": 3, "color": "blue"])
            let data = NSKeyedArchiver.archivedData(withRootObject: figure)
            let triangle = NSKeyedUnarchiver.unarchiveObject(with: data) as? Triangle
            XCTAssertNotNil(triangle)
            XCTAssertEqual(triangle!.sides, 3)
            XCTAssertEqual(triangle!.color, "blue")
        } catch {
            XCTFail()
        }
    }
}

class GeometricFigure: AbstractModel, DynamicTypeModel {
    var sides: Int = 0
    
    static var typeNameProperty: String { return "type" }
}

class Triangle: GeometricFigure {
    var color: String = ""
}

class Rectangle: GeometricFigure {
    
}
