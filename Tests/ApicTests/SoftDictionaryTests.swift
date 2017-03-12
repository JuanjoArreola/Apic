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
        let dictionary = playlist.jsonValidDictionary()
        XCTAssertEqual(dictionary.count, 2)
        XCTAssertNotNil(dictionary["songs"])
        XCTAssertTrue(dictionary["songs"] is [[String: Any]])
    }
    
}

class Playlist: AbstractModel {
    var id: String!
    var name: String!
    
    var songs: [Song]!
    var created: Date?
    
    override open class var propertyDateFormats: [String: String] { return ["created": "y-MM-dd HH:mm:ss"] }
    
    override open class var resolver: TypeResolver? { return PlaylistResolver.shared }
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["id", "name", "songs"].contains(property)
    }
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

fileprivate class PlaylistResolver: Resolver {
    
    static var shared = PlaylistResolver()
    
    fileprivate override func resolve(type: Any) -> Any? {
        if type is ImplicitlyUnwrappedOptional<[Song]>.Type { return Song.self }
        return nil
    }
    
    fileprivate override func resolve(typeForName typeName: String) -> Any? {
        return nil
    }
}
