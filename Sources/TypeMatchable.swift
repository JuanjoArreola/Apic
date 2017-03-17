//
//  TypeMatchable.swift
//  Apic
//
//  Created by Juan Jose Arreola on 17/03/17.
//
//

import Foundation

protocol TypeMatchable {
    static func match(type: Any.Type) -> Bool
    static func matchArray(type: Any.Type) -> Bool
    static func optionalityMatch(type: Any.Type) -> OptionalityType?
}

enum OptionalityType {
    case optional, implicitlyUnwrapped, notOptional
}
