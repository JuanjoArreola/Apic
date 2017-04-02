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
        
        DefaultTypeResolver.shared.register(types: Country.self)
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
            let world = try World(dictionary: ["capitals": [:], "countries": ["england": ["name": "England", "capital": "London"], "france": ["name": "France", "capital": "Paris"]]])
            XCTAssertEqual(world.countries.count, 2)
        } catch {
            XCTFail()
        }
    }
    
}

class World: AbstractModel {
    var capitals: [String: String]!
    var countries: [String: Country]!
}

class Country: AbstractModel {
    var capital: String = ""
    var name: String = ""
}
