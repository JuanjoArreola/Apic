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

public protocol InitializableWithString {
    init?(string: String)
}

public enum ModelError: ErrorType {
    case ValueTypeError(property: String?)
    case DateError
    case InstanciationError
    case InvalidProperty(property: String)
}

public class AbstractModel: NSObject, InitializableWithDictionary {
    
    override init() {
        super.init()
    }
    
    public required convenience init(dictionary: [String: AnyObject]) throws {
        self.init()
        let children = Mirror(reflecting: self).children
        for index in children.startIndex..<children.endIndex {
            let child = children[index]
            guard let name = child.label else {
                continue
            }
            
            switch Mirror(reflecting:child.value).subjectType {
            case _ as String?.Type:
                if let value = dictionary[name] as? String {
                    setValue(value, forKey: name)
                }
            case _ as String.Type:
                if let value = dictionary[name] as? String {
                    setValue(value, forKey: name)
                } else if valueForKey(name) == nil {
                    throw ModelError.ValueTypeError(property: name)
                }
                
//          MARK: - Int
            case _ as Int?.Type:
                if let value: Int = convertValue(dictionary[name]) {
                    try assignValue(value, forKey: name)
                }
            case _ as Int.Type:
                if let value: Int = convertValue(dictionary[name]) {
                    setValue(value, forKey: name)
                } else if valueForKey(name) == nil {
                    throw ModelError.ValueTypeError(property: name)
                }
                
//          MARK: - Float
            case _ as Float?.Type:
                if let value: Float = convertValue(dictionary[name]) {
                    try assignValue(value, forKey: name)
                }
            case _ as Float.Type:
                if let value: Float = convertValue(dictionary[name]) {
                    setValue(value, forKey: name)
                }
                else if valueForKey(name) == nil {
                    throw ModelError.ValueTypeError(property: name)
                }
                
//          MARK: - Double
            case _ as Double?.Type:
                if let value: Double = convertValue(dictionary[name]) {
                    try assignValue(value, forKey: name)
                }
            case _ as Double.Type:
                if let value: Double = convertValue(dictionary[name]) {
                    setValue(value, forKey: name)
                }
                else if valueForKey(name) == nil {
                    throw ModelError.ValueTypeError(property: name)
                }
                
//          MARK: - Bool
                
            case _ as Bool?.Type:
                if let value: Bool = convertValue(dictionary[name]) {
                    try assignValue(value, forKey: name)
                }
            case _ as Bool.Type:
                if let value: Bool = convertValue(dictionary[name]) {
                    setValue(value, forKey: name)
                } else if valueForKey(name) == nil {
                    throw ModelError.ValueTypeError(property: name)
                }
                
//          MARK: - Date
                
            case _ as NSDate?.Type:
                if let value = dictionary[name] as? String {
                    if let date = AbstractModel.dateFromString(value) {
                        try assignValue(date, forKey: name)
                    }
                }
            case _ as NSDate.Type:
                if let value = dictionary[name] as? String {
                    if let date = AbstractModel.dateFromString(value) {
                        setValue(date, forKey: name)
                    } else {
                        throw ModelError.DateError
                    }
                } else if valueForKey(name) == nil {
                    throw ModelError.ValueTypeError(property: name)
                }
                
//          MARK: - InitializableWithDictionary
                
            case let type as InitializableWithDictionary?.Type:
                if let value = dictionary[name] as? [String: AnyObject] {
                    let obj = try (type as! InitializableWithDictionary.Type).init(dictionary: value)
                    try assignValue((obj as! AnyObject), forKey: name)
                }
            case let type as InitializableWithDictionary.Type:
                if let value = dictionary[name] as? [String: AnyObject] {
                    let obj = try type.init(dictionary: value)
                    setValue((obj as! AnyObject), forKey: name)
                } else if valueForKey(name) == nil {
                    throw ModelError.ValueTypeError(property: name)
                }
                
            default:
                if let value: AnyObject = dictionary[name] {
                    try assignValue(value, forKey: name)
                }
            }
        }
    }
    
    /// Override this method in subclasses to assign the value of optional properties
    /// - parameter value: the value to assign
    /// - parameter forKey: the name of the property to set
    public func assignValue(value: AnyObject, forKey key: String) throws { }
    
    func parseArray<T: InitializableWithDictionary>(array: [AnyObject], type: [T].Type) throws -> [T] {
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
        formatter.dateFormat = Configuration.dateFormat
        return formatter
    }()
    
    private class func dateFromString(string: String) -> NSDate? {
        return dateFormatter.dateFromString(string)
    }
}

public func createType<T: RawRepresentable>(withValue value: AnyObject?) -> T? {
    if let value = value as? T.RawValue {
        return T(rawValue: value)
    }
    return nil
}

private func convertValue<T: InitializableWithString>(value: AnyObject?) -> T? {
    if let val = value {
        if let v = val as? T {
            return v
        }
        if let string = val as? String {
            return T(string: string)
        }
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

