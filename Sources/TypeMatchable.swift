//
//  TypeMatchable.swift
//  Apic
//
//  Created by Juan Jose Arreola on 17/03/17.
//
//

import Foundation

public protocol TypeMatchable {
    static func match(type: Any.Type) -> Bool
    static func matchArray(type: Any.Type) -> Bool
    static func optionalityMatch(type: Any.Type) -> OptionalityType?
}

public enum OptionalityType {
    case optional, implicitlyUnwrapped, notOptional
}
