//
//  DefaultTypeResolver.swift
//  Apic
//
//  Created by Juan Jose Arreola on 16/03/17.
//
//

import Foundation

public class DefaultTypeResolver: TypeResolver {
    
    public static var shared = DefaultTypeResolver()
    
    private var types: Set<TypeInfo> = []
    private var typeNames: Set<TypeInfo> = []
    
    public func register(type: Any.Type) {
        if !contains(type: type) && type != AbstractModel.self {
            types.insert(TypeInfo(type: type))
        }
    }
    
    public func register(types: Any.Type...) {
        for type in types {
            register(type: type)
        }
    }
    
    public func register(type: Any.Type, forName name: String) {
        if !contains(typeName: name) {
            typeNames.insert(TypeInfo(type: type, name: name))
        }
    }
    
    private func contains(type: Any.Type) -> Bool {
        return types.find({ $0.type == type }) != nil
    }
    
    private func contains(typeName: String) -> Bool {
        return typeNames.find({ $0.typeNames.contains(typeName) }) != nil
    }
    
    // MARK: - TypeResolver
    
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
        for info in types {
            if let match = info.matchDictionary(type: type) { return match }
        }
        return nil
    }
    
    public func resolve(typeForName typeName: String) -> Any? {
        for info in typeNames {
            if let match = info.match(typeName: typeName) { return match }
        }
        return nil
    }
}
