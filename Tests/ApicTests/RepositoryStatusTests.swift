//
//  RepositoryStatusTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 2/29/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
import Apic

class RepositoryStatusTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
//        OHHTTPStubs.removeAllStubs()
        
        super.tearDown()
    }
    
    func _testStringStatus() {
//        stubWithResponse(["status": "OK"])
        let expectation: XCTestExpectation = self.expectation(description: "fetch success")
        let repository = StringStatusRepository()
        _ = repository.requestTest { (getSuccess) -> Void in
            do {
                let success = try getSuccess()
                XCTAssertTrue(success)
                expectation.fulfill()
            } catch {
                print(error)
                XCTFail()
            }
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func _testBoolStatus() {
//        stubWithResponse(["success": true])
        let expectation: XCTestExpectation = self.expectation(description: "fetch success")
        let repository = BoolStatusRepository()
        _ = repository.requestTest { (getSuccess) -> Void in
            do {
                let success = try getSuccess()
                XCTAssertTrue(success)
                expectation.fulfill()
            } catch {
                print(error)
                XCTFail()
            }
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func _testStringStatusFail() {
//        stubWithResponse(["status": "FAIL"])
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
    
    func _testBoolStatusFail() {
//        stubWithResponse(["success": false])
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
    
//    func stubWithResponse(_ response: [String: Any]) {
//        OHHTTPStubs.stubRequests(passingTest: { _ in return true }) {
//            (request: URLRequest) -> OHHTTPStubsResponse in
//            return OHHTTPStubsResponse(data: try! JSONSerialization.data(withJSONObject: response, options: []), statusCode:200, headers: ["Content-Type": "application/json"])
//        }
//    }
    
}

class StringStatusRepository: AbstractRepository {
    
    init() {
        let parser = DefaultResponseParser<String>()
        parser.statusKey = "status"
        parser.statusOk = "OK"
        super.init(responseParser: parser)
    }
    
    func requestTest(completion: @escaping (_ getSuccess: () throws -> Bool) -> Void) -> Request<Bool>? {
        return requestSuccess(method: .GET, url: "http://mywebservice.com?stringStatus", completion: completion)
    }
}

class BoolStatusRepository: AbstractRepository {
    
    init() {
        let parser = DefaultResponseParser<Bool>()
        parser.statusKey = "status"
        parser.statusOk = true
        super.init(responseParser: parser)
    }
    
    func requestTest(completion: @escaping (_ getSuccess: () throws -> Bool) -> Void) -> Request<Bool>? {
        return requestSuccess(method: .GET, url: "http://mywebservice.com?booleanStatus", completion: completion)
    }
}
