//
//  HeadersTests.swift
//  Apic
//
//  Created by Juan Jose Arreola on 04/03/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
import Apic

class HeadersTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func _testExpectHeader() {
//        stubWithResponse(["status": "OK"], expectingHeader: "Authorization", withValue: "myId")
        let expectation: XCTestExpectation = self.expectation(description: "fetch success")
        let repository = WithHeaderRepository()
        repository.requestTest("myId") { (getSuccess) -> Void in
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
    
    func _testExpectWrongHeaderValue() {
//        stubWithResponse(["status": "OK"], expectingHeader: "Authorization", withValue: "myId")
        let expectation: XCTestExpectation = self.expectation(description: "fetch success")
        let repository = WithHeaderRepository()
        repository.requestTest("otherId") { (getSuccess) -> Void in
            do {
                _ = try getSuccess()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
//    fileprivate func stubWithResponse(_ response: [String: Any], expectingHeader header: String, withValue value: String) {
//        OHHTTPStubs.stubRequests(passingTest: { _ in return true }) {
//            (request: URLRequest) -> OHHTTPStubsResponse in
//            guard let headers = request.allHTTPHeaderFields else {
//                return self.responseError()
//            }
//            guard let headerValue = headers[header] else {
//                return self.responseError()
//            }
//            if headerValue == value {
//                return OHHTTPStubsResponse(data: self.jsonWithDictionary(response), statusCode:200, headers: ["Content-Type": "application/json"])
//            }
//            return self.responseError()
//        }
//    }
    
//    fileprivate func responseError() -> OHHTTPStubsResponse {
//        return OHHTTPStubsResponse(data: self.jsonWithDictionary(["status": "Fail"]), statusCode:200, headers: ["Content-Type": "application/json"])
//    }
    
    fileprivate func jsonWithDictionary(_ dictionary: [String: Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: dictionary, options: [])
    }
    
}

class WithHeaderRepository: AbstractRepository {
    
    init() {
        let configuration = DefaultResponseParser<String>()
        configuration.statusKey = "status"
        configuration.statusOk = "OK"
        super.init(responseParser: configuration)
    }
    
    @discardableResult func requestTest(_ token: String, completion: @escaping (_ getSuccess: () throws -> Bool) -> Void) -> Request<Bool>? {
        return requestSuccess(method: .GET, url: "http://test.com", headers: ["Authorization": token], completion: completion)
    }
}
