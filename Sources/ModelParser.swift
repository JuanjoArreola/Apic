//
//  ModelParser.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 4/2/17.
//
//

import Foundation

internal class ModelParser {
    
    private var modelType: AbstractModel.Type
    private var resolver: TypeResolver
    
    init(type: AbstractModel.Type) {
        modelType = type
        resolver = modelType.resolver
    }
    
    func assignBasic(value: Any, to model: AbstractModel, child: Mirror.Child) throws -> Bool {
        guard let childProperty = ChildProperty(child: child) else { return false }
        
        if let _: String = try assign(value, to: model, property: childProperty) { return true }
        if let _: [String] = try assignArray(value, to: model, property: childProperty) { return true }
        
        if let _: Int = try safeAssign(value, to: model, property: childProperty) { return true }
        if let _: [Int] = try assignArray(value, to: model, property: childProperty) { return true }
        
        if let _: Bool = try safeAssign(value, to: model, property: childProperty) { return true }
        if let _: [Bool] = try assignArray(value, to: model, property: childProperty) { return true }
        
        if let _: Float = try safeAssign(value, to: model, property: childProperty) { return true }
        if let _: [Float] = try assignArray(value, to: model, property: childProperty) { return true }
        
        if let _: Double = try safeAssign(value, to: model, property: childProperty) { return true }
        if let _: [Double] = try assignArray(value, to: model, property: childProperty) { return true }
        
        if try assignDate(value: value, to: model, property: childProperty) { return true }
        if try assignDateArray(value: value, to: model, property: childProperty) { return true }
        
        if let _: NSDecimalNumber = try assign(value, to: model, property: childProperty) { return true }
        if let _: [NSDecimalNumber] = try assignArray(value, to: model, property: childProperty) { return true }
        
        if let _: URL = try assign(value, to: model, property: childProperty) { return true }
        if let _: [URL] = try assignArray(value, to: model, property: childProperty) { return true }
        
        if let _: Color = try assign(value, to: model, property: childProperty) { return true }
        if let _: [Color] = try assignArray(value, to: model, property: childProperty) { return true }
        
        if try assignStringDictionary(value: value, to: model, property: childProperty) { return true }
        
        return false
    }
    
    func assignDictionaryInitializable(value: Any, to model: AbstractModel, child: Mirror.Child) throws -> Bool {
        guard let childProperty = ChildProperty(child: child) else { return false }
        
        if try assignInitializable(value: value, to: model, property: childProperty) { return true }
        if try assignInitializableArray(value: value, to: model, property: childProperty) { return true }
        if try assignInitializableDictionary(value: value, to: model, property: childProperty) { return true }
        return false
    }
    
    func assignAnyInitializable(value: Any, to model: AbstractModel, child: Mirror.Child) throws -> Bool {
        guard let childProperty = ChildProperty(child: child) else { return false }
        
        if try assignAnyInitializable(value: value, to: model, property: childProperty) { return true }
        if try assignAnyInitializableArray(value: value, to: model, property: childProperty) { return true }
        return false
    }
    
    // MARK: -
    
    @discardableResult
    private func assign<T: AnyMatchBuilder>(_ value: Any, to model: AbstractModel, property: ChildProperty) throws -> T? where T.Buildable == T {
        if T.match(type: property.type) {
            guard let instance = T.build(value: value) else {
                throw ModelError.sourceValueError(property: property.name, model: modelType, value: value)
            }
            model.setValue(instance, forKey: property.name)
            return instance
        }
        return nil
    }
    
    @discardableResult
    private func safeAssign<T: AnyMatchBuilder>(_ value: Any, to model: AbstractModel, property: ChildProperty) throws -> T? where T.Buildable == T {
        if let optionality = T.optionalityMatch(type: property.type) {
            guard let instance = T.build(value: value) else {
                throw ModelError.sourceValueError(property: property.name, model: modelType, value: value)
            }
            if instance is NSObjectProtocol {}
            if optionality == .notOptional {
                model.setValue(instance, forKey: property.name)
            } else {
                try model.assign(value: instance, forProperty: property.name)
            }
            return instance
        }
        return nil
    }
    
    @discardableResult
    private func assignArray<T: AnyMatchBuilder>(_ value: Any, to model: AbstractModel, property: ChildProperty) throws -> [T]? where T.Buildable == T {
        if T.matchArray(type: property.type) {
            guard let array = value as? [Any] else {
                throw ModelError.sourceValueError(property: property.name, model: modelType, value: value)
            }
            let newArray: [T] = try array.map({
                guard let element = T.build(value: $0) else {
                    throw ModelError.sourceValueError(property: property.name, model: T.self, value: $0)
                }
                return element
            })
            model.setValue(newArray, forKey: property.name)
            return newArray
        }
        return nil
    }
    
    // MARK: -
    
    private func assignDate(value: Any, to model: AbstractModel, property: ChildProperty) throws -> Bool {
        if Date.match(type: property.type) {
            let date = try parseDate(value: value, property: property.name)
            model.setValue(date, forKey: property.name)
            return true
        }
        return false
    }
    
    private func assignDateArray(value: Any, to model: AbstractModel, property: ChildProperty) throws -> Bool {
        if Date.matchArray(type: property.type) {
            guard let array = value as? [Any] else {
                throw ModelError.sourceValueError(property: property.name, model: modelType, value: value)
            }
            let dates = try array.map({ try parseDate(value: $0, property: property.name) })
            model.setValue(dates, forKey: property.name)
            return true
        }
        return false
    }
    
    private func parseDate(value: Any, property: String) throws -> Date {
        if let format = modelType.propertyDateFormats[property] {
            if let date = Date(value: value, format: format) {
                return date
            }
            throw ModelError.dateError(property: property, type: modelType, value: String(describing: value), format: format)
        } else if let format = modelType.dateFormat {
            if let date = Date(value: value, format: format) {
                return date
            }
            throw ModelError.dateError(property: property, type: modelType, value: String(describing: value), format: format)
        } else if let date = Date(value: value, format: Configuration.dateFormat) {
            return date
        }
        throw ModelError.dateError(property: property, type: modelType, value: String(describing: value), format: Configuration.dateFormat)
    }
    
    private func assignStringDictionary(value: Any, to model: AbstractModel, property: ChildProperty) throws -> Bool {
        let type = property.type
        if type is [String: String].Type || type is [String: String]?.Type || type is ImplicitlyUnwrappedOptional<[String: String]>.Type {
            guard let dictionary = value as? [String: String] else {
                throw ModelError.sourceValueError(property: property.name, model: modelType, value: value)
            }
            model.setValue(dictionary, forKey: property.name)
            return true
        }
        return false
    }
    
    // MARK: -
    
    private func assignInitializable(value: Any, to model: AbstractModel, property: ChildProperty) throws -> Bool {
        guard let propertyType = resolver.resolve(type: property.type) as? InitializableWithDictionary.Type else {
            return false
        }
        guard let dictionary = value as? [String: Any] else {
            throw ModelError.sourceValueError(property: property.name, model: modelType, value: value)
        }
        let instance: InitializableWithDictionary
        if let propertyType = propertyType as? DynamicTypeModel.Type {
            instance = try dynamicItem(from: dictionary, typeNameKey: propertyType.typeNameProperty)
        } else {
            instance = try propertyType.init(dictionary: dictionary)
        }
        
        if instance is NSObject {
            model.setValue(instance, forKey: property.name)
        } else {
            try model.assign(value: instance, forProperty: property.name)
        }
        return true
    }
    
    private func assignInitializableArray(value: Any, to model: AbstractModel, property: ChildProperty) throws -> Bool {
        guard let propertyType = resolver.resolveArray(type: property.type) as? InitializableWithDictionary.Type else {
            return false
        }
        guard let array = value as? [[String: Any]] else {
            throw ModelError.sourceValueError(property: property.name, model: modelType, value: value)
        }
        var newArray: [InitializableWithDictionary]
        if let propertyType = propertyType as? DynamicTypeModel.Type {
            newArray = try array.map({ try dynamicItem(from: $0, typeNameKey: propertyType.typeNameProperty)})
        } else {
            newArray = try array.map({ try propertyType.init(dictionary: $0) })
        }
        model.setValue(newArray, forKey: property.name)
        return true
    }
    
    private func assignInitializableDictionary(value: Any, to model: AbstractModel, property: ChildProperty) throws -> Bool {
        guard let propertyType = resolver.resolveDictionary(type: property.type) as? InitializableWithDictionary.Type else {
            return false
        }
        guard let dictionary = value as? [String: [String: Any]] else {
            throw ModelError.sourceValueError(property: property.name, model: modelType, value: value)
        }
        var newDictionary = [String: InitializableWithDictionary]()
        if let type = propertyType as? DynamicTypeModel.Type {
            try dictionary.forEach({ newDictionary[$0] = try dynamicItem(from: $1, typeNameKey: type.typeNameProperty) })
        } else {
            try dictionary.forEach({ newDictionary[$0] = try propertyType.init(dictionary: $1) })
        }
        model.setValue(newDictionary, forKey: property.name)
        return true
    }
    
    private func dynamicItem(from dictionary: [String: Any], typeNameKey: String) throws -> InitializableWithDictionary {
        guard let typeName = dictionary[typeNameKey] as? String else {
            Log.warn("Dynamic item has no type info")
            throw ModelError.dynamicTypeInfo(key: typeNameKey)
        }
        if let type = resolver.resolve(typeForName: typeName) as? InitializableWithDictionary.Type {
            return try type.init(dictionary: dictionary)
        }
        throw ModelError.undefinedTypeName(name: typeName)
    }
    
    // MARK: -
    
    private func assignAnyInitializable(value: Any, to model: AbstractModel, property: ChildProperty) throws -> Bool {
        guard let type = resolver.resolve(type: property.type) as? AnyInitializable.Type else {
            return false
        }
        guard let instance = type.init(value: value) else {
            throw ModelError.sourceValueError(property: property.name, model: modelType, value: value)
        }
        if instance is NSObject {
            model.setValue(instance, forKey: property.name)
        } else {
            try model.assign(value: instance, forProperty: property.name)
        }
        return true
    }
    
    private func assignAnyInitializableArray(value: Any, to model: AbstractModel, property: ChildProperty) throws -> Bool {
        guard let type = resolver.resolveArray(type: property.type) as? AnyInitializable.Type else {
            return false
        }
        guard let array = value as? [Any] else {
            throw ModelError.sourceValueError(property: property.name, model: modelType, value: value)
        }
        var newArray: [AnyInitializable] = []
        for element in array {
            guard let value = type.init(value: element) else {
                throw ModelError.sourceValueError(property: property.name, model: modelType, value: element)
            }
            newArray.append(value)
        }
        try model.assign(value: newArray, forProperty: property.name)
        return true
    }
    
}
