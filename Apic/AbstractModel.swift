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
    init(dictionary: [String: AnyObject]) throws
}

public protocol StringInitializable {
    init?(rawValue: String)
}

public protocol IntInitializable {
    init?(rawValue: Int)
}

protocol StringRepresentable: StringInitializable {
    var rawValue: String { get }
}

public protocol TypeResolver {
    func resolveType(type: Any) -> Any?
    
    func resolveTypeForName(typeName: String) -> Any?
}

public extension TypeResolver {
    func resolveTypeForName(typeName: String) -> Any? {
        return nil
    }
}

public protocol DynamicTypeModel {
    static var typeNameProperty: String { get }
}

public enum ModelError: ErrorType {
    case SourceValueError(property: String)
    case ValueTypeError(property: String?)
    case DateError(property: String?, value: String?)
    case URLError(property: String?, value: String?)
    case InstanciationError
    case InvalidProperty(property: String)
    case UndefinedType(type: Any.Type)
    case UndefinedTypeName(typeName: String)
    case UnasignedInstance(property: String)
}

/// Abstract model that provides the parsing functionality for subclasses
public class AbstractModel: NSObject, InitializableWithDictionary {
    
    public class var descriptionProperty: String { return "" }
    public class var resolver: TypeResolver? { return nil }
    public class var ignoredProperties: [String] { return [] }
    
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
        
        let modelType = mirror.subjectType as! AbstractModel.Type

        for child in mirror.children {
            guard let property = child.label else {
                continue
            }
            if modelType.ignoredProperties.contains(property) {
                continue
            }
            let propertyType = Mirror(reflecting:child.value).subjectType
            let rawValue = property == modelType.descriptionProperty ? dictionary["description"] : dictionary[property]
            
            if rawValue == nil {
                if self.shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }

//          MARK: - String
            if propertyType is String?.Type || propertyType is String.Type {
                if let value = rawValue as? String {
                    try assignValue(value, forProperty: property)
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
                
//          MARK: - [String]
            else if propertyType is [String]?.Type || propertyType is [String].Type {
                if let array = rawValue as? [String] {
                    try assignValue(array, forProperty: property)
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
//          MARK: - Int
            else if propertyType is Int?.Type || propertyType is Int.Type {
                if let value: Int = convertValue(rawValue) {
                    try assignValue(value, forProperty: property)
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
                
//          MARK: - [Int]
            
            else if propertyType is [Int]?.Type || propertyType is [Int].Type {
                if let array = rawValue as? [AnyObject] {
                    var newArray = [Int]()
                    for value in array {
                        if let intValue: Int = convertValue(value) {
                            newArray.append(intValue)
                        } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                            throw ModelError.SourceValueError(property: property)
                        }
                    }
                    try assignValue(newArray, forProperty: property)
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
//          MARK: - Float
            else if propertyType is Float?.Type || propertyType is Float.Type {
                if let value: Float = convertValue(rawValue) {
                    try assignValue(value, forProperty: property)
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
                
//          MARK: - [Float]
                
            else if propertyType is [Float]?.Type || propertyType is [Float].Type {
                if let array = rawValue as? [AnyObject] {
                    var newArray = [Float]()
                    for value in array {
                        if let floatValue: Float = convertValue(value) {
                            newArray.append(floatValue)
                        } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                            throw ModelError.SourceValueError(property: property)
                        }
                    }
                    try assignValue(newArray, forProperty: property)
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
//          MARK: - Double
            else if propertyType is Double?.Type || propertyType is Double.Type {
                if let value: Double = convertValue(rawValue) {
                    try assignValue(value, forProperty: property)
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
                
//          MARK: - [Double]
                
            else if propertyType is [Double]?.Type || propertyType is [Double].Type {
                if let array = rawValue as? [AnyObject] {
                    var newArray = [Double]()
                    for value in array {
                        if let doubleValue: Double = convertValue(value) {
                            newArray.append(doubleValue)
                        } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                            throw ModelError.SourceValueError(property: property)
                        }
                    }
                    try assignValue(newArray, forProperty: property)
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
//          MARK: - Bool
            else if propertyType is Bool?.Type || propertyType is Bool.Type {
                if let value: Bool = convertValue(rawValue) {
                    try assignValue(value, forProperty: property)
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
                
//          MARK: - [Bool]
                
            else if propertyType is [Bool]?.Type || propertyType is [Bool].Type {
                if let array = rawValue as? [AnyObject] {
                    var newArray = [Bool]()
                    for value in array {
                        if let boolValue: Bool = convertValue(value) {
                            newArray.append(boolValue)
                        } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                            throw ModelError.SourceValueError(property: property)
                        }
                    }
                    try assignValue(newArray, forProperty: property)
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
//          MARK: - NSDate
            else if propertyType is NSDate?.Type || propertyType is NSDate.Type {
                if let value = rawValue as? String {
                    if let date = AbstractModel.dateFromString(value) {
                        try assignValue(date, forProperty: property)
                    } else if shouldFailWithInvalidValue(value, forProperty: property) {
                        throw ModelError.DateError(property: property, value: value)
                    }
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
                
//          MARK: - NSDecimalNumber
            else if propertyType is NSDecimalNumber?.Type || propertyType is NSDecimalNumber.Type {
                if let value = rawValue as? Double {
                    try assignValue(NSDecimalNumber(double: value), forProperty: property)
                }
                else if let value = rawValue as? String {
                    let number = NSDecimalNumber(string: value)
                    if number != NSDecimalNumber.notANumber() {
                        try assignValue(number, forProperty: property)
                    } else if shouldFailWithInvalidValue(number, forProperty: property) {
                        throw ModelError.SourceValueError(property: property)
                    }
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
                
//          MARK: - NSURL
            else if propertyType is NSURL?.Type || propertyType is NSURL.Type {
                if let value = rawValue as? String {
                    if let url = NSURL(string: value) {
                        try assignValue(url, forProperty: property)
                    } else {
                        throw ModelError.URLError(property: property, value: value)
                    }
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
//          MARK: - Color
                
            else if propertyType is Color?.Type || propertyType is Color.Type {
                if let value = rawValue as? String {
                    if let color = Color(hex: value) {
                        try assignValue(color, forProperty: property)
                    } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                        throw ModelError.SourceValueError(property: property)
                    }
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
//          MARK: - [:]
            else if let value = rawValue as? [String: AnyObject] {
                
//              MARK: AbstractModel
                if let propertyType = modelType.resolver?.resolveType(propertyType) as? InitializableWithDictionary.Type {
                    let obj = try propertyType.init(dictionary: value)
                    try assignInstance(obj, forProperty: property)
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.UndefinedType(type: propertyType)
                } else if valueForKey(property) == nil {
                    Log.warn("Unresolved type <\(propertyType)> for property <\(property)> of model <\(self.dynamicType)>")
                }
            }
            
//          MARK: - [[:]]
            else if let array = rawValue as? [[String: AnyObject]] {
                
//              MARK: [AbstractModel]
                if let propertyType = modelType.resolver?.resolveType(propertyType) as? AbstractModel.Type {
                    do {
                        var newArray = [AbstractModel]()
                        if let propertyType = propertyType as? DynamicTypeModel.Type {
                            for item in array {
                                if let typeName = item[propertyType.typeNameProperty] as? String {
                                    if let itemType = modelType.resolver?.resolveTypeForName(typeName) as? AbstractModel.Type {
                                        newArray.append(try itemType.init(dictionary: item))
                                    } else {
                                        Log.warn("Unresolved type <\(typeName)> for property <\(property)> of model <\(self.dynamicType)>")
                                        if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                                            throw ModelError.UndefinedTypeName(typeName: typeName)
                                        }
                                    }
                                } else {
                                    Log.warn("Dynamic item has no type info")
                                    if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                                        throw ModelError.InvalidProperty(property: property)
                                    }
                                }
                            }
                        } else {
                            for item in array {
                                newArray.append(try propertyType.init(dictionary: item))
                            }
                        }
                        
                        try assignValue(newArray, forProperty: property)
                    } catch {
                        if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                            throw error
                        }
                    }
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.UndefinedType(type: propertyType)
                } else if valueForKey(property) == nil {
                    Log.warn("Unresolved type <\(propertyType)> for property <\(property)> of model <\(self.dynamicType)>")
                }
            }
                
//          MARK: - StringInitializable
            else if let propertyType = modelType.resolver?.resolveType(propertyType) as? StringInitializable.Type {
                if let string = rawValue as? String {
                    if let value = propertyType.init(rawValue: string) {
                        try assignInstance(value, forProperty: property)
                    }
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
//          MARK: - IntInitializable
            else if let propertyType = modelType.resolver?.resolveType(propertyType) as? IntInitializable.Type {
                if let value: Int = convertValue(rawValue) {
                    if let value = propertyType.init(rawValue: value) {
                        try assignInstance(value, forProperty: property)
                    }
                } else if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
            
            else {
                if let value = rawValue {
                    try assignUndefinedValue(value, forProperty: property)
                }
                if shouldFailWithInvalidValue(rawValue, forProperty: property) {
                    throw ModelError.SourceValueError(property: property)
                }
            }
        }
    }
    
    /// Override this method in subclasses to assign the value of properties of type:
    /// Int?, Int!, Float?, Float!, Double?, Double!, Bool?, Bool!
    /// - parameter value: the value to assign
    /// - parameter forKey: the name of the property to set
    public func assignValue(value: AnyObject, forProperty property: String) throws {
        setValue(value, forKey: property)
    }
    
    public func assignInstance(instance: Any, forProperty property: String) throws {
        if let object = instance as? AnyObject {
            setValue(object, forKey: property)
        } else {
            throw ModelError.UnasignedInstance(property: property)
        }
    }
    
    /// Override this method in subclasses to assign a value of an undefined type to a property
    /// - parameter value: the value to be assigned
    /// - parameter key: the name of the property to assign
    public func assignUndefinedValue(undefinedValue: AnyObject, forProperty property: String) throws {}
    
    /// Override this method in subclasses and return true if the object is invalid if a value couln't be parsed for a property
    public func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return false
    }
    
    private static var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = Configuration.locale
        formatter.dateFormat = Configuration.dateFormats.first
        return formatter
    }()
    
    public class func dateFromString(string: String) -> NSDate? {
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
    
    /// This function tries to convert a value of type `AnyObject?` to a value of type `T: StringInitializable`
    /// - parameter value: the value to be converted
    /// - returns: a value of type T or nil if the original value couln't be cenverted
    private func convertValue<T: StringInitializable>(value: AnyObject?) -> T? {
        if let val = value {
            if let v = val as? T {
                return v
            }
            if let string = val as? String {
                return T(rawValue: string)
            }
            Log.warn("\(self.dynamicType): value: \(val) couldn't be converted to \(T.self)")
        }
        return nil
    }

}

extension Int: StringInitializable {
    public init?(rawValue: String) {
        self.init(rawValue)
    }
}

extension Float: StringInitializable {
    public init?(rawValue: String) {
        self.init(rawValue)
    }
}

extension Double: StringInitializable {
    public init?(rawValue: String) {
        self.init(rawValue)
    }
}

extension Color {
    convenience init?(hex: String) {
        var format = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        format = (format.hasPrefix("#")) ? format.substringFromIndex(format.startIndex.advancedBy(1)) : format
        
        var value: UInt32 = 0
        if NSScanner(string: format).scanHexInt(&value) {
            if format.characters.count == 8 {
                self.init(red: CGFloat((value & 0xFF000000) >> 24) / 255.0,
                    green: CGFloat((value & 0x00FF0000) >> 16) / 255.0,
                    blue: CGFloat((value & 0x0000FF00) >> 8) / 255.0,
                    alpha: CGFloat((value & 0x000000FF)) / 255.0)
                return
            } else if format.characters.count == 6 {
                self.init(red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
                    green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
                    blue: CGFloat(value & 0x0000FF) / 255.0,
                    alpha: 1.0)
                return
            }
        }
        self.init()
        return nil
    }
}

extension Bool: StringInitializable {
    public init?(rawValue: String) {
        switch rawValue {
        case "true", "True", "1":
            self = true
        case "false", "False", "0":
            self = false
        default:
            return nil
        }
    }
}
