//
//  AbstractModel+SoftSerialization.swift
//  Apic
//
//  Created by Juan Jose Arreola on 20/04/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import Foundation

public extension AbstractModel {
    var softDictionary: [String: AnyObject] {
        let mirror = Mirror(reflecting: self)
        var result = [String: AnyObject]()
        for child in mirror.children {
            guard let property = child.label else {
                continue
            }
            let modelType = mirror.subjectType as! AbstractModel.Type
            if property == modelType.descriptionProperty {
                result["description"] = self.valueForKey(property)
                continue
            }
            if let value = self.valueForKey(property) {
                if let model = value as? AbstractModel {
                    result[property] = model.softDictionary
                } else if let models = value as? [AbstractModel] {
                    result[property] = models.map({ (model) -> [String: AnyObject] in
                        return model.softDictionary
                    })
                } else {
                    result[property] = value
                }
            }
        }
        return result
    }
}

public extension Array where Element: AbstractModel {
    var softArray: [[String: AnyObject]] {
        var result = [[String: AnyObject]]()
        for element in self {
            result.append(element.softDictionary)
        }
        return result
    }
}