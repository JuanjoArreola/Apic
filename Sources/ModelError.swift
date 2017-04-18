//
//  ModelError.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 3/17/17.
//
//

import Foundation

public enum ModelError: Error {
    case sourceValueError(property: String, model: Any.Type, value: Any?)
    case serializationError(property: String, model: String)
    case dateError(property: String?, type: Any.Type, value: String?, format: String)
    case urlError(property: String?, value: String?)
    case invalidProperty(property: String)
    case undefinedType(type: Any.Type, model: Any.Type)
    case undefinedTypeName(name: String)
    case unasignedInstance(property: String)
    case notEncoded(property: String)
    
    case validationError(reason: String, type: Any.Type)
}
