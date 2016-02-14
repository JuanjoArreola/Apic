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
            try ComplexContainer(dictionary: ["id": "1"])
            XCTFail()
        } catch { }
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
            try ComplexContainer(dictionary: ["id": "1", "first": ["id": "1"], "second": ["name": "two"]])
            XCTFail()
        } catch { }
    }
    
    func testUnresolvedProperty() {
        do {
            try WrongDefinitionComplexContainer(dictionary: ["first": ["id": "2"]])
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
            try ComplexArrayContainer(dictionary: ["id": "1"])
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
            try ComplexArrayContainer(dictionary: ["models": [["ids": "2"]], "optionals": [["id": "3"], ["id": "4"]]])
            XCTFail()
        } catch { }
    }
    
    func testUnresolvedPropertyArray() {
        do {
            try WrongDefinitionComplexArrayContainer(dictionary: ["models": [["id": "2"]]])
            XCTFail()
        } catch { }
    }
    
}

class ComplexModel: AbstractModel {
    static let _resolver = ComplexTypeResolver()
    override class var resolver: TypeResolver? { return _resolver }
}

class ComplexContainer: ComplexModel {
    var id: String!
    var first: SimpleModel!
    var second: SimpleModel?
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return ["id", "first"].contains(property)
    }
}

class ComplexArrayContainer: ComplexModel {
    var models: [SimpleModel]!
    var optionals: [SimpleModel]?
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return ["models"].contains(property)
    }
}

class WrongDefinitionComplexContainer: ComplexModel {
    var option: UnresolvedModel?
    var first: UnresolvedModel!
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return ["first"].contains(property)
    }
}

class WrongDefinitionComplexArrayContainer: ComplexModel {
    var models: [UnresolvedModel]!
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return ["models"].contains(property)
    }
}

class SimpleModel: AbstractModel {
    var id: String!
    var name: String?
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return property == "id"
    }
}

class UnresolvedModel: AbstractModel {
    var id: String!
}

class ComplexTypeResolver: TypeResolver {
    
    func resolveType(type: Any) -> Any? {
        if type is SimpleModel.Type || type is SimpleModel?.Type || type is [SimpleModel]?.Type {
            return SimpleModel.self
        }
        return nil
    }
}