//
//  String+AnyMatchBuilder.swift
//  Apic
//
//  Created by Juan Jose Arreola on 17/03/17.
//
//

import Foundation

extension String: AnyInitializable, FromAnyBuilder {
    
    public static func build(value: Any) -> String? {
        return String(value: value)
    }
    
    public init?(value: Any) {
        if let string = value as? String {
            self = string
        } else {
            return nil
        }
    }
}

extension String: TypeMatchable {
    
    public static func match(type: Any.Type) -> Bool {
        return type is String.Type || type is String?.Type || type is ImplicitlyUnwrappedOptional<String>.Type
    }
    
    public static func matchArray(type: Any.Type) -> Bool {
        return type is [String].Type || type is [String]?.Type || type is ImplicitlyUnwrappedOptional<[String]>.Type
    }
    
    public static func optionalityMatch(type: Any.Type) -> OptionalityType? {
        if type is String.Type { return .notOptional }
        if type is String?.Type { return .optional }
        if type is ImplicitlyUnwrappedOptional<String>.Type { return .implicitlyUnwrapped }
        return nil
    }
}

extension String: AnyMatchBuilder {}
