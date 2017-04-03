//
//  JSONValidTests.swift
//  Apic
//
//  Created by Juan Jose Arreola on 07/02/17.
//  Copyright © 2017 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class JSONValidTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSerializeJSON() {
        let playlist = Playlist()
        playlist.name = "Favourites"
        playlist.songs = [Song(id: "1", name: "No one knows"), Song(id: "2", name: "Symmetry")]
        let dictionary = try! playlist.jsonValidDictionary()
        XCTAssertEqual(dictionary.count, 2)
        XCTAssertNotNil(dictionary["songs"])
        XCTAssertTrue(dictionary["songs"] is [[String: Any]])
    }
    
    func testSerializeStrictJSON() {
        do {
            let playlist = Playlist()
            playlist.created = Date()
            playlist.id = "1"
            playlist.name = "Favourites"
            playlist.songs = [Song(id: "1", name: "No one knows"), Song(id: "2", name: "Symmetry")]
            let dictionary = try playlist.jsonValidDictionary(strict: true)
            XCTAssertEqual(dictionary.count, 4)
            XCTAssertNotNil(dictionary["songs"])
            XCTAssertNotNil(dictionary["created"])
            XCTAssertTrue(dictionary["songs"] is [[String: Any]])
        } catch {
            XCTFail()
        }
    }
    
    func testInvalidValue() {
        do {
            let playlist = Playlist()
            playlist.name = "Favourites"
            playlist.songs = [Song(id: "1", name: "No one knows"), Song(id: "2", name: "Symmetry")]
            let _ = try playlist.jsonValidDictionary(strict: true)
            XCTFail()
        } catch ModelError.serializationError(let property, _) {
            XCTAssertEqual(property, "id")
        } catch {
            Log.error(error)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
