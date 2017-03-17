//
//  Bool+AnyMatchInitialize.swift
//  Apic
//
//  Created by Juan Jose Arreola on 16/03/17.
//
//

import Foundation

extension Bool: AnyInitializable {
    
    init?(value: Any?) {
        if let bool = value as? Bool {
            self = bool
        }
        else if let string = value as? String {
            switch string.lowercased() {
            case "true", "t", "1":
                self = true
            case "false", "f", "0":
                self = false
            default:
                return nil
            }
        }
        else if let number = value as? NSNumber {
            self = number.boolValue
        }
        else {
            return nil
        }
    }
}

extension Bool: TypeMatchable {
    
    static func match(type: Any.Type) -> Bool {
        return type is Bool.Type || type is Bool?.Type || type is ImplicitlyUnwrappedOptional<Bool>.Type
    }
    
    static func matchArray(type: Any.Type) -> Bool {
        return type is [Bool].Type || type is [Bool]?.Type || type is ImplicitlyUnwrappedOptional<[Bool]>.Type
    }
    
    static func optionalityMatch(type: Any.Type) -> OptionalityType? {
        if type is Bool.Type { return .notOptional }
        if type is Bool?.Type { return .optional }
        if type is ImplicitlyUnwrappedOptional<Bool>.Type { return .implicitlyUnwrapped }
        return nil
    }
}

extension Bool: AnyMatchInitialize {}
