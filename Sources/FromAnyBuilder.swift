//
//  FromAnyBuilder.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 3/18/17.
//
//

import Foundation

public protocol AnyInitializable {
    init?(value: Any)
}

public protocol FromAnyBuilder {
    
    associatedtype Buildable
    
    static func build(value: Any) -> Buildable?
}

public protocol AnyMatchBuilder: FromAnyBuilder, TypeMatchable {}
