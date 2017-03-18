//
//  Float+AnyMatchBuilder.swift
//  Apic
//
//  Created by Juan Jose Arreola on 16/03/17.
//
//

import Foundation

extension Float: AnyInitializable, FromAnyBuilder {
    
    static func build(value: Any) -> Float? {
        return Float(value: value)
    }
    
    init?(value: Any) {
        if let float = value as? Float {
            self = float
        }
        if let double = value as? Double {
            self = Float(double)
        }
        else if let string = value as? String {
            if let float = Float(string) {
                self = float
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

extension Float: TypeMatchable {
    
    static func match(type: Any.Type) -> Bool {
        return type is Float.Type || type is Float?.Type || type is ImplicitlyUnwrappedOptional<Float>.Type
    }
    
    static func matchArray(type: Any.Type) -> Bool {
        return type is [Float].Type || type is [Float]?.Type || type is ImplicitlyUnwrappedOptional<[Float]>.Type
    }
    
    static func optionalityMatch(type: Any.Type) -> OptionalityType? {
        if type is Float.Type { return .notOptional }
        if type is Float?.Type { return .optional }
        if type is ImplicitlyUnwrappedOptional<Float>.Type { return .implicitlyUnwrapped }
        return nil
    }
}

extension Float: AnyMatchBuilder {}
