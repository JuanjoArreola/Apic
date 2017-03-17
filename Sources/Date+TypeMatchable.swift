//
//  Date+TypeMatchable.swift
//  Apic
//
//  Created by Juan Jose Arreola on 17/03/17.
//
//

import Foundation

extension Date: TypeMatchable {
    
    static func match(type: Any.Type) -> Bool {
        return type is Date.Type || type is Date?.Type || type is ImplicitlyUnwrappedOptional<Date>.Type
    }
    
    static func matchArray(type: Any.Type) -> Bool {
        return type is [Date].Type || type is [Date]?.Type || type is ImplicitlyUnwrappedOptional<[Date]>.Type
    }
    
    static func optionalityMatch(type: Any.Type) -> OptionalityType? {
        if type is Date.Type { return .notOptional }
        if type is Date?.Type { return .optional }
        if type is ImplicitlyUnwrappedOptional<Date>.Type { return .implicitlyUnwrapped }
        return nil
    }
}
