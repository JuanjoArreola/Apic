//
//  URL+AnyMatchBuilder.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 3/18/17.
//
//

import Foundation

extension URL: FromAnyBuilder {
    
    static func build(value: Any) -> URL? {
        if let string = value as? String {
            if let url = URL(string: string) {
                return url
            }
        }
        return nil
    }
}

extension URL: TypeMatchable {
    
    static func match(type: Any.Type) -> Bool {
        return type is URL.Type || type is URL?.Type || type is ImplicitlyUnwrappedOptional<URL>.Type
    }
    
    static func matchArray(type: Any.Type) -> Bool {
        return type is [URL].Type || type is [URL]?.Type || type is ImplicitlyUnwrappedOptional<[URL]>.Type
    }
    
    static func optionalityMatch(type: Any.Type) -> OptionalityType? {
        if type is URL.Type { return .notOptional }
        if type is URL?.Type { return .optional }
        if type is ImplicitlyUnwrappedOptional<URL>.Type { return .implicitlyUnwrapped }
        return nil
    }
}

extension URL: AnyMatchBuilder {}
