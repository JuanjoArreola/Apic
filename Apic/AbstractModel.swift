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

public protocol TypeResolver {
    func resolve(type: Any) -> Any?
    func resolve(typeForName typeName: String) -> Any?
    func resolveDictionary(type: Any) -> Any?
}

public protocol DynamicTypeModel {
    static var typeNameProperty: String { get }
}

// MARK: - Error

public enum ModelError: Error {
    case sourceValueError(property: String, model: String, value: String?)
    case serializationError(property: String, model: String)
    case valueTypeError(property: String?)
    case dateError(property: String?, value: String?)
    case urlError(property: String?, value: String?)
    case instanciationError
    case invalidProperty(property: String)
    case undefinedType(type: Any.Type)
    case undefinedTypeName(typeName: String)
    case unasignedInstance(property: String)
}

/// Abstract model that provides the parsing functionality for subclasses
open class AbstractModel: NSObject, InitializableWithDictionary, NSCoding {
    
    open class var propertyKeys: [String: String] { return [:] }
    open class var propertyDateFormats: [String: String] { return [:] }
    
    open class var resolver: TypeResolver? { return nil }
    open class var ignoredProperties: [String] { return [] }
    
    @available(*, deprecated: 3.2.0, message: "use propertyDateFormats instead")
    open class var dateFormats: [String] { return Configuration.dateFormats }
    
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
        let modelName = String(describing: modelType)
        
        guard let rawValue = optionalRawValue else {
            if self.shouldFail(withInvalidValue: nil, forProperty: property) {
                throw ModelError.sourceValueError(property: property, model: modelName, value: nil)
            } else {
                return
            }
        }
        
//      MARK: - String
        if propertyType is String.Type || propertyType is String?.Type || propertyType is ImplicitlyUnwrappedOptional<String>.Type {
            if let value = rawValue as? String {
                setValue(value, forKey: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - [String]
        else if propertyType is [String].Type || propertyType is [String]?.Type || propertyType is ImplicitlyUnwrappedOptional<[String]>.Type {
            if let array = rawValue as? [String] {
                setValue(array, forKey: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - Int
        else if propertyType is Int.Type {
            if let value: Int = convert(value: rawValue) {
                setValue(value, forKey: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
        else if propertyType is Int?.Type || propertyType is ImplicitlyUnwrappedOptional<Int>.Type {
            if let value: Int = convert(value: rawValue) {
                try assign(value: value, forProperty: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
        
//      MARK: - [Int]
        else if propertyType is [Int]?.Type || propertyType is [Int].Type || propertyType is ImplicitlyUnwrappedOptional<[Int]>.Type {
            if let array = rawValue as? [Any] {
                var newArray = [Int]()
                for value in array {
                    if let intValue: Int = convert(value: value) {
                        newArray.append(intValue)
                    } else {
                        try assign(undefinedValue: array, forProperty: property)
                        return
                    }
                }
                setValue(newArray, forKey: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - Float
        else if propertyType is Float.Type {
            if let value = Float(value: rawValue) {
                setValue(value, forKey: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
        else if propertyType is Float?.Type || propertyType is ImplicitlyUnwrappedOptional<Float>.Type {
            if let value = Float(value: rawValue) {
                try assign(value: value, forProperty: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - [Float]
        else if propertyType is [Float]?.Type || propertyType is [Float].Type || propertyType is ImplicitlyUnwrappedOptional<[Float]>.Type {
            if let array = rawValue as? [Any] {
                var newArray = [Float]()
                for value in array {
                    if let floatValue = Float(value: value) {
                        newArray.append(floatValue)
                    } else {
                        try assign(undefinedValue: array, forProperty: property)
                        return
                    }
                }
                setValue(newArray, forKey: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - Double
        else if propertyType is Double.Type {
            if let value: Double = convert(value: rawValue) {
                setValue(value, forKey: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
        else if propertyType is Double?.Type || propertyType is ImplicitlyUnwrappedOptional<Double>.Type {
            if let value: Double = convert(value: rawValue) {
                try assign(value: value, forProperty: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - [Double]
        else if propertyType is [Double]?.Type || propertyType is [Double].Type || propertyType is ImplicitlyUnwrappedOptional<[Double]>.Type {
            if let array = rawValue as? [Any] {
                var newArray = [Double]()
                for value in array {
                    if let doubleValue: Double = convert(value: value) {
                        newArray.append(doubleValue)
                    } else {
                        try assign(undefinedValue: array, forProperty: property)
                        return
                    }
                }
                setValue(newArray, forKey: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - Bool
        else if propertyType is Bool.Type {
            if let value = Bool(value: rawValue) {
                setValue(value, forKey: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
        else if propertyType is Bool?.Type || propertyType is ImplicitlyUnwrappedOptional<Bool>.Type {
            if let value = Bool(value: rawValue) {
                try assign(value: value, forProperty: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - [Bool]
            
        else if propertyType is [Bool]?.Type || propertyType is [Bool].Type || propertyType is ImplicitlyUnwrappedOptional<[Bool]>.Type {
            if let array = rawValue as? [Any] {
                var newArray = [Bool]()
                for value in array {
                    if let boolValue = Bool(value: value) {
                        newArray.append(boolValue)
                    } else {
                        try assign(undefinedValue: array, forProperty: property)
                        return
                    }
                }
                setValue(newArray, forKey: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - Date
        else if propertyType is Date?.Type || propertyType is Date.Type || propertyType is ImplicitlyUnwrappedOptional<Date>.Type {
            if let value = rawValue as? String {
                if let date = type(of: self).date(from: value, property: property) {
                    setValue(date, forKey: property)
                } else {
                    do {
                        try assign(undefinedValue: rawValue, forProperty: property)
                    } catch {
                        throw ModelError.dateError(property: property, value: value)
                    }
                }
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - NSDecimalNumber
        else if propertyType is NSDecimalNumber?.Type || propertyType is NSDecimalNumber.Type || propertyType is ImplicitlyUnwrappedOptional<NSDecimalNumber>.Type {
            if let value = rawValue as? Double {
                setValue(NSDecimalNumber(value: value), forKey: property)
            }
            else if let value = rawValue as? Int {
                setValue(NSDecimalNumber(value: value), forKey: property)
            }
            else if let value = rawValue as? Bool {
                setValue(NSDecimalNumber(value: value), forKey: property)
            }
            else if let value = rawValue as? String {
                let number = NSDecimalNumber(string: value)
                if number != NSDecimalNumber.notANumber {
                    setValue(number, forKey: property)
                } else {
                    try assign(undefinedValue: rawValue, forProperty: property)
                }
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - URL
        else if propertyType is URL?.Type || propertyType is URL.Type || propertyType is ImplicitlyUnwrappedOptional<URL>.Type {
            if let value = rawValue as? String {
                if let url = URL(string: value) {
                    setValue(url, forKey: property)
                } else {
                    try assign(undefinedValue: rawValue, forProperty: property)
                }
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - Color
        else if propertyType is Color?.Type || propertyType is Color.Type || propertyType is ImplicitlyUnwrappedOptional<Color>.Type {
            if let value = rawValue as? String {
                if let color = Color(hex: value) {
                    setValue(color, forKey: property)
                } else {
                    try assign(undefinedValue: rawValue, forProperty: property)
                }
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - [:]
        else if propertyType is [String: String].Type || propertyType is [String: String]?.Type || propertyType is ImplicitlyUnwrappedOptional<[String: String]>.Type {
            if let value = rawValue as? [String: String] {
                setValue(value, forKey: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
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
                                Log.warn("Unresolved type <\(typeName)> for property <\(property)> of model <\(type(of: self))>")
                                if shouldFail(withInvalidValue: rawValue, forProperty: property) {
                                    throw ModelError.undefinedTypeName(typeName: typeName)
                                }
                            }
                        } else {
                            Log.warn("Dynamic item has no type info")
                            if shouldFail(withInvalidValue: rawValue, forProperty: property) {
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
                setValue(obj, forKey: property)
            } else {
                Log.warn("Unresolved type <\(propertyType)> for property <\(property)> of model <\(type(of: self))>")
                try assign(undefinedValue: rawValue, forProperty: property)
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
                                    if shouldFail(withInvalidValue: rawValue, forProperty: property) {
                                        throw ModelError.undefinedTypeName(typeName: typeName)
                                    }
                                }
                            } else {
                                Log.warn("Dynamic item has no type info")
                                if shouldFail(withInvalidValue: rawValue, forProperty: property) {
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
                    if shouldFail(withInvalidValue: rawValue, forProperty: property) {
                        throw error
                    }
                }
            } else {
                Log.warn("Unresolved type <\(propertyType)> for property <\(property)> of model <\(type(of: self))>")
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - StringInitializable
        else if let propertyType = modelType.resolver?.resolve(type: propertyType) as? StringInitializable.Type {
            if let string = rawValue as? String {
                if let value = propertyType.init(rawValue: string) {
                    try assign(value: value, forProperty: property)
                } else {
                    try assign(undefinedValue: rawValue, forProperty: property)
                }
            } else if let array = rawValue as? [String] {
                var newArray: [StringInitializable] = []
                for value in array {
                    if let value = propertyType.init(rawValue: value) {
                        newArray.append(value)
                    } else {
                        try assign(undefinedValue: array, forProperty: property)
                        return
                    }
                }
                try assign(value: newArray, forProperty: property)
            }
            else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
//      MARK: - IntInitializable
        else if let propertyType = modelType.resolver?.resolve(type: propertyType) as? IntInitializable.Type {
            if let value: Int = convert(value: rawValue) {
                if let value = propertyType.init(rawValue: value) {
                    try assign(value: value, forProperty: property)
                } else {
                    try assign(undefinedValue: rawValue, forProperty: property)
                }
            } else if let array = rawValue as? [Any] {
                var newArray: [IntInitializable] = []
                for value in array {
                    if let int: Int = convert(value: value), let initializable = propertyType.init(rawValue: int) {
                        newArray.append(initializable)
                    } else {
                        try assign(undefinedValue: array, forProperty: property)
                        return
                    }
                }
                try assign(value: newArray, forProperty: property)
            } else {
                try assign(undefinedValue: rawValue, forProperty: property)
            }
        }
            
        else {
            try assign(undefinedValue: rawValue, forProperty: property)
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
    
    /// Override this method in subclasses to assign a value of an undefined type to a property
    /// - parameter value: the value to be assigned
    /// - parameter key: the name of the property to assign
    open func assign(undefinedValue: Any, forProperty property: String) throws {
        Log.warn("Could no parse value: <\(undefinedValue)> for property: <\(property)> of model: \(type(of: self))")
        if shouldFail(withInvalidValue: undefinedValue, forProperty: property) {
            throw ModelError.sourceValueError(property: property, model: String(describing: type(of: self)), value: String(describing: undefinedValue))
        }
    }
    
    /// Override this method in subclasses and return true if the object is invalid if a value couln't be parsed for a property
    open func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return true
    }
    
    // MARK: - Date
    
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Configuration.locale
        formatter.dateFormat = Configuration.dateFormats.first
        return formatter
    }()
    
    internal class func date(from string: String, property: String) -> Date? {
        if let format = propertyDateFormats[property] {
            dateFormatter.dateFormat = format
        }
        return date(from: string)
    }
    
    public class func date(from string: String) -> Date? {
        if let date = dateFormatter.date(from: string) {
            return date
        }
        for format in Configuration.dateFormats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: string) {
                return date
            }
        }
        return nil
    }
    
    internal class func string(from date: Date, property: String) -> String? {
        if let format = propertyDateFormats[property] ?? Configuration.dateFormats.first {
            dateFormatter.dateFormat = format
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    /// This function tries to convert a value of type `Any?` to a value of type `T: StringInitializable`
    /// - parameter value: the value to be converted
    /// - returns: a value of type T or nil if the original value couln't be cenverted
    private func convert<T: StringInitializable>(value: Any?) -> T? {
        if let val = value {
            if let v = val as? T {
                return v
            }
            if let string = val as? String {
                return T(rawValue: string)
            }
            Log.warn("\(type(of: self)): value: \(val) couldn't be converted to \(T.self)")
        }
        return nil
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

extension Mirror {
    var isAbstractModelMirror: Bool {
        return String(describing: self.subjectType) == String(describing: AbstractModel.self)
    }
}

extension Int: StringInitializable {
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
        var format = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        format = (format.hasPrefix("#")) ? format.substring(from: format.index(format.startIndex, offsetBy: 1)) : format
        
        var value: UInt32 = 0
        if Scanner(string: format).scanHexInt32(&value) {
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

extension Bool {
    init?(value: Any?) {
        if value == nil { return nil }
        if let bool = value as? Bool {
            self = bool
        }
        else if let string = value as? String {
            switch string {
            case "true", "True", "1":
                self = true
            case "false", "False", "0":
                self = false
            default:
                return nil
            }
        }
        else if let number = value as? NSNumber {
            self = Bool(number)
        }
        else {
            return nil
        }
    }
}

extension Float {
    init?(value: Any?) {
        if value == nil { return nil }
        if let float = value as? Float {
            self = float
        }
        else if let string = value as? String {
            if let float = Float(string) {
                self = float
            } else {
                return nil
            }
        }
        else if let double = value as? Double {
            self = Float(double)
        } else {
            return nil
        }
    }
}

extension Mirror {
    func findChild(withName name: String) -> Mirror.Child? {
        for child in children {
            if child.label == name {
                return child
            }
        }
        return nil
    }
}
