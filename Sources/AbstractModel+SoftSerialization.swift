//
//  AbstractModel+SoftSerialization.swift
//  Apic
//
//  Created by Juan Jose Arreola on 20/04/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import Foundation

public extension AbstractModel {
    
    func jsonValidDictionary(strict: Bool = false) throws -> [String: Any] {
        var result = [String: Any]()
        try softAddProperties(to: &result, mirror: Mirror(reflecting: self), strict: strict)
        
        return result
    }
    
    private func softAddProperties(to dictionary: inout [String: Any], mirror: Mirror, strict: Bool) throws {
        if let superMirror = mirror.superclassMirror, !superMirror.isAbstractModelMirror {
            try softAddProperties(to: &dictionary, mirror: superMirror, strict: strict)
        }
        for child in mirror.children {
            guard let property = child.label else { continue }
            guard let value = self.value(forKey: property) else {
                let propertyType = type(of: child.value)
                if "\(propertyType)".hasPrefix("Optional<") {
                    continue
                }
                if strict {
                    throw ModelError.serializationError(property: property, model: String(describing: modelType))
                }
                continue
            }
            let resultKey = modelType.propertyKeys[property] ?? property
            if JSONSerialization.isValidJSONObject(["value": value]) {
                dictionary[resultKey] = value
            } else if let date = value as? Date {
                let format = modelType.propertyDateFormats[property] ?? Configuration.dateFormat
                dictionary[resultKey] = date.toString(format: format)
            } else if let model = value as? AbstractModel {
                dictionary[resultKey] = try model.jsonValidDictionary(strict: strict)
            } else if let models = value as? [AbstractModel] {
                dictionary[resultKey] = try models.jsonValidArray(strict: strict)
            } else {
                dictionary[resultKey] = String(describing: value)
            }
        }
    }
}

public extension Array where Element: AbstractModel {
    
    func jsonValidArray(strict: Bool = false) throws -> [[String: Any]] {
        return try self.map({ try $0.jsonValidDictionary(strict: strict) })
    }
}
