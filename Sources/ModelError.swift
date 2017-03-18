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
    case valueTypeError(property: String?)
    case dateError(property: String?, value: String?)
    case urlError(property: String?, value: String?)
    case instanciationError
    case invalidProperty(property: String)
    case undefinedType(type: Any.Type)
    case undefinedTypeName(typeName: String)
    case unasignedInstance(property: String)
}
