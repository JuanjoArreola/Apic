//
//  ErrorTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 8/16/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
import Apic
import AsyncRequest

class ErrorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
//        OHHTTPStubs.removeAllStubs()
        
        super.tearDown()
    }
    
    func _testCustomError() {
//        stub(withResponse: ["status": "FAIL", "error": ["code": 401, "message": "Authorization error", "solution": "Login first"]])
        let expectation: XCTestExpectation = self.expectation(description: "error")
        let repository = ModelErrorRepository()
        _ = repository.requestThatFails { (getSuccess) in
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
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
//    func stub(withResponse response: [String: Any]) {
//        OHHTTPStubs.stubRequests(passingTest: { _ in return true }) {
//            (request: URLRequest) -> OHHTTPStubsResponse in
//            return OHHTTPStubsResponse(data: try! JSONSerialization.data(withJSONObject: response, options: []), statusCode:200, headers: ["Content-Type": "application/json"])
//        }
//    }
    
}

class HttpError: AbstractErrorModel {
    var code: Int = 0
    var message: String!
    var solution: String!
}

class ModelErrorRepository: AbstractRepository {
    
    init() {
        let configuration = CustomErrorResponseParser<String, HttpError>()
        configuration.objectKey = "object"
        configuration.objectsKey = "objects"
        configuration.statusKey = "status"
        configuration.statusOk = "OK"
        configuration.errorKey = "error"
        super.init(responseParser: configuration)
    }
    
    func requestThatFails(_ completion: @escaping (_ getSuccess: () throws -> Bool) -> Void) -> Request<Bool> {
        return requestSuccess(method: .GET, url: "http://mywebservice.com?stringStatus", completion: completion)
    }
}
