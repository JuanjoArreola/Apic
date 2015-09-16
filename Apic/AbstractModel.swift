//
//  AbstractModel.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation

public protocol InitializableWithDictionary {
    init(dictionary: [String: AnyObject]) throws
}

public protocol AbstractModelContainer {
    static var modelProperties: [String: AbstractModel.Type] { get }
    static var arrayOfModelProperties: [String: AbstractModel.Type] { get }
}

public protocol InitializableWithString {
    init?(string: String)
}

public enum ModelError: ErrorType {
    case SourceValueError(property: String)
    case ValueTypeError(property: String?)
    case DateError
    case InstanciationError
    case InvalidProperty(property: String)
}

public class AbstractModel: NSObject, InitializableWithDictionary, AbstractModelContainer {
    
    public class var modelProperties: [String: AbstractModel.Type] { return [:] }
    public class var arrayOfModelProperties: [String: AbstractModel.Type] { return [:] }
    
    public override init() {
        super.init()
    }
    
    public required convenience init(dictionary: [String: AnyObject]) throws {
        self.init()
        
        let mirror = Mirror(reflecting: self)
        try initializePropertiesOfMirror(mirror, withDictionary: dictionary)
    }
    
    func initializePropertiesOfMirror(mirror: Mirror, withDictionary dictionary: [String: AnyObject]) throws {
        if String(mirror.subjectType) == String(AbstractModel) {
            return
        }
        if let superclassMirror = mirror.superclassMirror() {
            try initializePropertiesOfMirror(superclassMirror, withDictionary: dictionary)
        }
        
        let modelContainer = mirror.subjectType as! AbstractModelContainer.Type

        let children = mirror.children
        for index in children.startIndex..<children.endIndex {
            let child = children[index]
            guard let property = child.label else {
                continue
            }
            let type = Mirror(reflecting:child.value).subjectType

//          MARK: - String
            if type is String?.Type || type is String.Type {
                if let value = dictionary[property] as? String {
                    try assignValue(value, forProperty: property)
                } else if shouldFailWithInvalidValue(dictionary[property], forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
//          MARK: - Int
            else if type is Int?.Type || type is Int.Type {
                if let value: Int = convertValue(dictionary[property]) {
                    try assignValue(value, forProperty: property)
                } else if shouldFailWithInvalidValue(dictionary[property], forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
//          MARK: - Float
            else if type is Float?.Type || type is Float.Type {
                if let value: Float = convertValue(dictionary[property]) {
                    try assignValue(value, forProperty: property)
                } else if shouldFailWithInvalidValue(dictionary[property], forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
//          MARK: - Double
            else if type is Double?.Type || type is Double.Type {
                if let value: Double = convertValue(dictionary[property]) {
                    try assignValue(value, forProperty: property)
                } else if shouldFailWithInvalidValue(dictionary[property], forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
//          MARK: - Bool
            else if type is Bool?.Type || type is Bool.Type {
                if let value: Bool = convertValue(dictionary[property]) {
                    try assignValue(value, forProperty: property)
                } else if shouldFailWithInvalidValue(dictionary[property], forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
//          MARK: - Date
            else if type is NSDate?.Type || type is NSDate.Type {
                if let value = dictionary[property] as? String {
                    if let date = AbstractModel.dateFromString(value) {
                        try assignValue(date, forProperty: property)
                    } else if shouldFailWithInvalidValue(dictionary[property], forProperty: property) {
                        throw ModelError.DateError
                    }
                } else if shouldFailWithInvalidValue(dictionary[property], forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
                
//          MARK: - InitializableWithDictionary
            else if let propertyType = modelContainer.modelProperties[property] {
                if let value = dictionary[property] as? [String: AnyObject] {
                    let obj = try propertyType.init(dictionary: value)
                    try assignValue(obj, forProperty: property)
                } else if shouldFailWithInvalidValue(dictionary[property], forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
//          MARK: - [InitializableWithDictionary]
            else if let propertyType = modelContainer.arrayOfModelProperties[property] {
                if let array = dictionary[property] as? [[String: AnyObject]] {
                    do {
                        var newArray = [AbstractModel]()
                        for item in array {
                            newArray.append(try propertyType.init(dictionary: item))
                        }
                        try assignValue(newArray, forProperty: property)
                    } catch {
                        if shouldFailWithInvalidValue(dictionary[property], forProperty: property) {
                            throw error
                        }
                    }
                } else {
                    Log.warn("Potentially incorrect source data for property \(property) of model \(self.dynamicType)")
                    if shouldFailWithInvalidValue(dictionary[property], forProperty: property) {
                        throw ModelError.SourceValueError(property: property)
                    }
                }
            }
            
//          MARK: - Undefined Type
            else {
                if let value: AnyObject = dictionary[property] {
                    try assignUndefinedValue(value, forKey: property)
                }
            }
        }
    }
    
    /// Override this method in subclasses to assign the value of optional properties
    /// - parameter value: the value to assign
    /// - parameter forKey: the name of the property to set
    /// - note: `value` can be safely cast to the type of the key if is of type:
    /// String, Int, Float, Double, Bool or NSDate and optionally: InitializableWithDictionary,
    /// InitializableWithDictionary?, [InitializableWithDictionary] and [InitializableWithDictionary]?
    /// if the properties and their concret Types are registered in the properties of the protocol `AbstractModelContainer`
    public func assignValue(value: AnyObject, forProperty property: String) throws {
        setValue(value, forKey: property)
    }
    
    /// Override this method in subclasses to assign a value of an undefined type to a property
    /// - parameter value: the value to be assigned
    /// - parameter key: the name of the property to assign
    public func assignUndefinedValue(undefinedValue: AnyObject, forKey key: String) throws {}
    
    public func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool { return false }
    
    public func parseArray<T: InitializableWithDictionary>(array: [AnyObject]) throws -> [T] {
        var newArray = [T]()
        
        for item in array {
            if let dictionary = item as? [String: AnyObject] {
                let t = try T(dictionary: dictionary)
                newArray.append(t)
            } else {
                throw ModelError.InstanciationError
            }
        }
        return newArray
    }
    
    private static var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.dateFormat = Configuration.dateFormats.first
        return formatter
    }()
    
    private class func dateFromString(string: String) -> NSDate? {
        if let date = dateFormatter.dateFromString(string) {
            return date
        }
        for format in Configuration.dateFormats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.dateFromString(string) {
                return date
            }
        }
        return nil
    }
    
    /// This function tries to convert a value of type `AnyObject?` to a value of type `T: InitializableWithString`
    /// - parameter value: the value to be converted
    /// - returns: a value of type T or nil if the original value couln't be cenverted
    private func convertValue<T: InitializableWithString>(value: AnyObject?) -> T? {
        if let val = value {
            if let v = val as? T {
                return v
            }
            if let string = val as? String {
                return T(string: string)
            }
            Log.warn("\(self.dynamicType): value: \(val) couldn't be converted to \(T.self)")
        }
        return nil
    }
}

public func createType<T: RawRepresentable>(withValue value: AnyObject?) -> T? {
    if let value = value as? T.RawValue {
        return T(rawValue: value)
    }
    return nil
}

extension Int: InitializableWithString {
    public init?(string: String) {
        self.init(string)
    }
}

extension Float: InitializableWithString {
    public init?(string: String) {
        self.init(string)
    }
}

extension Double: InitializableWithString {
    public init?(string: String) {
        self.init(string)
    }
}

extension Bool: InitializableWithString {
    public init?(string: String) {
        switch string {
        case "true", "True", "1":
            self = true
        case "false", "False", "0":
            self = false
        default:
            return nil
        }
    }
}

