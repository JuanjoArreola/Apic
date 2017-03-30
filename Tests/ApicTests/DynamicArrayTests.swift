//
//  DynamicArrayTests.swift
//  Apic
//
//  Created by Juan Jose Arreola on 19/04/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class DynamicArrayTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDynamicArray() {
        do {
            let movie = try Moview(dictionary: ["name": "Mad Max", "awards": [
                ["type": "Oscar", "name": "Best Achievement in Film Editing", "edition": "LXXXVIII"],
                ["type": "GoldenGlobe", "name": "Best Motion Picture - Drama", "year": 2016]]])
            XCTAssertNotNil(movie)
            XCTAssertTrue(movie.awards[0] is Oscar)
            XCTAssertTrue(movie.awards[1] is GoldenGlobe)
        } catch {
            XCTFail()
            Log.error(error)
        }
    }
    
}

class Moview: AbstractModel {
    var name: String!
    var awards: [Award]!
}

class Award: AbstractModel, DynamicTypeModel {
    var name: String!
    
    override class func initialize() {
        super.initialize()
        
        DefaultTypeResolver.shared.register(type: Oscar.self, forName: "Oscar")
        DefaultTypeResolver.shared.register(type: GoldenGlobe.self, forName: "GoldenGlobe")
    }
    
    static var typeNameProperty: String {
        return "type"
    }
}

class Oscar: Award {
    var edition: String!
}

class GoldenGlobe: Award {
    var year: Int = 0
}
