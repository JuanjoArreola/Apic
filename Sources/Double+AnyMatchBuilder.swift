//
//  Double+AnyMatchBuilder.swift
//  Apic
//
//  Created by Juan Jose Arreola on 17/03/17.
//
//

import Foundation

extension Double: AnyInitializable, FromAnyBuilder {
    
    public static func build(value: Any) -> Double? {
        return Double(value: value)
    }
    
    public init?(value: Any) {
        if let double = value as? Double {
            self = double
        }
        else if let string = value as? String {
            if let double = Double(string) {
                self = double
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

extension Double: TypeMatchable {
    
    public static func match(type: Any.Type) -> Bool {
        return type is Double.Type || type is Double?.Type || type is ImplicitlyUnwrappedOptional<Double>.Type
    }
    
    public static func matchArray(type: Any.Type) -> Bool {
        return type is [Double].Type || type is [Double]?.Type || type is ImplicitlyUnwrappedOptional<[Double]>.Type
    }
    
    public static func optionalityMatch(type: Any.Type) -> OptionalityType? {
        if type is Double.Type { return .notOptional }
        if type is Double?.Type { return .optional }
        if type is ImplicitlyUnwrappedOptional<Double>.Type { return .implicitlyUnwrapped }
        return nil
    }
}

extension Double: AnyMatchBuilder {}
