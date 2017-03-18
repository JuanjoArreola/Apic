//
//  Color+AnyMatchBuilder.swift
//  Apic
//
//  Created by Juan Jose Arreola on 3/18/17.
//
//

import Foundation

extension Color: FromAnyBuilder {
    
    static func build(value: Any) -> Color? {
        if let string = value as? String, let color = Color(hex: string) {
            return color
        }
        return nil
    }
}

extension Color: TypeMatchable {
    
    static func match(type: Any.Type) -> Bool {
        return type is Color.Type || type is Color?.Type || type is ImplicitlyUnwrappedOptional<Color>.Type
    }
    
    static func matchArray(type: Any.Type) -> Bool {
        return type is [Color].Type || type is [Color]?.Type || type is ImplicitlyUnwrappedOptional<[Color]>.Type
    }
    
    static func optionalityMatch(type: Any.Type) -> OptionalityType? {
        if type is Color.Type { return .notOptional }
        if type is Color?.Type { return .optional }
        if type is ImplicitlyUnwrappedOptional<Color>.Type { return .implicitlyUnwrapped }
        return nil
    }
}

extension Color: AnyMatchBuilder {}
