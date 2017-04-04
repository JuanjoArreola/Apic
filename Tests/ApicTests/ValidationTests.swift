//
//  ValidationTests.swift
//  Apic
//
//  Created by Juan Jose Arreola on 03/04/17.
//
//

import XCTest
import Apic

class ValidationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInvalidValue() {
        do {
            let _ = try RegisteredUser(dictionary: ["name": "Joe"])
            XCTFail()
        } catch {
            XCTAssertTrue(error is ModelError)
        }
    }
    
}

class RegisteredUser: AbstractModel {
    var id: String = ""
    var name: String = ""
    
    var latitude: Double = 0
    var longitude: Double = 0
    
    override func validate() throws {
        try validateId()
        try validateLocation()
    }
    
    func validateId() throws {
        if id.isEmpty {
            throw ModelError.validationError(reason: "id empty", type: type(of: self))
        }
    }
    
    func validateLocation() throws {
        if latitude == 0 && longitude == 0 {
            throw ModelError.validationError(reason: "invalid location", type: type(of: self))
        }
    }
}
