//
//  TypeResolver.swift
//  Apic
//
//  Created by Juan Jose Arreola on 16/03/17.
//
//

import Foundation

public protocol TypeResolver {
    func resolve(type: Any.Type) -> Any.Type?
    func resolveArray(type: Any.Type) -> Any.Type?
    func resolveDictionary(type: Any.Type) -> Any.Type?
    func resolve(typeForName typeName: String) -> Any?
}
