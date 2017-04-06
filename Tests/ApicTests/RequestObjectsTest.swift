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
        let expectation: XCTestExpectation = self.expectation(description: "fetch list")
        
        let repository = GistsRepository()
        _ = repository.requestGists(ofUser: "JuanjoArreola") { (getGists) -> Void in
            do {
                let gists = try getGists()
                XCTAssertGreaterThan(gists.count, 0)
                expectation.fulfill()
            } catch {
                Log.error(error)
                XCTFail()
            }
        }
        waitForExpectations(timeout: 60.0, handler: nil)
    }
    
    func testGetInnerList() {
        let expectation: XCTestExpectation = self.expectation(description: "fetch list")
        
        let repository = HistoryRepository()
        _ = repository.requestHistoryOfGist("30f7b1a56a61c71631a6") { getHistory in
            do {
                _ = try getHistory()
                expectation.fulfill()
            } catch {
                Log.error(error)
                XCTFail()
            }
        }
        waitForExpectations(timeout: 60.0, handler: nil)
    }
    
    func testWrongList() {
        let expectation: XCTestExpectation = self.expectation(description: "fetch list")
        
        let repository = WrongGistsRepository()
        _ = repository.requestGists(ofUser: "JuanjoArreola") { (getGists) -> Void in
            do {
                _ = try getGists()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 60.0, handler: nil)
    }
    
    func testWrongInnerList() {
        let expectation: XCTestExpectation = self.expectation(description: "fetch list")
        
        let repository = WrongHistoryRepository()
        _ = repository.requestHistory(ofGist: "30f7b1a56a61c71631a6") { getHistory in
            do {
                _ = try getHistory()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 60.0, handler: nil)
    }

}


class GistsRepository: AbstractRepository {
    
    init() {
        let parser = DefaultResponseParser<String>()
        super.init(responseParser: parser)
    }
    
    func requestGists(ofUser user: String, completion: @escaping (_ getGists: () throws -> [Gist]) -> Void) -> Request<[Gist]>? {
        return requestObjects(method: .GET, url: "https://api.github.com/users/\(user)/gists", completion: completion)
    }
}

class WrongGistsRepository: AbstractRepository {
    
    init() {
        let parser = DefaultResponseParser<String>()
        parser.objectsKey = "gists"
        super.init(responseParser: parser)
    }
    
    func requestGists(ofUser user: String, completion: @escaping (_ getGists: () throws -> [Gist]) -> Void) -> Request<[Gist]>? {
        return requestObjects(method: .GET, url: "https://api.github.com/users/\(user)/gists", completion: completion)
    }
}

class HistoryRepository: AbstractRepository {
    
    init() {
        let parser = DefaultResponseParser<String>()
        parser.objectsKey = "history"
        super.init(responseParser: parser)
    }
    
    func requestHistoryOfGist(_ gist: String, completion: @escaping (_ getHistory: () throws -> [HistoryEntry]) -> Void) -> Request<[HistoryEntry]>? {
        return requestObjects(method: .GET, url: "https://api.github.com/gists/\(gist)", completion: completion)
    }
}

class WrongHistoryRepository: AbstractRepository {
    
    init() {
        let parser = DefaultResponseParser<String>()
        super.init(responseParser: parser)
    }
    
    func requestHistory(ofGist gist: String, completion: @escaping (_ getHistory: () throws -> [HistoryEntry]) -> Void) -> Request<[HistoryEntry]>? {
        return requestObjects(method: .GET, url: "https://api.github.com/gists/\(gist)", completion: completion)
    }
}

class Gist: AbstractModel {
    var id: String!
    var url: URL!
}

class HistoryEntry: AbstractModel {
    var version: String!
    var url: URL!
}
