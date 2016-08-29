//
//  RequestObjectTests.swift
//  Apic
//
//  Created by Juan Jose Arreola on 2/23/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
import Apic

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
        
        let expectation: XCTestExpectation = self.expectation(description: "fetch list")
        userRepository.requestUser(withName: "JuanjoArreola") { (getUser) -> Void in
            do {
                _ = try getUser()
                expectation.fulfill()
            } catch {
                Log.error(error)
                XCTFail()
            }
        }
        waitForExpectations(timeout: 60.0, handler: nil)
    }
    
    func testRequestInnerUser() {
        let gistRepository = GistRepository()
        
        let expectation: XCTestExpectation = self.expectation(description: "fetch list")
        gistRepository.requestUser(fromGist: "30f7b1a56a61c71631a6") { (getUser) -> Void in
            do {
                _ = try getUser()
                expectation.fulfill()
            } catch {
                Log.error(error)
                XCTFail()
            }
        }
        waitForExpectations(timeout: 60.0, handler: nil)
    }
    
    func testRequestInnerUserWrong() {
        let gistRepository = WrongGistRepository()
        
        let expectation: XCTestExpectation = self.expectation(description: "fetch list")
        gistRepository.requestUser(fromGist: "30f7b1a56a61c71631a6") { (getUser) -> Void in
            do {
                _ = try getUser()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 60.0, handler: nil)
    }
    
    func testRequestUserWrong() {
        let repository = WrongUserRepository()
        
        let expectation: XCTestExpectation = self.expectation(description: "fetch list")
        repository.requestUser(withName: "JuanjoArreola") { (getUser) -> Void in
            do {
                _ = try getUser()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 60.0, handler: nil)
    }
    
}

class User: AbstractModel {
    var id: Int = 0
    var login: String!
    var avatar_url: URL!
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return true
    }
}

class UserRepository: AbstractRepository<String> {
    
    init() { super.init() }
    
    @discardableResult func requestUser(withName name: String, completion: @escaping (_ getUser: () throws -> User) -> Void) -> Request<User>? {
        return requestObject(method: .GET, url: "https://api.github.com/users/\(name)", completion: completion)
    }
}

class WrongUserRepository: AbstractRepository<String> {
    
    init() {
        super.init(objectKey: "user")
    }
    
    @discardableResult func requestUser(withName name: String, completion: @escaping (_ getUser: () throws -> User) -> Void) -> Request<User>? {
        return requestObject(method: .GET, url: "https://api.github.com/users/\(name)", completion: completion)
    }
}

class GistRepository: AbstractRepository<String> {
    
    init() {
        super.init(objectKey: "owner")
    }
    
    @discardableResult func requestUser(fromGist gist: String, completion: @escaping (_ getUser: () throws -> User) -> Void) -> Request<User>? {
        return requestObject(method: .GET, url: "https://api.github.com/gists/\(gist)", completion: completion)
    }
}

class WrongGistRepository: AbstractRepository<String> {
    
    init() { super.init() }
    
    @discardableResult func requestUser(fromGist gist: String, completion: @escaping (_ getUser: () throws -> User) -> Void) -> Request<User>? {
        return requestObject(method: .GET, url: "https://api.github.com/gists/\(gist)", completion: completion)
    }
}
