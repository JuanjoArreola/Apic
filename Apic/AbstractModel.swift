//
//  AbstractModel.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation

protocol InitializableWithDictionary {
    init?(dictionary: Dictionary<String, AnyObject>)
}

public protocol InitializableWithString {
    init?(string: String)
}

public class AbstractModel: NSObject, InitializableWithDictionary {
    
    required convenience public init?(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        let mirror = reflect(self)
        for index in 0..<mirror.count {
            let (name, childMirror) = mirror[index]
            if name == "super" {
                continue
            }
            
            switch childMirror.valueType {
            case let type as String?.Type:
                if let value = dictionary[name] as? String {
                    self.setValue(value, forKey: name)
                }
            case let type as String.Type:
                if let value = dictionary[name] as? String {
                    self.setValue(value, forKey: name)
                } else {
                    return nil
                }
                
            case let type as Int?.Type:
                if let value = dictionary[name] as? Int {
                    assignValue(value, forKey: name)
                }
            case let type as Int.Type:
                if let value = dictionary[name] as? Int {
                    self.setValue(value, forKey: name)
                } else {
                    return nil
                }
                
            case let type as Float?.Type:
                if let value = dictionary[name] as? Float {
                    assignValue(value, forKey: name)
                } else if let value = dictionary[name] as? String {
                    if let float = AbstractModel.floatValue(string: value) {
                        assignValue(float, forKey: name)
                    }
                }
            case let type as Float.Type:
                if let value = dictionary[name] as? Float {
                    self.setValue(value, forKey: name)
                } else if let value = dictionary[name] as? String {
                    if let float = AbstractModel.floatValue(string: value) {
                        assignValue(float, forKey: name)
                    }
                }
                else {
                    return nil
                }
                
            case let type as Bool?.Type:
                if let value = dictionary[name] as? Bool {
                    assignValue(value, forKey: name)
                }
            case let type as Bool.Type:
                if let value = dictionary[name] as? Bool {
                    self.setValue(value, forKey: name)
                } else {
                    return nil
                }
                
            default:
                if let value: AnyObject = dictionary[name] {
                    if !assignValue(value, forKey: name) {
                        return nil
                    }
                }
            }
        }
    }
    
    func assignValue<T>(value: T, forKey key: String) -> Bool {
        return true
    }
    
    private static var formatter: NSNumberFormatter = {
        var formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        return formatter
        }()
    
    private class func floatValue(#string: String) -> Float? {
        let number = formatter.numberFromString(string)
        return number?.floatValue
    }
}

public func createType<T: InitializableWithString>(type: T.Type, withString string: String?) -> T? {
    if let value = string {
        return T(string: value)
    }
    return nil
}