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
                print(error)
                XCTFail()
            }
        }
        waitForExpectations(timeout: 8.0, handler: nil)
    }
    
    func testRequestUser2() {
        let expectation: XCTestExpectation = self.expectation(description: "fetch list")
        let request = UserRepository2.shared.requestUser2(withName: "JuanjoArreola") { user in
            expectation.fulfill()
        }
        request?.fail { _ in XCTFail() }
        waitForExpectations(timeout: 8.0, handler: nil)
    }
    
    func testRequestInnerUser() {
        let gistRepository = GistRepository()
        
        let expectation: XCTestExpectation = self.expectation(description: "fetch list")
        gistRepository.requestUser(fromGist: "30f7b1a56a61c71631a6") { (getUser) -> Void in
            do {
                _ = try getUser()
                expectation.fulfill()
            } catch {
                print(error)
                XCTFail()
            }
        }
        waitForExpectations(timeout: 8.0, handler: nil)
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
        waitForExpectations(timeout: 8.0, handler: nil)
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
        waitForExpectations(timeout: 8.0, handler: nil)
    }
    
}

class User: AbstractModel {
    var id: Int = 0
    var login: String!
    var avatar_url: URL!
}

class UserRepository2: AbstractRequestRepository {
    
    static var shared = UserRepository2(responseParser: DefaultResponseParser<String>())
    
    @discardableResult func requestUser2(withName name: String, completion: @escaping (User) -> Void) -> Request<User>? {
        return requestObject(route: .get("https://api.github.com/users/\(name)"), completion: completion)
    }
}

class UserRepository: AbstractRepository {
    
    init() {
        let parser = DefaultResponseParser<String>()
        super.init(responseParser: parser)
    }
    
    @discardableResult func requestUser(withName name: String, completion: @escaping (_ getUser: () throws -> User) -> Void) -> Request<User>? {
        return requestObject(method: .GET, url: "https://api.github.com/users/\(name)", completion: completion)
    }
}

class WrongUserRepository: AbstractRepository {
    
    init() {
        let parser = DefaultResponseParser<String>()
        parser.objectKey = "user"
        super.init(responseParser: parser)
    }
    
    @discardableResult func requestUser(withName name: String, completion: @escaping (_ getUser: () throws -> User) -> Void) -> Request<User>? {
        return requestObject(method: .GET, url: "https://api.github.com/users/\(name)", completion: completion)
    }
}

class GistRepository: AbstractRepository {
    
    init() {
        let parser = DefaultResponseParser<String>()
        parser.objectKey = "owner"
        super.init(responseParser: parser)
    }
    
    @discardableResult func requestUser(fromGist gist: String, completion: @escaping (_ getUser: () throws -> User) -> Void) -> Request<User>? {
        return requestObject(method: .GET, url: "https://api.github.com/gists/\(gist)", completion: completion)
    }
}

class WrongGistRepository: AbstractRepository {
    
    init() {
        let parser = DefaultResponseParser<String>()
        super.init(responseParser: parser)
    }
    
    @discardableResult func requestUser(fromGist gist: String, completion: @escaping (_ getUser: () throws -> User) -> Void) -> Request<User>? {
        return requestObject(method: .GET, url: "https://api.github.com/gists/\(gist)", completion: completion)
    }
}
