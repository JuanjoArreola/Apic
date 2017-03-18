//
//  String+AnyMatchBuilder.swift
//  Apic
//
//  Created by Juan Jose Arreola on 17/03/17.
//
//

import Foundation

extension String: AnyInitializable, FromAnyBuilder {
    
    static func build(value: Any) -> String? {
        return String(value: value)
    }
    
    init?(value: Any) {
        if let string = value as? String {
            self = string
        } else {
            return nil
        }
    }
}

extension String: TypeMatchable {
    
    static func match(type: Any.Type) -> Bool {
        return type is String.Type || type is String?.Type || type is ImplicitlyUnwrappedOptional<String>.Type
    }
    
    static func matchArray(type: Any.Type) -> Bool {
        return type is [String].Type || type is [String]?.Type || type is ImplicitlyUnwrappedOptional<[String]>.Type
    }
    
    static func optionalityMatch(type: Any.Type) -> OptionalityType? {
        if type is String.Type { return .notOptional }
        if type is String?.Type { return .optional }
        if type is ImplicitlyUnwrappedOptional<String>.Type { return .implicitlyUnwrapped }
        return nil
    }
}

extension String: AnyMatchBuilder {}
