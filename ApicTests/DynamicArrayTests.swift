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


class Resolver: TypeResolver {
    
    static var sharedResolver = Resolver()
    
    func resolve(type: Any) -> Any? {
        if type is [Award]?.Type || type is Award?.Type || type is ImplicitlyUnwrappedOptional<[Award]>.Type { return Award.self }
        return nil
    }
    
    func resolve(typeForName typeName: String) -> Any? {
        if typeName == "Oscar" { return Oscar.self }
        if typeName == "GoldenGlobe" { return GoldenGlobe.self }
        return nil
    }
    
    public func resolveDictionary(type: Any) -> Any? {
        return nil
    }
}

class Moview: AbstractModel {
    var name: String!
    var awards: [Award]!
    
    override class var resolver: TypeResolver? { return Resolver.sharedResolver }
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return true
    }
}

class Award: AbstractModel, DynamicTypeModel {
    var name: String!
    
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
