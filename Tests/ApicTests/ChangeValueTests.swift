//
//  ChangeValueTests.swift
//  Apic
//
//  Created by Juan Jose Arreola on 07/02/17.
//  Copyright © 2017 Juanjo. All rights reserved.
//

import XCTest
import Apic

class ChangeValueTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        DefaultTypeResolver.shared.register(types: Playlist.self, Song.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testChangePropertyValue() {
        do {
            let playlist = try Playlist(dictionary: ["id": "1", "name": "Favourites", "songs": [["id": "1", "name": "No one knows"], ["id": "2", "name": "Symmetry"]]])
            try playlist.assign(rawValue: [["id": "7", "name": "Symmetry"]], toProperty: "songs")
            XCTAssertEqual(playlist.songs.count, 1)
            XCTAssertEqual(playlist.songs[0].id, "7")
        } catch {
            XCTFail()
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
