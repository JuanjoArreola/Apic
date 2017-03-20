//
//  AbstractModel.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

#if os(OSX)
    import AppKit
#else
    import UIKit
#endif


/// Abstract model that provides the parsing functionality for subclasses
open class AbstractModel: NSObject, NSCoding, InitializableWithDictionary {
    
    open class var propertyKeys: [String: String] { return [:] }
    open class var propertyDateFormats: [String: String] { return [:] }
    
    open class var resolver: TypeResolver { return DefaultTypeResolver.shared }
    open class var ignoredProperties: [String] { return [] }
    
    open override class func initialize() {
        DefaultTypeResolver.shared.register(type: self)
    }
    
    internal lazy var modelType: AbstractModel.Type = type(of: self)
    
    public override init() {
        super.init()
    }
    
    public static func initFrom<T: AbstractModel>(list: [[String: Any]]) throws -> [T] {
        return try list.map({ try T(dictionary: $0) })
    }
    
    public required init(dictionary: [String: Any]) throws {
        super.init()
        
        try initializeProperties(of: Mirror(reflecting: self), with: dictionary)
    }
    
    open func initializeProperties(of mirror: Mirror, with dictionary: [String: Any]) throws {
        if mirror.isAbstractModelMirror {
            return
        }
        if let superclassMirror = mirror.superclassMirror {
            try initializeProperties(of: superclassMirror, with: dictionary)
        }
        
        for child in mirror.children {
            guard let property = child.label else { continue }
            
            let key = modelType.propertyKeys[property] ?? property
            do {
                try assign(rawValue: dictionary[key], to: child, parser: self)
            } catch {
                if shouldFail(withInvalidValue: dictionary[key], forProperty: property, type: modelType) {
                    throw error
                }
            }
        }
    }
    
    public func assign(rawValue: Any?, toProperty property: String, mirror: Mirror? = nil) throws {
        let mirror = mirror ?? Mirror(reflecting: self)
        if let child = mirror.findChild(withName: property) {
            do {
                try assign(rawValue: rawValue, to: child, parser: self)
            } catch {
                if shouldFail(withInvalidValue: rawValue, forProperty: property, type: modelType) {
                    throw error
                }
            }
        } else {
            if mirror.isAbstractModelMirror {
                throw ModelError.invalidProperty(property: property)
            }
            if let superclassMirror = mirror.superclassMirror {
                try assign(rawValue: rawValue, toProperty: property, mirror: superclassMirror)
            }
        }
    }
    
    open func assign(rawValue optionalRawValue: Any?, to child: Mirror.Child, parser: PropertyParser) throws {
        guard let property = child.label else { return }
        
        if modelType.ignoredProperties.contains(property) {
            return
        }
        let propertyType = Mirror(reflecting: child.value).subjectType
        
        guard let rawValue = optionalRawValue else {
            if self.shouldFail(withInvalidValue: nil, forProperty: property, type: propertyType) {
                throw ModelError.sourceValueError(property: property, model: modelType, value: nil)
            } else {
                return
            }
        }
        
//      MARK: - String
        if try parser.parsed(value: rawValue, property: property, type: propertyType, target: String.self) {}
            
        else if try parser.parsedArray(value: rawValue, property: property, type: propertyType, target: String.self) {}
            
//      MARK: - Int
        else if try parser.safeParsed(value: rawValue, property: property, type: propertyType, target: Int.self) {}
            
        else if try parser.parsedArray(value: rawValue, property: property, type: propertyType, target: Int.self) {}

//      MARK: - Float
        else if try parser.safeParsed(value: rawValue, property: property, type: propertyType, target: Float.self) {}
            
        else if try parser.parsedArray(value: rawValue, property: property, type: propertyType, target: Float.self) {}
            
//      MARK: - Double
        else if try parser.safeParsed(value: rawValue, property: property, type: propertyType, target: Double.self) {}
            
        else if try parser.parsedArray(value: rawValue, property: property, type: propertyType, target: Double.self) {}
            
//      MARK: - Bool
        else if try parser.safeParsed(value: rawValue, property: property, type: propertyType, target: Bool.self) {}
            
        else if try parser.parsedArray(value: rawValue, property: property, type: propertyType, target: Bool.self) {}
            
//      MARK: - Date
        else if try parser.parsedDate(value: rawValue, property: property, type: propertyType) {}
            
        else if try parser.parsedDateArray(value: rawValue, property: property, type: propertyType) {}
            
//      MARK: - NSDecimalNumber
        else if try parser.parsed(value: rawValue, property: property, type: propertyType, target: NSDecimalNumber.self) {}
            
        else if try parser.parsedArray(value: rawValue, property: property, type: propertyType, target: NSDecimalNumber.self) {}
            
//      MARK: - URL
        else if try parser.parsed(value: rawValue, property: property, type: propertyType, target: URL.self) {}
            
        else if try parser.parsedArray(value: rawValue, property: property, type: propertyType, target: URL.self) {}
            
//      MARK: - Color
        else if try parser.parsed(value: rawValue, property: property, type: propertyType, target: Color.self) {}
            
        else if try parser.parsedArray(value: rawValue, property: property, type: propertyType, target: Color.self) {}
            
//      MARK: - [String: String]
        else if try parser.parsedStringDictionary(value: rawValue, property: property, type: propertyType) {}
            
//      MARK: AbstractModel
            
        else if let propertyType = modelType.resolver.resolve(type: propertyType) as? InitializableWithDictionary.Type {
            try parser.parseInitializable(value: rawValue, property: property, type: propertyType)
        }
            
        else if let propertyType = modelType.resolver.resolveArray(type: propertyType) as? InitializableWithDictionary.Type {
            try parser.parseInitializableArray(value: rawValue, property: property, type: propertyType)
        }
            
        else if let propertyType = modelType.resolver.resolveDictionary(type: propertyType) as? InitializableWithDictionary.Type {
            try parser.parseDictionary(value: rawValue, property: property, type: propertyType)
        }
            
//      MARK: - AnyInitializable
            
        else if let propertyType = modelType.resolver.resolve(type: propertyType) as? AnyInitializable.Type {
            try parser.parseAnyInitializable(value: rawValue, property: property, type: propertyType)
        }
            
        else if let propertyType = modelType.resolver.resolveArray(type: propertyType) as? AnyInitializable.Type {
            try parser.parseAnyInitializableArray(value: rawValue, property: property, type: propertyType)
        }
        
        else {
            throw ModelError.sourceValueError(property: property, model: modelType, value: rawValue)
        }
    }
    
    open func assign(value: Any, forProperty property: String) throws {
        throw ModelError.unasignedInstance(property: property)
    }
    
    /// Override this method in subclasses and return true if the object is invalid if a value couln't be parsed for a property
    open func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool? {
        return nil
    }
    
    internal func shouldFail(withInvalidValue value: Any?, forProperty property: String, type: Any.Type) -> Bool {
        if let fail = shouldFail(withInvalidValue: value, forProperty: property) { return fail }
        if "\(type)".hasPrefix("Optional<") {
            if let value = value {
                Log.warn("The value: \(value) could not be parsed to type: |\(type)|, the property: \(property) might have an incorrect value")
            }
            return false
        }
        return true
    }
    
    // MARK: - NSCoding
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        do {
            try initializeProperties(of: Mirror(reflecting: self), with: aDecoder)
        } catch {
            return nil
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        encodeProperties(of: Mirror(reflecting: self), with: aCoder)
    }
}
