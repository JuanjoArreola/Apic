//
//  GenericTypeResolver.swift
//  Apic
//
//  Created by Juan Jose Arreola on 10/02/17.
//  Copyright © 2017 Juanjo. All rights reserved.
//

import Foundation

open class GenericTypeResolver: TypeResolver {
    
    public init() {
    }
    
    open func resolve(type: Any.Type) -> Any.Type? {
        return nil
    }
    
    open func resolve(typeForName typeName: String) -> Any? {
        return nil
    }
    
    open func resolveDictionary(type: Any) -> Any? {
        return nil
    }
    
    open func matchesSingle<T>(type: Any) -> T.Type? {
        if type is T.Type || type is T?.Type || type is ImplicitlyUnwrappedOptional<T>.Type {
            return T.self
        }
        return nil
    }
    
    open func matchesArray<T>(type: Any) -> T.Type? {
        if type is [T].Type || type is [T]?.Type || type is ImplicitlyUnwrappedOptional<[T]>.Type {
            return T.self
        }
        return nil
    }
    
    open func matchesAny<T>(type: Any) -> T.Type? {
        return matchesSingle(type: type) ?? matchesArray(type: type)
    }
}
