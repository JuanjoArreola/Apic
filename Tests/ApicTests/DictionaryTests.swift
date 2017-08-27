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
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}

class World: Codable {
    var capitals: [String: String]!
    var countries: [String: Country]!
}

class Country: Codable {
    var capital: String = ""
    var name: String = ""
}
