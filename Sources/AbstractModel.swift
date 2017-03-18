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

// MARK: - String

public protocol StringInitializable {
    init?(rawValue: String)
}

public protocol StringRepresentable: StringInitializable {
    var rawValue: String { get }
}

// MARK: - Int

public protocol IntInitializable {
    init?(rawValue: Int)
}

protocol IntRepresentable: IntInitializable {
    var rawValue: Int { get }
}

// MARK: -

public protocol DynamicTypeModel {
    static var typeNameProperty: String { get }
}

/// Abstract model that provides the parsing functionality for subclasses
open class AbstractModel: NSObject, InitializableWithDictionary, NSCoding {
    
    open class var propertyKeys: [String: String] { return [:] }
    open class var propertyDateFormats: [String: String] { return [:] }
    
    open class var resolver: TypeResolver? { return DefaultTypeResolver.shared }
    open class var ignoredProperties: [String] { return [] }
    
    open override class func initialize() {
        DefaultTypeResolver.shared.register(type: self)
    }
    
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
        
        let modelType = mirror.subjectType as! AbstractModel.Type
        
        for child in mirror.children {
            guard let property = child.label else {
                continue
            }
            let key = modelType.propertyKeys[property] ?? property
            try assign(rawValue: dictionary[key], to: child, modelType: modelType)
        }
    }
    
    public func assign(rawValue: Any?, toProperty property: String, mirror: Mirror? = nil) throws {
        let mirror = mirror ?? Mirror(reflecting: self)
        if let child = mirror.findChild(withName: property) {
            let modelType = mirror.subjectType as! AbstractModel.Type
            try assign(rawValue: rawValue, to: child, modelType: modelType)
        } else {
            if mirror.isAbstractModelMirror {
                throw ModelError.invalidProperty(property: property)
            }
            if let superclassMirror = mirror.superclassMirror {
                try assign(rawValue: rawValue, toProperty: property, mirror: superclassMirror)
            }
        }
    }
    
    open func assign(rawValue optionalRawValue: Any?, to child: Mirror.Child, modelType: AbstractModel.Type) throws {
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
        else if Date.match(type: propertyType) {
            let format = modelType.propertyDateFormats[property] ?? Configuration.dateFormat
            guard let date = Date(value: rawValue, format: format) else {
                throw ModelError.dateError(property: property, value: String(describing: rawValue))
            }
            setValue(date, forKey: property)
        }
            
        else if Date.matchArray(type: propertyType) {
            let format = modelType.propertyDateFormats[property] ?? Configuration.dateFormat
            guard let array = rawValue as? [Any] else {
                return
            }
            var dates = [Date]()
            for value in array {
                guard let date = Date(value: value, format: format) else {
                    throw ModelError.dateError(property: property, value: String(describing: value))
                }
                dates.append(date)
            }
            setValue(dates, forKey: property)
        }
            
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
            
        else if let value = rawValue as? [String: Any] {
            
//          MARK: AbstractModel
            if let dictionary = rawValue as? [String: [String: Any]], let propertyType = modelType.resolver?.resolveDictionary(type: propertyType) as? InitializableWithDictionary.Type {
                var newDictionary = [String: InitializableWithDictionary]()
                if let propertyType = propertyType as? DynamicTypeModel.Type {
                    let resolver = (propertyType as? AbstractModel.Type)?.resolver ?? modelType.resolver
                    for (key, item) in dictionary {
                        if let typeName = item[propertyType.typeNameProperty] as? String {
                            if let itemType = resolver?.resolve(typeForName: typeName) as? AbstractModel.Type {
                                newDictionary[key] = try itemType.init(dictionary: item)
                            } else {
                                Log.warn("Unresolved type |\(typeName)| for property |\(property)| of model |\(type(of: self))|")
                                if shouldFail(withInvalidValue: rawValue, forProperty: property, type: propertyType) {
                                    throw ModelError.undefinedTypeName(typeName: typeName)
                                }
                            }
                        } else {
                            Log.warn("Dynamic item has no type info")
                            if shouldFail(withInvalidValue: rawValue, forProperty: property, type: propertyType) {
                                throw ModelError.invalidProperty(property: property)
                            }
                        }
                    }
                } else {
                    for (key, item) in dictionary {
                        newDictionary[key] = try propertyType.init(dictionary: item)
                    }
                }
                setValue(newDictionary, forKey: property)
            } else if let propertyType = modelType.resolver?.resolve(type: propertyType) as? InitializableWithDictionary.Type {
                let obj = try propertyType.init(dictionary: value)
                if obj is NSObject {
                    setValue(obj, forKey: property)
                } else {
                    try assign(value: obj, forProperty: property)
                }
            } else {
                Log.warn("Unresolved type <\(propertyType)> for property <\(property)> of model <\(type(of: self))>")
                try assign(undefinedValue: rawValue, forProperty: property, type: propertyType)
            }
        }
            
//      MARK: - [[:]]
        else if let array = rawValue as? [[String: Any]] {
            
//          MARK: [AbstractModel]
            if let propertyType = modelType.resolver?.resolve(type: propertyType) as? AbstractModel.Type {
                do {
                    var newArray = [AbstractModel]()
                    if let propertyType = propertyType as? DynamicTypeModel.Type {
                        let resolver = (propertyType as? AbstractModel.Type)?.resolver ?? modelType.resolver
                        for item in array {
                            if let typeName = item[propertyType.typeNameProperty] as? String {
                                if let itemType = resolver?.resolve(typeForName: typeName) as? AbstractModel.Type {
                                    newArray.append(try itemType.init(dictionary: item))
                                } else {
                                    Log.warn("Unresolved type <\(typeName)> for property <\(property)> of model <\(type(of: self))>")
                                    if shouldFail(withInvalidValue: rawValue, forProperty: property, type: propertyType) {
                                        throw ModelError.undefinedTypeName(typeName: typeName)
                                    }
                                }
                            } else {
                                Log.warn("Dynamic item has no type info")
                                if shouldFail(withInvalidValue: rawValue, forProperty: property, type: propertyType) {
                                    throw ModelError.invalidProperty(property: property)
                                }
                            }
                        }
                    } else {
                        for item in array {
                            do {
                                newArray.append(try propertyType.init(dictionary: item))
                            } catch {
                                Log.warn("Couldn't append to \(property):  \(error)")
                                throw error
                            }
                        }
                    }
                    setValue(newArray, forKey: property)
                } catch {
                    if shouldFail(withInvalidValue: rawValue, forProperty: property, type: propertyType) {
                        throw error
                    }
                }
            } else {
                Log.warn("Unresolved type |\(propertyType)| for property |\(property)| of model |\(type(of: self))|")
                try assign(undefinedValue: rawValue, forProperty: property, type: propertyType)
            }
        }
            
//      MARK: - StringInitializable
        else if let propertyType = modelType.resolver?.resolve(type: propertyType) as? StringInitializable.Type {
            if let string = rawValue as? String {
                if let value = propertyType.init(rawValue: string) {
                    try assign(value: value, forProperty: property)
                } else {
                    try assign(undefinedValue: rawValue, forProperty: property, type: propertyType)
                }
            } else if let array = rawValue as? [String] {
                var newArray: [StringInitializable] = []
                for value in array {
                    if let value = propertyType.init(rawValue: value) {
                        newArray.append(value)
                    } else {
                        try assign(undefinedValue: array, forProperty: property, type: propertyType)
                        return
                    }
                }
                try assign(value: newArray, forProperty: property)
            }
            else {
                try assign(undefinedValue: rawValue, forProperty: property, type: propertyType)
            }
        }
            
//      MARK: - IntInitializable
        else if let propertyType = modelType.resolver?.resolve(type: propertyType) as? IntInitializable.Type {
            if let value = Int(value: rawValue) {
                if let value = propertyType.init(rawValue: value) {
                    try assign(value: value, forProperty: property)
                } else {
                    try assign(undefinedValue: rawValue, forProperty: property, type: propertyType)
                }
            } else if let array = rawValue as? [Any] {
                var newArray: [IntInitializable] = []
                for value in array {
                    if let int = Int(value: value), let initializable = propertyType.init(rawValue: int) {
                        newArray.append(initializable)
                    } else {
                        try assign(undefinedValue: array, forProperty: property, type: propertyType)
                        return
                    }
                }
                try assign(value: newArray, forProperty: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property, type: propertyType)
            }
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
    
    // MARK: -
    
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
        if "\(type)".hasPrefix("Optional<") { return false }
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
        if String(describing: mirror.subjectType) == String(describing: AbstractModel.self) {
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
                if let type = modelType.resolver?.resolve(type: propertyType) as? StringRepresentable.Type, let string = value as? String, let representable = type.init(rawValue: string) {
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
        if String(describing: mirror.subjectType) == String(describing: AbstractModel.self) {
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
            } else if let _ = modelType.resolver?.resolve(type: propertyType) as? StringRepresentable.Type {
                Log.debug("representable")
            } else {
                coder.encode(child.value, forKey: property)
            }
        }
    }
}
