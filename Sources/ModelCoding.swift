//
//  ModelCoding.swift
//  Apic
//
//  Created by Juan Jose Arreola on 05/04/17.
//
//

import Foundation

class ModelCoding {
    
    static var shared = ModelCoding()
    
    func encodeProperties(of model: AbstractModel, mirror: Mirror, with coder: NSCoder) {
        if mirror.isAbstractModelMirror {
            return
        }
        if let superclassMirror = mirror.superclassMirror, !superclassMirror.isAbstractModelMirror {
            encodeProperties(of: model, mirror: superclassMirror, with: coder)
        }
        
        let modelType = type(of: model)
        for child in mirror.children {
            guard let property = child.label else { continue }
            
            let propertyType = type(of: child.value)
            if let value = child.value as? StringRepresentable {
                coder.encode(value.rawValue, forKey: property)
            } else if let _ = modelType.resolver.resolve(type: propertyType) as? StringRepresentable.Type {
                Log.warn("representable")
            } else {
                coder.encode(child.value, forKey: property)
            }
        }
    }
    
    open func initializeProperties(of model: AbstractModel, mirror: Mirror, with decoder: NSCoder) throws {
        if mirror.isAbstractModelMirror {
            return
        }
        if let superclassMirror = mirror.superclassMirror, !superclassMirror.isAbstractModelMirror {
            try initializeProperties(of: model, mirror: superclassMirror, with: decoder)
        }
        
        let modelType = type(of: model)
        for child in mirror.children {
            guard let property = child.label else { continue }
            guard let value = decoder.decodeObject(forKey: property), !(value is NSNull) else {
                continue
            }
            let propertyType = type(of: child.value)
            if let type = modelType.resolver.resolve(type: propertyType) as? StringRepresentable.Type,
                let string = value as? String,
                let representable = type.init(rawValue: string) {
                assign(value: representable, to: model, decoder: decoder, forProperty: property)
            } else {
                assign(value: value, to: model, decoder: decoder, forProperty: property)
            }
        }
    }
    
    open func assign(value: Any, to model: AbstractModel, decoder: NSCoder, forProperty property: String) {
        do {
            try model.assign(value: value, forProperty: property)
        } catch {
            model.setValue(value, forKey: property)
        }
    }
}
