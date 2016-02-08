//
//  RequestObjectsTest.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 2/6/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic
import Alamofire

class RequestObjectsTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetList() {
        let expectation: XCTestExpectation = expectationWithDescription("fetch list")
        
        let repository = AlbumRepository()
        repository.getAlbums { (getAlbums) -> Void in
            do {
                let albums = try getAlbums()
                XCTAssertGreaterThan(albums.count, 0)
                expectation.fulfill()
            } catch {
                Log.error(error)
                XCTFail()
            }
        }
        waitForExpectationsWithTimeout(300.0, handler: nil)
    }

}


class AlbumRepository: AbstractRepository {
    
    func getAlbums(completion: (getAlbums: () throws -> [Album]) -> Void) -> Request? {
        return requestObjects(.GET, url: "http://jsonplaceholder.typicode.com/photos", completion: completion)
    }
}

class Album: AbstractModel {
    var albumId: Int!
    var id: Int!
    var title: String!
    var url: String!
    var thumbnailUrl: String!
    
    override func assignValue(value: AnyObject, forProperty property: String) throws {
        switch property {
        case "albumId":
            albumId = value as! Int
        case "id":
            id = value as! Int
        default:
            try super.assignValue(value, forProperty: property)
        }
    }
}