//
//  SoftDictionaryTests.swift
//  Apic
//
//  Created by Juan Jose Arreola on 20/04/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class SoftDictionaryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSerialize() {
        let playlist = Playlist()
        playlist.name = "Favourites"
        playlist.songs = [Song(id: "1", name: "No one knows"), Song(id: "2", name: "Symmetry")]
        let dictionary = playlist.softDictionary
        XCTAssertEqual(dictionary.count, 2)
        XCTAssertNotNil(dictionary["songs"])
        XCTAssertTrue(dictionary["songs"]![0] is [String: AnyObject])
    }
    
}

class Playlist: AbstractModel {
    var id: String!
    var name: String!
    
    var songs: [Song]!
}

class Song: AbstractModel {
    var id: String!
    var name: String!
    
    convenience init(id: String, name: String) {
        self.init()
        self.id = id
        self.name = name
    }
}
