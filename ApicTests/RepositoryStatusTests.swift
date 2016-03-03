//
//  RepositoryStatusTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 2/29/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
import Apic
import OHHTTPStubs

class RepositoryStatusTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        
        super.tearDown()
    }
    
    func testStringStatus() {
        stubWithResponse(["status": "OK"])
        let expectation: XCTestExpectation = expectationWithDescription("fetch success")
        let repository = StringStatusRepository()
        repository.requestTest { (getSuccess) -> Void in
            do {
                try getSuccess()
                expectation.fulfill()
            } catch {
                Log.error(error)
                XCTFail()
            }
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testBoolStatus() {
        stubWithResponse(["status": true])
        let expectation: XCTestExpectation = expectationWithDescription("fetch success")
        let repository = BoolStatusRepository()
        repository.requestTest { (getSuccess) -> Void in
            do {
                try getSuccess()
                expectation.fulfill()
            } catch {
                Log.error(error)
                XCTFail()
            }
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func stubWithResponse(response: [String: AnyObject]) {
        OHHTTPStubs.stubRequestsPassingTest({ _ in return true }) {
            (request: NSURLRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: try! NSJSONSerialization.dataWithJSONObject(response, options: []), statusCode:200, headers: ["Content-Type": "application/json"])
        }
    }
    
}

class StringStatusRepository: AbstractRepository<String> {
    init() {
        super.init(statusKey: "status", statusOk: "OK")
    }
    
    func requestTest(completion: (getSuccess: () throws -> Bool) -> Void) -> Request<Bool>? {
        return requestSuccess(method: .GET, url: "http://mywebservice.com?stringStatus", completion: completion)
    }
}

class BoolStatusRepository: AbstractRepository<Bool> {
    init() {
        super.init(statusKey: "status", statusOk: true)
    }
    
    func requestTest(completion: (getSuccess: () throws -> Bool) -> Void) -> Request<Bool>? {
        return requestSuccess(method: .GET, url: "http://mywebservice.com?booleanStatus", completion: completion)
    }
}
