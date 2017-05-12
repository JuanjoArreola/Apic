//
//  ApicTests.swift
//  ApicTests
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class MovieTests: XCTestCase {
    
    let dictionary = ["id": "348798", "name": "Mad Max: Fury Road", "year": 2015, "duration": 120, "releaseDate": "2015-05-14 00:00:00", "rating": 4.8, "country": ["Australia", "USA"], "format": "16:9",
        "director": ["name": "George Miller"], "cast": [["name": " Tom Hardy"], ["name": "Charlize Theron"]], "nominations": [["name": "Teen Choice Awards"]], "synopsis": ["text": "A woman rebels against a tyrannical ruler in post apocalyptic Australia in search for her homeland with the help of a group of female prisoners, a psychotic worshiper, and a drifter named Max"]] as [String : Any]
    
    override func setUp() {
        super.setUp()
        
        DefaultTypeResolver.shared.register(types: Director.self, Actor.self, MovieFormat.self, Nomination.self, Synopsis.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateMovie() {
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
            XCTAssertNotNil(movie.releaseDate)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testNSCoding() {
        do {
            let originalMovie = try Movie(dictionary: dictionary)
            let data = NSKeyedArchiver.archivedData(withRootObject: originalMovie)
            let movie = NSKeyedUnarchiver.unarchiveObject(with: data) as! Movie
            XCTAssertNotNil(movie)
            XCTAssertNotEqual(movie.duration, 0)
            XCTAssertNotNil(movie.director)
            XCTAssertFalse(movie.cast.isEmpty)
            XCTAssertFalse(movie.cast[0].name.isEmpty)
            XCTAssertNotNil(movie.nominations)
            XCTAssertFalse(movie.nominations!.isEmpty)
            XCTAssertNotNil(movie.synopsis)
            XCTAssertNotNil(movie.releaseDate)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    func testInvalidImplicitlyUnwrappedOptional() {
        let dictionary: [String : Any] = ["id": "348798", "name": "Mad Max: Fury Road", "duration": 120, "releaseDate": "2015-05-14T 00:00:00z",
            "director": ["names": "George Miller"], "cast": [["name": " Tom Hardy"], ["name": "Charlize Theron"]]]
        do {
            _ = try Movie(dictionary: dictionary)
            XCTFail()
        } catch {
            
        }
    }
    
}
