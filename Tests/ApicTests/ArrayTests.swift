//
//  ArrayTests.swift
//  Apic
//
//  Created by Juan Jose Arreola on 10/02/17.
//  Copyright © 2017 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class ArrayTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testArrayOfModels() {
        do {
            let array = try Country.initFrom(list: [["name": "England", "capital": "London"], ["name": "France", "capital": "Paris"]])
            XCTAssertGreaterThan(array.count, 0)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
}
