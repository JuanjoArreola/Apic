//
//  DictionaryTests.swift
//  Apic
//
//  Created by Juan Jose Arreola on 07/02/17.
//  Copyright © 2017 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class DictionaryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStringDictionary() {
        do {
            let world = try World(dictionary: ["capitals": ["England": "London", "France": "Paris"], "countries": [:]])
            XCTAssertEqual(world.capitals.count, 2)
        } catch {
            Log.error(error)
            XCTFail()
        }
    }
    
    func testModelsDictionary() {
        do {
            let world = try World(dictionary: ["capitals": [:], "countries": ["England": ["capital": "London"], "France": ["capital": "Paris"]]])
            XCTAssertEqual(world.countries.count, 2)
        } catch {
            XCTFail()
        }
    }
    
}

class World: AbstractModel {
    var capitals: [String: String]!
    var countries: [String: Country]!
    
    override open class var resolver: TypeResolver? { return WorldResolver.shared }
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return true
    }
}

class Country: AbstractModel {
    var capital: String = ""
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return true
    }
}

fileprivate class WorldResolver: Resolver {
    
    static var shared = WorldResolver()
    
    fileprivate override func resolve(type: Any) -> Any? {
        return nil
    }
    
    fileprivate override func resolve(typeForName typeName: String) -> Any? {
        return nil
    }
    
    fileprivate override func resolveDictionary(type: Any) -> Any? {
        if type is ImplicitlyUnwrappedOptional<Dictionary<String, Country>>.Type { return Country.self }
        return nil
    }
}
