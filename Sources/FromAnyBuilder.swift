//
//  FromAnyBuilder.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 3/18/17.
//
//

import Foundation

protocol AnyInitializable {
    init?(value: Any)
}

protocol FromAnyBuilder {
    
    associatedtype Buildable
    
    static func build(value: Any) -> Buildable?
}

protocol AnyMatchBuilder: FromAnyBuilder, TypeMatchable {}
