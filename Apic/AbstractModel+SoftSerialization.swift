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
    
    var softDictionary: [String: Any] {
        let mirror = Mirror(reflecting: self)
        var result = [String: Any]()
        softAddProperties(to: &result, mirror: mirror)
        
        return result
    }
    
    private func softAddProperties(to dictionary: inout [String: Any], mirror: Mirror) {
        if let superMirror = mirror.superclassMirror, !superMirror.isAbstractModelMirror {
            softAddProperties(to: &dictionary, mirror: superMirror)
        }
        let modelType = mirror.subjectType as! AbstractModel.Type
        for child in mirror.children {
            guard let property = child.label, let value = self.value(forKey: property) else {
                continue
            }
            let resultKey = modelType.propertyKeys[property] ?? property
            if let date = value as? Date {
                dictionary[resultKey] = formatter.string(from: date)
            }
            else if let model = value as? AbstractModel {
                dictionary[resultKey] = model.softDictionary
            } else if let models = value as? [AbstractModel] {
                dictionary[resultKey] = models.map({ $0.softDictionary })
            } else {
                dictionary[resultKey] = value
            }
        }
    }
}

extension Mirror {
    var isAbstractModelMirror: Bool {
        return String(describing: self.subjectType) == String(describing: AbstractModel.self)
    }
}

public extension Array where Element: AbstractModel {
    var softArray: [[String: Any]] {
        return self.map({ $0.softDictionary })
    }
}
