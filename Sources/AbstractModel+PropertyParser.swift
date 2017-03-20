//
//  AbstractModel+ModelParser.swift
//  Apic
//
//  Created by Juan Jose Arreola on 3/20/17.
//
//

import Foundation

extension AbstractModel: PropertyParser {
    
    public func parsed<T: AnyMatchBuilder>(value: Any, property: String, type: Any.Type, target: T.Type) throws -> Bool {
        if T.match(type: type) {
            guard let instance = T.build(value: value) else {
                throw ModelError.sourceValueError(property: property, model: modelType, value: value)
            }
            setValue(instance, forKey: property)
            return true
        }
        return false
    }
    
    public func safeParsed<T: AnyMatchBuilder>(value: Any, property: String, type: Any.Type, target: T.Type) throws -> Bool {
        if let optionality = T.optionalityMatch(type: type) {
            guard let instance = T.build(value: value) else {
                throw ModelError.sourceValueError(property: property, model: modelType, value: value)
            }
            if optionality == .notOptional {
                setValue(instance, forKey: property)
            } else {
                try assign(value: instance, forProperty: property)
            }
            return true
        }
        return false
    }
    
    public func parsedArray<T: AnyMatchBuilder>(value: Any, property: String, type: Any.Type, target: T.Type) throws -> Bool {
        if T.matchArray(type: type) {
            if let array = value as? [Any] {
                let newArray: [T] = try array.map({
                    if let element = T.build(value: $0) as? T {
                        return element
                    }
                    else {
                        throw ModelError.sourceValueError(property: property, model: T.self, value: $0)
                    }
                })
                setValue(newArray, forKey: property)
            } else {
                throw ModelError.sourceValueError(property: property, model: modelType, value: value)
            }
            return true
        }
        return false
    }
    
    public func parsedDate(value: Any, property: String, type: Any.Type) throws -> Bool {
        if Date.match(type: type) {
            let format = modelType.propertyDateFormats[property] ?? Configuration.dateFormat
            guard let date = Date(value: value, format: format) else {
                throw ModelError.dateError(property: property, value: String(describing: value))
            }
            setValue(date, forKey: property)
            return true
        }
        return false
    }
    
    public func parsedDateArray(value: Any, property: String, type: Any.Type) throws -> Bool {
        if Date.matchArray(type: type) {
            let format = modelType.propertyDateFormats[property] ?? Configuration.dateFormat
            guard let array = value as? [Any] else {
                throw ModelError.dateError(property: property, value: String(describing: value))
            }
            var dates = [Date]()
            for value in array {
                guard let date = Date(value: value, format: format) else {
                    throw ModelError.dateError(property: property, value: String(describing: value))
                }
                dates.append(date)
            }
            setValue(dates, forKey: property)
            return true
        }
        return false
    }
    
    public func parsedStringDictionary(value: Any, property: String, type: Any.Type) throws -> Bool {
        if type is [String: String].Type || type is [String: String]?.Type || type is ImplicitlyUnwrappedOptional<[String: String]>.Type {
            if let dictionary = value as? [String: String] {
                setValue(dictionary, forKey: property)
            } else {
                throw ModelError.sourceValueError(property: property, model: modelType, value: value)
            }
            return true
        }
        return false
    }
    
    public func parseDictionary(value: Any, property: String, type: InitializableWithDictionary.Type) throws {
        guard let dictionary = value as? [String: [String: Any]] else {
            throw ModelError.sourceValueError(property: property, model: modelType, value: value)
        }
        var newDictionary = [String: InitializableWithDictionary]()
        if let propertyType = type as? DynamicTypeModel.Type {
            let resolver = (propertyType as? AbstractModel.Type)?.resolver ?? modelType.resolver
            for (key, value) in dictionary {
                newDictionary[key] = try dynamicItem(from: value, typeNameKey: propertyType.typeNameProperty, resolver: resolver)
            }
        } else {
            for (key, item) in dictionary {
                newDictionary[key] = try type.init(dictionary: item)
            }
        }
        setValue(newDictionary, forKey: property)
    }
    
    public func parseInitializable(value: Any, property: String, type: InitializableWithDictionary.Type) throws {
        guard let dictionary = value as? [String: Any] else {
            throw ModelError.sourceValueError(property: property, model: modelType, value: value)
        }
        let instance: InitializableWithDictionary
        if let propertyType = type as? DynamicTypeModel.Type {
            let resolver = (propertyType as? AbstractModel.Type)?.resolver ?? modelType.resolver
            instance = try dynamicItem(from: dictionary, typeNameKey: propertyType.typeNameProperty, resolver: resolver)
        } else {
            instance = try type.init(dictionary: dictionary)
        }
        if instance is NSObject {
            setValue(instance, forKey: property)
        } else {
            try assign(value: instance, forProperty: property)
        }
    }
    
    public func parseInitializableArray(value: Any, property: String, type: InitializableWithDictionary.Type) throws {
        guard let array = value as? [[String: Any]] else {
            throw ModelError.sourceValueError(property: property, model: modelType, value: value)
        }
        var newArray = [InitializableWithDictionary]()
        if let propertyType = type as? DynamicTypeModel.Type {
            let resolver = (propertyType as? AbstractModel.Type)?.resolver ?? modelType.resolver
            for value in array {
                newArray.append(try dynamicItem(from: value, typeNameKey: propertyType.typeNameProperty, resolver: resolver))
            }
        } else {
            for value in array {
                newArray.append(try type.init(dictionary: value))
            }
        }
        setValue(newArray, forKey: property)
    }
    
    public func parseAnyInitializable(value: Any, property: String, type: AnyInitializable.Type) throws {
        guard let instance = type.init(value: value) else {
            throw ModelError.sourceValueError(property: property, model: modelType, value: value)
        }
        if instance is NSObject {
            setValue(instance, forKey: property)
        } else {
            try assign(value: instance, forProperty: property)
        }
    }
    
    public func parseAnyInitializableArray(value: Any, property: String, type: AnyInitializable.Type) throws {
        guard let array = value as? [Any] else {
            throw ModelError.sourceValueError(property: property, model: modelType, value: value)
        }
        var newArray: [AnyInitializable] = []
        for element in array {
            guard let value = type.init(value: element) else {
                throw ModelError.sourceValueError(property: property, model: modelType, value: element)
            }
            newArray.append(value)
        }
        setValue(newArray, forKey: property)
    }
    
    private func dynamicItem(from dictionary: [String: Any], typeNameKey: String, resolver: TypeResolver) throws -> InitializableWithDictionary {
        if let typeName = dictionary[typeNameKey] as? String {
            if let type = resolver.resolve(typeForName: typeName) as? InitializableWithDictionary.Type {
                return try type.init(dictionary: dictionary)
            }
            throw ModelError.undefinedTypeName(name: typeName)
        }
        Log.warn("Dynamic item has no type info")
        throw ModelError.dynamicTypeInfo(key: typeNameKey)
    }
}
