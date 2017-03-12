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
        let expectation: XCTestExpectation = self.expectation(description: "fetch success")
        let repository = StringStatusRepository()
        _ = repository.requestTest { (getSuccess) -> Void in
            do {
                let success = try getSuccess()
                XCTAssertTrue(success)
                expectation.fulfill()
            } catch {
                Log.error(error)
                XCTFail()
            }
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testBoolStatus() {
        stubWithResponse(["success": true])
        let expectation: XCTestExpectation = self.expectation(description: "fetch success")
        let repository = BoolStatusRepository()
        _ = repository.requestTest { (getSuccess) -> Void in
            do {
                let success = try getSuccess()
                XCTAssertTrue(success)
                expectation.fulfill()
            } catch {
                Log.error(error)
                XCTFail()
            }
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testStringStatusFail() {
        stubWithResponse(["status": "FAIL"])
        let expectation: XCTestExpectation = self.expectation(description: "fetch success")
        let repository = StringStatusRepository()
        _ = repository.requestTest { (getSuccess) -> Void in
            do {
                _ = try getSuccess()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testBoolStatusFail() {
        stubWithResponse(["success": false])
        let expectation: XCTestExpectation = self.expectation(description: "fetch success")
        let repository = BoolStatusRepository()
        _ = repository.requestTest { (getSuccess) -> Void in
            do {
                _ = try getSuccess()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func stubWithResponse(_ response: [String: Any]) {
        OHHTTPStubs.stubRequests(passingTest: { _ in return true }) {
            (request: URLRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: try! JSONSerialization.data(withJSONObject: response, options: []), statusCode:200, headers: ["Content-Type": "application/json"])
        }
    }
    
}

class StringStatusRepository: AbstractRepository<String> {
    init() {
        super.init(statusKey: "status", statusOk: "OK")
    }
    
    func requestTest(completion: @escaping (_ getSuccess: () throws -> Bool) -> Void) -> Request<Bool>? {
        return requestSuccess(method: .GET, url: "http://mywebservice.com?stringStatus", completion: completion)
    }
}

class BoolStatusRepository: AbstractRepository<Bool> {
    init() {
        super.init(statusKey: "success", statusOk: true)
    }
    
    func requestTest(completion: @escaping (_ getSuccess: () throws -> Bool) -> Void) -> Request<Bool>? {
        return requestSuccess(method: .GET, url: "http://mywebservice.com?booleanStatus", completion: completion)
    }
}
