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
    open class var ignoredProperties: [String] { return [] }
    
    open class var dateFormat: String? { return nil }
    open class var propertyDateFormats: [String: String] { return [:] }
    
    static let resolver = DefaultTypeResolver.shared
    
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
            guard let property = child.label, !modelType.ignoredProperties.contains(property) else { continue }
            
            let key = modelType.propertyKeys[property] ?? property
            try assign(rawValue: dictionary[key], to: child)
        }
    }
    
    public func assign(rawValue: Any?, toProperty property: String, mirror: Mirror? = nil) throws {
        let mirror = mirror ?? Mirror(reflecting: self)
        if let child = mirror.findChild(withName: property) {
            try assign(rawValue: rawValue, to: child)
        } else {
            if mirror.isAbstractModelMirror {
                throw ModelError.invalidProperty(property: property)
            }
            if let superclassMirror = mirror.superclassMirror {
                try assign(rawValue: rawValue, toProperty: property, mirror: superclassMirror)
            }
        }
    }
    
    open func assign(rawValue optionalRawValue: Any?, to child: Mirror.Child) throws {
        guard let property = child.label else { return }
    
        let propertyType = type(of: child.value)
        
        guard let rawValue = optionalRawValue else {
            if "\(propertyType)".hasPrefix("Optional<") {
                return
            }
            if String(describing: child.value) != "nil" {
                return
            }
            throw ModelError.sourceValueError(property: property, model: modelType, value: nil)
        }
        
        let parser = ModelParserProvider.shared.parser(for: type(of: self))
        
        if try parser.assignBasic(value: rawValue, to: self, child: child) { return }
        
        if try parser.assignSimple(value: rawValue, to: self, child: child) { return }
            
        if try parser.assignDictionaryInitializable(value: rawValue, to: self, child: child) { return }
            
        if try parser.assignAnyInitializable(value: rawValue, to: self, child: child) { return }
        
        if shouldFail(withInvalidValue: rawValue, forProperty: property, type: propertyType) {
            throw ModelError.sourceValueError(property: property, model: modelType, value: rawValue)
        }
    }
    
    open func assign(value: Any, forProperty property: String) throws {
        throw ModelError.unasignedInstance(property: property)
    }
    
    /// Override this method in subclasses and return true if the object is invalid if a value couln't be parsed for a property
    open func shouldFail(withInvalidValue value: Any, forProperty property: String, type: Any.Type) -> Bool {
        Log.warn("The value: \(value) could not be parsed to type: |\(type)|, consider to register the type with:\n\nDefaultTypeResolver.shared.register(type: <MyModel>.self\n")
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
