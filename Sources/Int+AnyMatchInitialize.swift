//
//  Int+AnyMatchInitialize.swift
//  Apic
//
//  Created by Juan Jose Arreola on 17/03/17.
//
//

import Foundation

extension Int: AnyInitializable {
    
    init?(value: Any?) {
        if let int = value as? Int {
            self = int
        }
        else if let string = value as? String {
            if let int = Int(string) {
                self = int
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

extension Int: TypeMatchable {
    
    static func match(type: Any.Type) -> Bool {
        return type is Int.Type || type is Int?.Type || type is ImplicitlyUnwrappedOptional<Int>.Type
    }
    
    static func matchArray(type: Any.Type) -> Bool {
        return type is [Int].Type || type is [Int]?.Type || type is ImplicitlyUnwrappedOptional<[Int]>.Type
    }
    
    static func optionalityMatch(type: Any.Type) -> OptionalityType? {
        if type is Int.Type { return .notOptional }
        if type is Int?.Type { return .optional }
        if type is ImplicitlyUnwrappedOptional<Int>.Type { return .implicitlyUnwrapped }
        return nil
    }
}

extension Int: AnyMatchInitialize {}
