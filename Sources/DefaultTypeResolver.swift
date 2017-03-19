//
//  DefaultTypeResolver.swift
//  Apic
//
//  Created by Juan Jose Arreola on 16/03/17.
//
//

import Foundation

struct TypeInfo {
    let type: Any.Type
    let typeNames: [String]
    let arrayTypeNames: [String]
    
    init<T>(type: T.Type) {
        self.type = type
        typeNames = ["\(type)", "Optional<\(type)>", "ImplicitlyUnwrappedOptional<\(type)>"]
        arrayTypeNames = ["Array<\(type)>", "Optional<Array<\(type)>>",
            "ImplicitlyUnwrappedOptional<Array<\(type)>>"]
    }
    
    init<T>(type: T.Type, name: String) {
        self.type = type
        typeNames = [name]
        arrayTypeNames = []
    }
    
    func match(type: Any.Type) -> Any.Type? {
        if typeNames.contains("\(type)") {
            return self.type
        }
        return nil
    }
    
    func matchArray(type: Any.Type) -> Any.Type? {
        if arrayTypeNames.contains("\(type)") {
            return self.type
        }
        return nil
    }
    
    func match(typeName: String) -> Any.Type? {
        if typeNames.contains(typeName) {
            return type
        }
        return nil
    }
}

open class DefaultTypeResolver: TypeResolver {
    
    public static var shared = DefaultTypeResolver()
    
    var types = [TypeInfo]()
    var typeNames = [TypeInfo]()
    
    public func register<T>(type: T.Type) {
        if contains(type: type) { return }
        if type == AbstractModel.self { return }
        types.append(TypeInfo(type: type))
    }
    
    public func register<T>(type: T.Type, forName name: String) {
        if contains(typeName: name) { return }
        typeNames.append(TypeInfo(type: type, name: name))
    }
    
    private func contains(type: Any.Type) -> Bool {
        for info in types {
            if info.type == type {
                return true
            }
        }
        return false
    }
    
    private func contains(typeName: String) -> Bool {
        for info in typeNames {
            if info.typeNames.contains(typeName) {
                return true
            }
        }
        return false
    }
    
    public func resolve(type: Any.Type) -> Any.Type? {
        for info in types {
            if let match = info.match(type: type) { return match }
        }
        return nil
    }
    
    public func resolveArray(type: Any.Type) -> Any.Type? {
        for info in types {
            if let match = info.matchArray(type: type) { return match }
        }
        return nil
    }
    
    public func resolveDictionary(type: Any.Type) -> Any.Type? {
        return nil
    }
    
    public func resolve(typeForName typeName: String) -> Any? {
        for info in typeNames {
            if let match = info.match(typeName: typeName) { return match }
        }
        return nil
    }
}
