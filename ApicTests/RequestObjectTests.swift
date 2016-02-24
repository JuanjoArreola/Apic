//
//  RequestObjectTests.swift
//  Apic
//
//  Created by Juan Jose Arreola on 2/23/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic
import Alamofire

class RequestObjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequestUser() {
        let userRepository = UserRepository()
        
        let expectation: XCTestExpectation = expectationWithDescription("fetch list")
        userRepository.requestUserWithName("JuanjoArreola") { (getUser) -> Void in
            do {
                try getUser()
                expectation.fulfill()
            } catch {
                Log.error(error)
                XCTFail()
            }
        }
        waitForExpectationsWithTimeout(60.0, handler: nil)
    }
    
    func testRequestInnerUser() {
        let gistRepository = GistRepository()
        
        let expectation: XCTestExpectation = expectationWithDescription("fetch list")
        gistRepository.requestUserFromGist("30f7b1a56a61c71631a6") { (getUser) -> Void in
            do {
                try getUser()
                expectation.fulfill()
            } catch {
                Log.error(error)
                XCTFail()
            }
        }
        waitForExpectationsWithTimeout(60.0, handler: nil)
    }
    
    func testRequestInnerUserWrong() {
        let gistRepository = WrongGistRepository()
        
        let expectation: XCTestExpectation = expectationWithDescription("fetch list")
        gistRepository.requestUserFromGist("30f7b1a56a61c71631a6") { (getUser) -> Void in
            do {
                try getUser()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(60.0, handler: nil)
    }
    
    func testRequestUserWrong() {
        let repository = WrongUserRepository()
        
        let expectation: XCTestExpectation = expectationWithDescription("fetch list")
        repository.requestUserWithName("JuanjoArreola") { (getUser) -> Void in
            do {
                try getUser()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        }
        waitForExpectationsWithTimeout(60.0, handler: nil)
    }
    
}

class User: AbstractModel {
    var id: Int = 0
    var login: String!
    var avatar_url: NSURL!
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return true
    }
}

class UserRepository: AbstractRepository {
    func requestUserWithName(name: String, completion: (getUser: () throws -> User) -> Void) -> Request? {
        return requestObject(.GET, url: "https://api.github.com/users/\(name)", completion: completion)
    }
}

class WrongUserRepository: AbstractRepository {
    
    init() {
        super.init(objectKey: "user")
    }
    
    func requestUserWithName(name: String, completion: (getUser: () throws -> User) -> Void) -> Request? {
        return requestObject(.GET, url: "https://api.github.com/users/\(name)", completion: completion)
    }
}

class GistRepository: AbstractRepository {
    
    init() {
        super.init(objectKey: "owner")
    }
    
    func requestUserFromGist(gist: String, completion: (getUser: () throws -> User) -> Void) -> Request? {
        return requestObject(.GET, url: "https://api.github.com/gists/\(gist)", completion: completion)
    }
}

class WrongGistRepository: AbstractRepository {
    
    func requestUserFromGist(gist: String, completion: (getUser: () throws -> User) -> Void) -> Request? {
        return requestObject(.GET, url: "https://api.github.com/gists/\(gist)", completion: completion)
    }
}
