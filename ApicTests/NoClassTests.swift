//
//  NoClassTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 1/23/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class NoClassTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMandatoryProperty() {
        do {
            let container = try StateContainer(dictionary: ["state": "playing"])
            XCTAssertNotNil(container)
            XCTAssertEqual(container.state, State.Playing)
        } catch {
            XCTFail()
        }
    }
    
    func testMandatoryPropertyNil() {
        do {
            try StateContainer(dictionary: ["nextState": "playing"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalPropertyNil() {
        do {
            let container = try StateContainer(dictionary: ["state": "playing"])
            XCTAssertNotNil(container)
            XCTAssertNil(container.nextState)
        } catch {
            XCTFail()
        }
    }
    
    func testOptionalPropertyNotNil() {
        do {
            let container = try StateContainer(dictionary: ["state": "playing", "nextState": "paused"])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.nextState)
        } catch {
            XCTFail()
        }
    }
    
    func testInvalidValue() {
        do {
            try StateContainer(dictionary: ["state": 1])
            XCTFail()
        } catch { }
    }
    
    func testMandatoryStruct() {
        do {
            let container = try PositionContainer(dictionary: ["location": ["latitude": 19.0, "longitude": -18.1]])
            XCTAssertNotNil(container)
        } catch { }
    }
    
}

enum State: StringInitializable {
    case Playing
    case Paused
    
    init?(rawValue: String) {
        if rawValue == "playing" {
            self = .Playing
        } else if rawValue == "paused" {
            self = .Paused
        } else {
            return nil
        }
    }
}

class StateResolver: TypeResolver {
    
    static let sharedInstance = StateResolver()
    
    func resolveType(type: Any) -> Any? {
        if type is State?.Type {
            return State.self
        } else if type is Location?.Type {
            return Location.self
        }
        return nil
    }
}

class StateContainer: AbstractModel {
    override class var resolver: TypeResolver { return StateResolver.sharedInstance }
    
    var state: State!
    var nextState: State?
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return ["state"].contains(property)
    }
    
    override func assignInstance(instance: Any, forProperty property: String) throws {
        if property == "state" {
            state = instance as! State
        } else if property == "nextState" {
            nextState = instance as? State
        } else {
            try super.assignInstance(instance, forProperty: property)
        }
    }
}

class PositionContainer: AbstractModel {
    override class var resolver: TypeResolver { return StateResolver.sharedInstance }
    
    var location: Location!
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return ["location"].contains(property)
    }
    
    override func assignInstance(instance: Any, forProperty property: String) throws {
        if property == "location" {
            location = instance as! Location
        } else {
            try super.assignInstance(instance, forProperty: property)
        }
    }
}

struct Location: InitializableWithDictionary {
    var latitude: Double
    var longitude: Double
    
    init(dictionary: [String : AnyObject]) throws {
        guard let latitude = dictionary["latitude"] as? Double else {
            throw ModelError.SourceValueError(property: "latitude")
        }
        guard let longitude = dictionary["longitude"] as? Double else {
            throw ModelError.SourceValueError(property: "longitude")
        }
        self.latitude = latitude
        self.longitude = longitude
    }
}