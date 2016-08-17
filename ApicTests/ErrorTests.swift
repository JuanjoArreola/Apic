//
//  ErrorTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 8/16/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
import Apic
import OHHTTPStubs

class ErrorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        
        super.tearDown()
    }
    
    func testCustomError() {
        stubWithResponse(["status": "FAIL", "error": ["code": 401, "message": "Authorization error", "solution": "Login first"]])
        let expectation: XCTestExpectation = expectationWithDescription("request")
        let repository = ModelErrorRepository()
        repository.requestThatFails { (getSuccess) in
            do {
                _ = try getSuccess()
                XCTFail()
            } catch let httpError as HttpError {
                XCTAssertNotNil(httpError.solution)
                expectation.fulfill()
            } catch {
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

class HttpError: AbstractErrorModel {
    var code: Int = 0
    var message: String!
    var solution: String!
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return true
    }
}

class ModelErrorRepository: AbstractCustomErrorRepository<String, HttpError> {
    init() {
        super.init(objectKey: "object", objectsKey: "objects", statusKey: "status", statusOk: "OK", errorKey: "error")
    }
    
    func requestThatFails(completion: (getSuccess: () throws -> Bool) -> Void) -> Request<Bool> {
        return requestSuccess(method: .GET, url: "http://mywebservice.com?stringStatus", completion: completion)
    }
}