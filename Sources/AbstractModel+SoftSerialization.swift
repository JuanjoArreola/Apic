//
//  AbstractModel+SoftSerialization.swift
//  Apic
//
//  Created by Juan Jose Arreola on 20/04/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import Foundation

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
    
    @available(*, deprecated: 3.2.2, message: "Use jsonValidDictionary() instead")
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
                let propertyType = Mirror(reflecting:child.value).subjectType
                if strict && shouldFail(withInvalidValue: self.value(forKey: property), forProperty: property, type: propertyType) {
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
                dictionary[resultKey] = strict ? try model.jsonValidStrictDictionary() : model.jsonValidDictionary()
            } else if let models = value as? [AbstractModel] {
                dictionary[resultKey] = strict ? try models.jsonValidStrict() : models.jsonValid()
            } else {
                dictionary[resultKey] = String(describing: value)
            }
        }
    }
}

public extension Array where Element: AbstractModel {
    
    func jsonValid() -> [[String: Any]] {
        return self.map({ $0.jsonValidDictionary() })
    }
    
    func jsonValidStrict() throws -> [[String: Any]] {
        return try self.map({ try $0.jsonValidStrictDictionary() })
    }
    
    @available(*, deprecated: 3.2.2, message: "Use jsonValid() instead")
    var softArray: [[String: Any]] {
        return self.map({ $0.softDictionary })
    }
}
