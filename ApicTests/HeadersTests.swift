//
//  HeadersTests.swift
//  Apic
//
//  Created by Juan Jose Arreola on 04/03/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
import Apic
import OHHTTPStubs

class HeadersTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExpectHeader() {
        stubWithResponse(["status": "OK"], expectingHeader: "Authorization", withValue: "myId")
        let expectation: XCTestExpectation = expectationWithDescription("fetch success")
        let repository = WithHeaderRepository()
        repository.requestTest("myId") { (getSuccess) -> Void in
            do {
                let success = try getSuccess()
                XCTAssertTrue(success)
                expectation.fulfill()
            } catch {
                Log.error(error)
                XCTFail()
            }
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testExpectWrongHeaderValue() {
        stubWithResponse(["status": "OK"], expectingHeader: "Authorization", withValue: "myId")
        let expectation: XCTestExpectation = expectationWithDescription("fetch success")
        let repository = WithHeaderRepository()
        repository.requestTest("otherId") { (getSuccess) -> Void in
            do {
                _ = try getSuccess()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    private func stubWithResponse(response: [String: AnyObject], expectingHeader header: String, withValue value: String) {
        OHHTTPStubs.stubRequestsPassingTest({ _ in return true }) {
            (request: NSURLRequest) -> OHHTTPStubsResponse in
            guard let headers = request.allHTTPHeaderFields else {
                return self.responseError()
            }
            guard let headerValue = headers[header] else {
                return self.responseError()
            }
            if headerValue == value {
                return OHHTTPStubsResponse(data: self.jsonWithDictionary(response), statusCode:200, headers: ["Content-Type": "application/json"])
            }
            return self.responseError()
        }
    }
    
    private func responseError() -> OHHTTPStubsResponse {
        return OHHTTPStubsResponse(data: self.jsonWithDictionary(["status": "Fail"]), statusCode:200, headers: ["Content-Type": "application/json"])
    }
    
    private func jsonWithDictionary(dictionary: [String: AnyObject]) -> NSData {
        return try! NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
    }
    
}

class WithHeaderRepository: AbstractRepository<String> {
    init() {
        super.init(statusKey: "status", statusOk: "OK")
    }
    
    func requestTest(token: String, completion: (getSuccess: () throws -> Bool) -> Void) -> Request<Bool>? {
        return requestSuccess(method: .GET, url: "http://test.com", headers: ["Authorization": token], completion: completion)
    }
}