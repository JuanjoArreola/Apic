//
//  ReachabilityTests.swift
//  Apic
//
//  Created by Juan Jose Arreola on 23/03/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
import Apic

private let testQueue: DispatchQueue = DispatchQueue(label: "com.apic.TestQueue", attributes: DispatchQueue.Attributes.concurrent)

class ReachabilityTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        var count = 0
        var fulfilled = false
        let expectation: XCTestExpectation = self.expectation(description: "fetch list")
        for i in 0...20 {
            testQueue.async {
                do {
                    let info = try Reachability.reachabilityInfoForURL(URL(string: "http://github.com/\(i)")!)
                    Log.debug("info: \(info)")
                    count += 1
                    if count >= 19 && !fulfilled {
                        expectation.fulfill()
                        fulfilled = true
                    }
                } catch {
                    Log.error(error)
                    XCTFail()
                }
            }
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
}
