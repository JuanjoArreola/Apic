//
//  AbstractModel.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation

protocol InitializableWithDictionary {
    init(dictionary: [String: AnyObject]) throws
}

public protocol InitializableWithString {
    init?(string: String)
}

enum ModelError: ErrorType {
    case PropertyNotFound
    case DateError
}

public class AbstractModel: NSObject, InitializableWithDictionary {
    
    required convenience public init(dictionary: [String: AnyObject]) throws {
        self.init()
        let children = Mirror(reflecting: self).children
        for index in children.startIndex..<children.endIndex {
            let child = children[index]
            guard let name = child.label else {
                continue
            }
//            if name == "super" {
//                continue
//            }
            
            switch Mirror(reflecting:child.value).subjectType {
            case _ as String?.Type:
                if let value = dictionary[name] as? String {
                    setValue(value, forKey: name)
                }
            case _ as String.Type:
                if let value = dictionary[name] as? String {
                    setValue(value, forKey: name)
                } else {
                    throw ModelError.PropertyNotFound
                }
                
            case _ as Int?.Type:
                if let value = dictionary[name] {
                    try assignValue(value, forKey: name)
                }
            case _ as Int.Type:
                if let value = dictionary[name] as? Int {
                    setValue(value, forKey: name)
                } else {
                    throw ModelError.PropertyNotFound
                }
                
            case _ as Float?.Type:
                if let value = dictionary[name] {
                    try assignValue(value, forKey: name)
                } else if let value = dictionary[name] as? String {
                    if let float = AbstractModel.floatValue(string: value) {
                        try assignValue(float, forKey: name)
                    }
                }
            case _ as Float.Type:
                if let value = dictionary[name] as? Float {
                    setValue(value, forKey: name)
                } else if let value = dictionary[name] as? String {
                    if let float = AbstractModel.floatValue(string: value) {
                        try assignValue(float, forKey: name)
                    }
                }
                else {
                    throw ModelError.PropertyNotFound
                }
                
            case _ as Bool?.Type:
                if let value = dictionary[name] {
                    try assignValue(value, forKey: name)
                }
            case _ as Bool.Type:
                if let value = dictionary[name] as? Bool {
                    setValue(value, forKey: name)
                } else {
                    throw ModelError.PropertyNotFound
                }
                
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
                } else {
                    throw ModelError.PropertyNotFound
                }
                
            default:
                if let value: AnyObject = dictionary[name] {
                    try assignValue(value, forKey: name)
                }
            }
        }
    }
    
    func assignValue(value: AnyObject, forKey key: String) throws { }
    
    private static var formatter: NSNumberFormatter = {
        var formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
        }()
    
    private class func floatValue(string string: String) -> Float? {
        let number = formatter.numberFromString(string)
        return number?.floatValue
    }
    
    private static var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.dateFormat = ""
        return formatter
    }()
    
    private class func dateFromString(string: String) -> NSDate? {
        return dateFormatter.dateFromString(string)
    }
}

public func createType<T: InitializableWithString>(type: T.Type, withString string: String?) -> T? {
    if let value = string {
        return T(string: value)
    }
    return nil
}