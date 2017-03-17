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
            let container = try StateContainer(dictionary: ["state": "playing", "mediaType": 1])
            XCTAssertNotNil(container)
            XCTAssertEqual(container.state, State.playing)
            XCTAssertEqual(container.mediaType, MediaType.video)
        } catch {
            XCTFail()
            Log.error(error)
        }
    }
    
    func testMandatoryPropertyNil() {
        do {
            _ = try StateContainer(dictionary: ["nextState": "playing"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalPropertyNil() {
        do {
            let container = try StateContainer(dictionary: ["state": "playing", "mediaType": 1])
            XCTAssertNotNil(container)
            XCTAssertNil(container.nextState)
        } catch {
            XCTFail()
        }
    }
    
    func testOptionalPropertyNotNil() {
        do {
            let container = try StateContainer(dictionary: ["state": "playing", "nextState": "paused", "mediaType": 1])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.nextState)
        } catch {
            XCTFail()
        }
    }
    
    func testInvalidValue() {
        do {
            _ = try StateContainer(dictionary: ["state": 1])
            XCTFail()
        } catch { }
    }
    
    func testMandatoryStruct() {
        do {
            let container = try PositionContainer(dictionary: ["location": ["latitude": 19.0, "longitude": -18.1]])
            XCTAssertNotNil(container)
        } catch {
            XCTFail()
        }
    }
    
}

enum State: StringInitializable {
    case playing
    case paused
    
    init?(rawValue: String) {
        if rawValue == "playing" {
            self = .playing
        } else if rawValue == "paused" {
            self = .paused
        } else {
            return nil
        }
    }
}

enum MediaType: IntInitializable {
    case audio
    case video
    
    init?(rawValue: Int) {
        if rawValue == 0 {
            self = .audio
        } else if rawValue == 1 {
            self = .video
        } else {
            return nil
        }
    }
}

class StateContainer: AbstractModel {
    
    open override class func initialize() {
        super.initialize()
        
        DefaultTypeResolver.shared.register(type: State.self)
        DefaultTypeResolver.shared.register(type: MediaType.self)
    }
    
    var state: State!
    var nextState: State?
    var mediaType: MediaType!
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["state", "mediaType"].contains(property)
    }
    
    override func assign(value: Any, forProperty property: String) throws {
        if property == "state" {
            state = value as! State
        } else if property == "mediaType" {
            mediaType = value as! MediaType
        } else if property == "nextState" {
            nextState = value as? State
        } else {
            try super.assign(value: value, forProperty: property)
        }
    }
}

class PositionContainer: AbstractModel {
    
    open override class func initialize() {
        super.initialize()
        
        DefaultTypeResolver.shared.register(type: Location.self)
    }
    
    var location: Location!
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["location"].contains(property)
    }
    
    override func assign(value: Any, forProperty property: String) throws {
        if property == "location" {
            location = value as! Location
        } else {
            try super.assign(value: value, forProperty: property)
        }
    }
}

struct Location: InitializableWithDictionary {
    var latitude: Double
    var longitude: Double
    
    init(dictionary: [String : Any]) throws {
        guard let latitude = dictionary["latitude"] as? Double else {
            throw ModelError.sourceValueError(property: "latitude", model: Location.self, value: String(describing: dictionary["latitude"]))
        }
        guard let longitude = dictionary["longitude"] as? Double else {
            throw ModelError.sourceValueError(property: "longitude", model: Location.self, value: String(describing: dictionary["longitude"]))
        }
        self.latitude = latitude
        self.longitude = longitude
    }
}
