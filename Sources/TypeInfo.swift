//
//  TypeInfo.swift
//  Apic
//
//  Created by Juan Jose Arreola on 29/03/17.
//
//

import Foundation

struct TypeInfo: Hashable {
    let type: Any.Type
    let typeNames: [String]
    let arrayTypeNames: [String]
    let dictionaryTypeNames: [String]
    
    init<T>(type: T.Type) {
        self.type = type
        typeNames = [
            "\(type)",
            "Optional<\(type)>",
            "ImplicitlyUnwrappedOptional<\(type)>"]
        arrayTypeNames = [
            "Array<\(type)>",
            "Optional<Array<\(type)>>",
            "ImplicitlyUnwrappedOptional<Array<\(type)>>"]
        dictionaryTypeNames = [
            "Dictionary<String, \(type)>",
            "Optional<Dictionary<String, \(type)>>",
            "ImplicitlyUnwrappedOptional<Dictionary<String, \(type)>>"]
    }
    
    init<T>(type: T.Type, name: String) {
        self.type = type
        typeNames = [name]
        arrayTypeNames = []
        dictionaryTypeNames = []
    }
    
    func match(type: Any.Type) -> Any.Type? {
        return typeNames.contains("\(type)") ? self.type : nil
    }
    
    func matchArray(type: Any.Type) -> Any.Type? {
        return arrayTypeNames.contains("\(type)") ? self.type : nil
    }
    
    func matchDictionary(type: Any.Type) -> Any.Type? {
        return dictionaryTypeNames.contains("\(type)") ? self.type : nil
    }
    
    func match(typeName: String) -> Any.Type? {
        return typeNames.contains(typeName) ? type : nil
    }
    
    var hashValue: Int {
        return ObjectIdentifier(type).hashValue
    }
}

func ==(left: TypeInfo, right: TypeInfo) -> Bool {
    return left.hashValue == right.hashValue
}
