//
//  ComplexModelTests.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 1/23/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import XCTest
@testable import Apic

class ComplexModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMandatoryProperties() {
        do {
            let container = try ComplexContainer(dictionary: ["id": "1", "first": ["id": "2"]])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.first)
        } catch {
            XCTFail()
        }
    }
    
    func testMandatoryPropertiesNil() {
        do {
            _ = try ComplexContainer(dictionary: ["id": "1"])
            XCTFail()
        } catch {
            Log.debug(error)
        }
    }
    
    func testOptionalPropertyNil() {
        do {
            let container = try ComplexContainer(dictionary: ["id": "1", "first": ["id": "2"]])
            XCTAssertNotNil(container)
            XCTAssertNil(container.second)
        } catch {
            XCTFail()
        }
    }
    
    func testOptionalPropertyNotNil() {
        do {
            let container = try ComplexContainer(dictionary: ["id": "1", "first": ["id": "1"], "second": ["id": "2", "name": "two"]])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.second)
            XCTAssertNotNil(container.second?.name)
            XCTAssertEqual(container.second!.name, "two")
        } catch {
            XCTFail()
        }
    }
    
    func testInvalidPropertyValue() {
        do {
            _ = try ComplexContainer(dictionary: ["id": "1", "first": ["id": "1"], "second": ["name": "two"]])
            XCTFail()
        } catch { }
    }
    
    func testUnresolvedProperty() {
        do {
            _ = try WrongDefinitionComplexContainer(dictionary: ["first": ["id": "2"]])
            XCTFail()
        } catch { }
    }
    
//    MARK: - [AbstractModel]
    
    func testMandatoryPropertiesArray() {
        do {
            let container = try ComplexArrayContainer(dictionary: ["models": [["id": "2"], ["id": "3"]]])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.models)
        } catch {
            XCTFail()
        }
    }
    
    func testMandatoryPropertiesArrayNil() {
        do {
            _ = try ComplexArrayContainer(dictionary: ["id": "1"])
            XCTFail()
        } catch { }
    }
    
    func testOptionalPropertyArrayNil() {
        do {
            let container = try ComplexArrayContainer(dictionary: ["models": [["id": "2"]]])
            XCTAssertNotNil(container)
            XCTAssertNil(container.optionals)
        } catch {
            XCTFail()
        }
    }
    
    func testOptionalPropertyArrayNotNil() {
        do {
            let container = try ComplexArrayContainer(dictionary: ["models": [["id": "2"]], "optionals": [["id": "3"], ["id": "4"]]])
            XCTAssertNotNil(container)
            XCTAssertNotNil(container.optionals)
        } catch {
            XCTFail()
        }
    }
    
    func testInvalidPropertyArrayValue() {
        do {
            _ = try ComplexArrayContainer(dictionary: ["models": [["ids": "2"]], "optionals": [["id": "3"], ["id": "4"]]])
            XCTFail()
        } catch { }
    }
    
    func testUnresolvedPropertyArray() {
        do {
            _ = try WrongDefinitionComplexArrayContainer(dictionary: ["models": [["id": "2"]]])
            XCTFail()
        } catch { }
    }
    
}

class ComplexContainer: AbstractModel {
    var id: String!
    var first: SimpleModel!
    var second: SimpleModel?
}

class ComplexArrayContainer: AbstractModel {
    var models: [SimpleModel]!
    var optionals: [SimpleModel]?
}

class WrongDefinitionComplexContainer: AbstractModel {
    var option: UnresolvedType?
    var first: UnresolvedType!
}

class WrongDefinitionComplexArrayContainer: AbstractModel {
    var models: [UnresolvedType]!
}

class SimpleModel: AbstractModel {
    var id: String!
    var name: String?
}

enum UnresolvedType: StringInitializable {
    case test
    
    init?(rawValue: String) {
        if rawValue.lowercased() == "test" {
            self = .test
        } else {
            return nil
        }
    }
}
