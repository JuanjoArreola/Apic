//
//  RequestObjectsTest.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 2/6/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
import Apic

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
        
        let repository = GistsRepository()
        repository.requestGistsOfUser("JuanjoArreola") { (getGists) -> Void in
            do {
                let gists = try getGists()
                XCTAssertGreaterThan(gists.count, 0)
                expectation.fulfill()
            } catch {
                Log.error(error)
                XCTFail()
            }
        }
        waitForExpectationsWithTimeout(60.0, handler: nil)
    }
    
    func testGetInnerList() {
        let expectation: XCTestExpectation = expectationWithDescription("fetch list")
        
        let repository = HistoryRepository()
        repository.requestHistoryOfGist("30f7b1a56a61c71631a6") { getHistory in
            do {
                try getHistory()
                expectation.fulfill()
            } catch {
                Log.error(error)
                XCTFail()
            }
        }
        waitForExpectationsWithTimeout(60.0, handler: nil)
    }
    
    func testWrongList() {
        let expectation: XCTestExpectation = expectationWithDescription("fetch list")
        
        let repository = WrongGistsRepository()
        repository.requestGistsOfUser("JuanjoArreola") { (getGists) -> Void in
            do {
                try getGists()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(60.0, handler: nil)
    }
    
    func testWrongInnerList() {
        let expectation: XCTestExpectation = expectationWithDescription("fetch list")
        
        let repository = WrongHistoryRepository()
        repository.requestHistoryOfGist("30f7b1a56a61c71631a6") { getHistory in
            do {
                try getHistory()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(60.0, handler: nil)
    }

}


class GistsRepository: AbstractRepository<String> {
    
    init() { super.init() }
    
    func requestGistsOfUser(user: String, completion: (getGists: () throws -> [Gist]) -> Void) -> Request<[Gist]>? {
        return requestObjects(.GET, url: "https://api.github.com/users/\(user)/gists", completion: completion)
    }
}

class WrongGistsRepository: AbstractRepository<String> {
    
    init() {
        super.init(objectsKey: "gists")
    }
    
    func requestGistsOfUser(user: String, completion: (getGists: () throws -> [Gist]) -> Void) -> Request<[Gist]>? {
        return requestObjects(.GET, url: "https://api.github.com/users/\(user)/gists", completion: completion)
    }
}

class HistoryRepository: AbstractRepository<String> {
    
    init() {
        super.init(objectsKey: "history")
    }
    
    func requestHistoryOfGist(gist: String, completion: (getHistory: () throws -> [HistoryEntry]) -> Void) -> Request<[HistoryEntry]>? {
        return requestObjects(.GET, url: "https://api.github.com/gists/\(gist)", completion: completion)
    }
}

class WrongHistoryRepository: AbstractRepository<String> {
    
    init() { super.init() }
    
    func requestHistoryOfGist(gist: String, completion: (getHistory: () throws -> [HistoryEntry]) -> Void) -> Request<[HistoryEntry]>? {
        return requestObjects(.GET, url: "https://api.github.com/gists/\(gist)", completion: completion)
    }
}

class Gist: AbstractModel {
    var id: String!
    var url: NSURL!
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return true
    }
}

class HistoryEntry: AbstractModel {
    var version: String!
    var url: NSURL!
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return true
    }
}
