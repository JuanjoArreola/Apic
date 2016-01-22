//
//  ApicTests.swift
//  ApicTests
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import UIKit
import XCTest
@testable import Apic

class ApicTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateMovie() {
        let dictionary = ["id": "348798", "name": "Mad Max: Fury Road", "year": 2015, "duration": 120, "releaseDate": "2015-05-14T 00:00:00z", "rating": 4.8,
            "country": ["Australia", "USA"],
            "director": ["name": "George Miller"], "cast": [["name": " Tom Hardy"], ["name": "Charlize Theron"]], "nominations": [["name": "Teen Choice Awards"]], "synopsis": ["text": "A woman rebels against a tyrannical ruler in post apocalyptic Australia in search for her homeland with the help of a group of female prisoners, a psychotic worshiper, and a drifter named Max"]]
        do {
            let movie = try Movie(dictionary: dictionary)
            XCTAssertNotNil(movie)
            XCTAssertNotEqual(movie.duration, 0)
            XCTAssertNotNil(movie.director)
            XCTAssertFalse(movie.cast.isEmpty)
            XCTAssertFalse(movie.cast[0].name.isEmpty)
            XCTAssertNotNil(movie.nominations)
            XCTAssertFalse(movie.nominations!.isEmpty)
            XCTAssertNotNil(movie.synopsis)
        } catch {
            Log.error(error)
        }
    }
    
    func testInvalidImplicitlyUnwrappedOptional() {
        let dictionary = ["id": "348798", "name": "Mad Max: Fury Road", "duration": 120, "releaseDate": "2015-05-14T 00:00:00z",
            "director": ["names": "George Miller"], "cast": [["name": " Tom Hardy"], ["name": "Charlize Theron"]]]
        do {
            try Movie(dictionary: dictionary)
            XCTFail()
        } catch {
            
        }
    }
    
}
