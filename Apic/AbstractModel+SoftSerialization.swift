//
//  AbstractModel+SoftSerialization.swift
//  Apic
//
//  Created by Juan Jose Arreola on 20/04/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import Foundation

private var formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = Configuration.dateFormats.first
    return formatter
}()

public extension AbstractModel {
    
    func jsonValidDictionary() -> [String: Any] {
        var result = [String: Any]()
        try? softAddProperties(to: &result, mirror: Mirror(reflecting: self), strict: false)
        
        return result
    }
    
    func jsonValidStrictDictionary() throws -> [String: Any] {
        var result = [String: Any]()
        try softAddProperties(to: &result, mirror: Mirror(reflecting: self), strict: true)
        
        return result
    }
    
    var softDictionary: [String: Any] {
        return jsonValidDictionary()
    }
    
    private func softAddProperties(to dictionary: inout [String: Any], mirror: Mirror, strict: Bool) throws {
        if let superMirror = mirror.superclassMirror, !superMirror.isAbstractModelMirror {
            try softAddProperties(to: &dictionary, mirror: superMirror, strict: strict)
        }
        let modelType = mirror.subjectType as! AbstractModel.Type
        for child in mirror.children {
            guard let property = child.label else { continue }
            guard let value = self.value(forKey: property) else {
                if strict && shouldFail(withInvalidValue: self.value(forKey: property), forProperty: property) {
                    throw ModelError.serializationError(property: property, model: String(describing: modelType))
                }
                continue
            }
            let resultKey = modelType.propertyKeys[property] ?? property
            if JSONSerialization.isValidJSONObject(value) {
                dictionary[resultKey] = value
            } else if let date = value as? Date {
                if let string = modelType.string(from: date, property: property) {
                    dictionary[resultKey] = string
                } else if strict && shouldFail(withInvalidValue: date, forProperty: property) {
                    throw ModelError.serializationError(property: property, model: String(describing: modelType))
                }
            } else if let model = value as? AbstractModel {
                dictionary[resultKey] = strict ? try model.jsonValidStrictDictionary() : model.jsonValidDictionary()
            } else if let models = value as? [AbstractModel] {
                dictionary[resultKey] = strict ? try models.jsonValidStrictDictionary() : models.jsonValidDictionary()
            } else {
                dictionary[resultKey] = String(describing: value)
            }
        }
    }
}

public extension Array where Element: AbstractModel {
    func jsonValidDictionary() -> [[String: Any]] {
        return self.map({ $0.jsonValidDictionary() })
    }
    
    func jsonValidStrictDictionary() throws -> [[String: Any]] {
        return try self.map({ try $0.jsonValidStrictDictionary() })
    }
    
    var softArray: [[String: Any]] {
        return self.map({ $0.softDictionary })
    }
}
