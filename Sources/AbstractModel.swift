//
//  AbstractModel.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

#if os(OSX)
    import AppKit
    typealias Color = NSColor
#else
    import UIKit
    typealias Color = UIColor
#endif

public protocol InitializableWithDictionary {
    init(dictionary: [String: Any]) throws
}

// MARK: -

public protocol DynamicTypeModel {
    static var typeNameProperty: String { get }
}

/// Abstract model that provides the parsing functionality for subclasses
open class AbstractModel: NSObject, InitializableWithDictionary, NSCoding {
    
    open class var propertyKeys: [String: String] { return [:] }
    open class var propertyDateFormats: [String: String] { return [:] }
    
    open class var resolver: TypeResolver { return DefaultTypeResolver.shared }
    open class var ignoredProperties: [String] { return [] }
    
    open override class func initialize() {
        DefaultTypeResolver.shared.register(type: self)
    }
    
    private lazy var modelType: AbstractModel.Type = type(of: self)
    
    public override init() {
        super.init()
    }
    
    public static func initFrom<T: AbstractModel>(list: [[String: Any]]) throws -> [T] {
        var result = [T]()
        for dictionary in list {
            result.append(try T(dictionary: dictionary))
        }
        return result
    }
    
    public required init(dictionary: [String: Any]) throws {
        super.init()
        
        let mirror = Mirror(reflecting: self)
        try initializeProperties(of: mirror, with: dictionary)
    }
    
    open func initializeProperties(of mirror: Mirror, with dictionary: [String: Any]) throws {
        if mirror.isAbstractModelMirror {
            return
        }
        if let superclassMirror = mirror.superclassMirror {
            try initializeProperties(of: superclassMirror, with: dictionary)
        }
        
        for child in mirror.children {
            guard let property = child.label else {
                continue
            }
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
        guard let property = child.label else {
            return
        }
        if modelType.ignoredProperties.contains(property) {
            return
        }
        let propertyType = Mirror(reflecting:child.value).subjectType
        
        guard let rawValue = optionalRawValue else {
            if self.shouldFail(withInvalidValue: nil, forProperty: property, type: propertyType) {
                throw ModelError.sourceValueError(property: property, model: modelType, value: nil)
            } else {
                return
            }
        }
        
//      MARK: - String
        if try parsed(rawValue: rawValue, property: property, type: propertyType, target: String.self) {}
            
        else if try parsedArray(rawValue: rawValue, property: property, type: propertyType, target: String.self) {}
            
//      MARK: - Int
        else if try safeParsed(rawValue: rawValue, property: property, type: propertyType, target: Int.self) {}
            
        else if try parsedArray(rawValue: rawValue, property: property, type: propertyType, target: Int.self) {}

//      MARK: - Float
        else if try safeParsed(rawValue: rawValue, property: property, type: propertyType, target: Float.self) {}
            
        else if try parsedArray(rawValue: rawValue, property: property, type: propertyType, target: Float.self) {}
            
//      MARK: - Double
        else if try safeParsed(rawValue: rawValue, property: property, type: propertyType, target: Double.self) {}
            
        else if try parsedArray(rawValue: rawValue, property: property, type: propertyType, target: Double.self) {}
            
//      MARK: - Bool
        else if try safeParsed(rawValue: rawValue, property: property, type: propertyType, target: Bool.self) {}
            
        else if try parsedArray(rawValue: rawValue, property: property, type: propertyType, target: Bool.self) {}
            
//      MARK: - Date
        else if try parsedDate(rawValue: rawValue, property: property, type: propertyType, modelType: modelType) {}
            
        else if try parsedDateArray(rawValue: rawValue, property: property, type: propertyType, modelType: modelType) {}
            
//      MARK: - NSDecimalNumber
        else if try parsed(rawValue: rawValue, property: property, type: propertyType, target: NSDecimalNumber.self) {}
            
        else if try parsedArray(rawValue: rawValue, property: property, type: propertyType, target: NSDecimalNumber.self) {}
            
//      MARK: - URL
        else if try parsed(rawValue: rawValue, property: property, type: propertyType, target: URL.self) {}
            
        else if try parsedArray(rawValue: rawValue, property: property, type: propertyType, target: URL.self) {}
            
//      MARK: - Color
        else if try parsed(rawValue: rawValue, property: property, type: propertyType, target: Color.self) {}
            
        else if try parsedArray(rawValue: rawValue, property: property, type: propertyType, target: Color.self) {}
            
//      MARK: - [:]
        else if propertyType is [String: String].Type || propertyType is [String: String]?.Type || propertyType is ImplicitlyUnwrappedOptional<[String: String]>.Type {
            if let value = rawValue as? [String: String] {
                setValue(value, forKey: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property, type: propertyType)
            }
        }
            
//      MARK: AbstractModel
            
        else if let propertyType = modelType.resolver.resolve(type: propertyType) as? InitializableWithDictionary.Type {
            try parsedInitializable(rawValue: rawValue, property: property, type: propertyType)
        }
            
        else if let propertyType = modelType.resolver.resolveArray(type: propertyType) as? InitializableWithDictionary.Type {
            try parsedInitializableArray(rawValue: rawValue, property: property, type: propertyType)
        }
            
        else if let propertyType = modelType.resolver.resolveDictionary(type: propertyType) as? InitializableWithDictionary.Type {
            try parsedDictionary(rawValue: rawValue, property: property, type: propertyType)
        }
            
//      MARK: - AnyInitializable
        else if let propertyType = modelType.resolver.resolve(type: propertyType) as? AnyInitializable.Type {
            try parsedAnyInitializable(rawValue: rawValue, property: property, type: propertyType)
        }
            
        else if let propertyType = modelType.resolver.resolveArray(type: propertyType) as? AnyInitializable.Type {
            try parsedAnyInitializableArray(rawValue: rawValue, property: property, type: propertyType)
        }
            
        else {
            try assign(undefinedValue: rawValue, forProperty: property, type: propertyType)
        }
    }
    
    open func assign(value: Any, forProperty property: String) throws {
        throw ModelError.unasignedInstance(property: property)
    }
    
    open func assign(value: Any, from decoder: NSCoder, forProperty property: String) {
        do {
            try assign(value: value, forProperty: property)
        } catch {
            setValue(value, forKey: property)
        }
    }
    
    // MARK: - Parse
    
    private func parsed<T: AnyMatchBuilder>(rawValue: Any, property: String, type: Any.Type, target: T.Type) throws -> Bool {
        if T.match(type: type) {
            guard let value = T.build(value: rawValue) else {
                throw ModelError.sourceValueError(property: property, model: type(of: self), value: rawValue)
            }
            setValue(value, forKey: property)
            return true
        }
        return false
    }
    
    private func safeParsed<T: AnyMatchBuilder>(rawValue: Any, property: String, type: Any.Type, target: T.Type) throws -> Bool {
        if let optionality = T.optionalityMatch(type: type) {
            guard let value = T.build(value: rawValue) else {
                throw ModelError.sourceValueError(property: property, model: type(of: self), value: rawValue)
            }
            if optionality == .notOptional {
                setValue(value, forKey: property)
            } else {
                try assign(value: value, forProperty: property)
            }
            return true
        }
        return false
    }
    
    private func parsedArray<T: AnyMatchBuilder>(rawValue: Any, property: String, type: Any.Type, target: T.Type) throws -> Bool {
        if T.matchArray(type: type) {
            if let array = rawValue as? [Any] {
                let newArray: [T] = try array.map({
                    if let element = T.build(value: $0) as? T {
                        return element
                    }
                    else {
                        throw ModelError.sourceValueError(property: property, model: T.self, value: $0)
                    }
                })
                setValue(newArray, forKey: property)
            } else {
                throw ModelError.sourceValueError(property: property, model: type(of: self), value: rawValue)
            }
            return true
        }
        return false
    }
    
    private func parsedDate(rawValue: Any, property: String, type: Any.Type, modelType: AbstractModel.Type) throws -> Bool {
        if Date.match(type: type) {
            let format = modelType.propertyDateFormats[property] ?? Configuration.dateFormat
            guard let date = Date(value: rawValue, format: format) else {
                throw ModelError.dateError(property: property, value: String(describing: rawValue))
            }
            setValue(date, forKey: property)
            return true
        }
        return false
    }
    
    private func parsedDateArray(rawValue: Any, property: String, type: Any.Type, modelType: AbstractModel.Type) throws -> Bool {
        if Date.matchArray(type: type) {
            let format = modelType.propertyDateFormats[property] ?? Configuration.dateFormat
            guard let array = rawValue as? [Any] else {
                throw ModelError.dateError(property: property, value: String(describing: rawValue))
            }
            var dates = [Date]()
            for value in array {
                guard let date = Date(value: value, format: format) else {
                    throw ModelError.dateError(property: property, value: String(describing: value))
                }
                dates.append(date)
            }
            setValue(dates, forKey: property)
            return true
        }
        return false
    }
    
    private func parsedDictionary(rawValue: Any, property: String, type: InitializableWithDictionary.Type) throws {
        guard let dictionary = rawValue as? [String: [String: Any]] else {
            throw ModelError.sourceValueError(property: property, model: type(of: self), value: rawValue)
        }
        var newDictionary = [String: InitializableWithDictionary]()
        if let propertyType = type as? DynamicTypeModel.Type {
            let resolver = (propertyType as? AbstractModel.Type)?.resolver ?? modelType.resolver
            for (key, value) in dictionary {
                newDictionary[key] = try dynamicItem(from: value, typeNameKey: propertyType.typeNameProperty, resolver: resolver)
            }
        } else {
            for (key, item) in dictionary {
                newDictionary[key] = try type.init(dictionary: item)
            }
        }
        setValue(newDictionary, forKey: property)
    }
    
    private func dynamicItem(from dictionary: [String: Any], typeNameKey: String, resolver: TypeResolver) throws -> InitializableWithDictionary {
        if let typeName = dictionary[typeNameKey] as? String {
            if let type = resolver.resolve(typeForName: typeName) as? InitializableWithDictionary.Type {
                return try type.init(dictionary: dictionary)
            }
            throw ModelError.undefinedTypeName(name: typeName)
        }
        Log.warn("Dynamic item has no type info")
        throw ModelError.dynamicTypeInfo(key: typeNameKey)
    }
    
    private func parsedInitializable(rawValue: Any, property: String, type: InitializableWithDictionary.Type) throws {
        guard let dictionary = rawValue as? [String: Any] else {
            throw ModelError.sourceValueError(property: property, model: modelType, value: rawValue)
        }
        let value: InitializableWithDictionary
        if let propertyType = type as? DynamicTypeModel.Type {
            let resolver = (propertyType as? AbstractModel.Type)?.resolver ?? modelType.resolver
            value = try dynamicItem(from: dictionary, typeNameKey: propertyType.typeNameProperty, resolver: resolver)
        } else {
            value = try type.init(dictionary: dictionary)
        }
        if value is NSObject {
            setValue(value, forKey: property)
        } else {
            try assign(value: value, forProperty: property)
        }
    }
    
    private func parsedInitializableArray(rawValue: Any, property: String, type: InitializableWithDictionary.Type) throws {
        guard let array = rawValue as? [[String: Any]] else {
            throw ModelError.sourceValueError(property: property, model: modelType, value: rawValue)
        }
        var newArray = [InitializableWithDictionary]()
        if let propertyType = type as? DynamicTypeModel.Type {
            let resolver = (propertyType as? AbstractModel.Type)?.resolver ?? modelType.resolver
            for value in array {
                newArray.append(try dynamicItem(from: value, typeNameKey: propertyType.typeNameProperty, resolver: resolver))
            }
        } else {
            for value in array {
                newArray.append(try type.init(dictionary: value))
            }
        }
        setValue(newArray, forKey: property)
    }
    
    private func parsedAnyInitializable(rawValue: Any, property: String, type: AnyInitializable.Type) throws {
        guard let value = type.init(value: rawValue) else {
            throw ModelError.sourceValueError(property: property, model: modelType, value: rawValue)
        }
        if value is NSObject {
            setValue(value, forKey: property)
        } else {
            try assign(value: value, forProperty: property)
        }
    }
    
    private func parsedAnyInitializableArray(rawValue: Any, property: String, type: AnyInitializable.Type) throws {
        guard let array = rawValue as? [Any] else {
            throw ModelError.sourceValueError(property: property, model: modelType, value: rawValue)
        }
        var newArray: [AnyInitializable] = []
        for element in array {
            guard let value = type.init(value: element) else {
                throw ModelError.sourceValueError(property: property, model: modelType, value: element)
            }
            newArray.append(value)
        }
        setValue(newArray, forKey: property)
    }
    
    /// Override this method in subclasses to assign a value of an undefined type to a property
    /// - parameter value: the value to be assigned
    /// - parameter key: the name of the property to assign
    open func assign(undefinedValue: Any, forProperty property: String, type: Any.Type) throws {
        if shouldFail(withInvalidValue: undefinedValue, forProperty: property, type: type) {
            throw ModelError.sourceValueError(property: property, model: type(of: self), value: undefinedValue)
        }
        if let string = undefinedValue as? String, string.isEmpty { return }
        Log.warn("Could no parse value: |\(undefinedValue)| for property: |\(property)| of model: |\(type(of: self))|")
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
    
    open func initializeProperties(of mirror: Mirror, with decoder: NSCoder) throws {
        if mirror.isAbstractModelMirror {
            return
        }
        if let superclassMirror = mirror.superclassMirror {
            try initializeProperties(of: superclassMirror, with: decoder)
        }
        let modelType = mirror.subjectType as! AbstractModel.Type
        for child in mirror.children {
            guard let property = child.label else { continue }
            let propertyType = Mirror(reflecting: child.value).subjectType
            if let value = decoder.decodeObject(forKey: property), !(value is NSNull) {
                if let type = modelType.resolver.resolve(type: propertyType) as? StringRepresentable.Type, let string = value as? String, let representable = type.init(rawValue: string) {
                    assign(value: representable, from: decoder, forProperty: property)
                } else {
                    assign(value: value, from: decoder, forProperty: property)
                }
            }
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        encodeProperties(of: Mirror(reflecting: self), with: aCoder)
    }
    
    func encodeProperties(of mirror: Mirror, with coder: NSCoder) {
        if mirror.isAbstractModelMirror {
            return
        }
        if let superclassMirror = mirror.superclassMirror {
            encodeProperties(of: superclassMirror, with: coder)
        }
        let modelType = mirror.subjectType as! AbstractModel.Type
        for child in mirror.children {
            guard let property = child.label else { continue }
            let propertyType = Mirror(reflecting: child.value).subjectType
            if let value = child.value as? StringRepresentable {
                coder.encode(value.rawValue, forKey: property)
            } else if let _ = modelType.resolver.resolve(type: propertyType) as? StringRepresentable.Type {
                Log.debug("representable")
            } else {
                coder.encode(child.value, forKey: property)
            }
        }
    }
}
