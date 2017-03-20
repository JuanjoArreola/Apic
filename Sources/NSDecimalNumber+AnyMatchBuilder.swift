
//
//  NSDecimalNumber+AnyMatchBuilder.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 3/18/17.
//
//

import Foundation

extension NSDecimalNumber: FromAnyBuilder {
    
    public static func build(value: Any) -> NSDecimalNumber? {
        if let double = value as? Double {
            return NSDecimalNumber(value: double)
        }
        else if let int = value as? Int {
            return NSDecimalNumber(value: int)
        }
        else if let bool = value as? Bool {
            return NSDecimalNumber(value: bool)
        }
        else if let string = value as? String {
            let number = NSDecimalNumber(string: string)
            if number == NSDecimalNumber.notANumber {
                return nil
            }
            return number
        }
        return nil
    }
}

extension NSDecimalNumber: TypeMatchable {
    
    public static func match(type: Any.Type) -> Bool {
        return type is NSDecimalNumber.Type || type is NSDecimalNumber?.Type || type is ImplicitlyUnwrappedOptional<NSDecimalNumber>.Type
    }
    
    public static func matchArray(type: Any.Type) -> Bool {
        return type is [NSDecimalNumber].Type || type is [NSDecimalNumber]?.Type || type is ImplicitlyUnwrappedOptional<[NSDecimalNumber]>.Type
    }
    
    public static func optionalityMatch(type: Any.Type) -> OptionalityType? {
        if type is NSDecimalNumber.Type { return .notOptional }
        if type is NSDecimalNumber?.Type { return .optional }
        if type is ImplicitlyUnwrappedOptional<NSDecimalNumber>.Type { return .implicitlyUnwrapped }
        return nil
    }
}

extension NSDecimalNumber: AnyMatchBuilder {}
