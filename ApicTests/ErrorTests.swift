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
        stubWithResponse(["status": "FAIL", "error": ["code": 404, "message": "Authorization error", "solution": "Login first"]])
        let expectation: XCTestExpectation = expectationWithDescription("request")
        let repository = BoolStatusRepository()
    }
    
    func stubWithResponse(response: [String: AnyObject]) {
        OHHTTPStubs.stubRequestsPassingTest({ _ in return true }) {
            (request: NSURLRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: try! NSJSONSerialization.dataWithJSONObject(response, options: []), statusCode:200, headers: ["Content-Type": "application/json"])
        }
    }
    
}

class CustomError: AbstractErrorModel {
    
}

class ModelErrorRepository: AbstractCustomErrorRepository<String, CustomError> {
    
}