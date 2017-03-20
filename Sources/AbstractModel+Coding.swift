//
//  AbstractModel+Coding.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 3/20/17.
//
//

import Foundation

extension AbstractModel {
    
    func encodeProperties(of mirror: Mirror, with coder: NSCoder) {
        if mirror.isAbstractModelMirror {
            return
        }
        if let superclassMirror = mirror.superclassMirror, !superclassMirror.isAbstractModelMirror {
            encodeProperties(of: superclassMirror, with: coder)
        }
        for child in mirror.children {
            guard let property = child.label else { continue }
            let propertyType = Mirror(reflecting: child.value).subjectType
            if let value = child.value as? StringRepresentable {
                coder.encode(value.rawValue, forKey: property)
            } else if let _ = modelType.resolver.resolve(type: propertyType) as? StringRepresentable.Type {
                Log.debug("representable")
            } else {
                coder.encode(child.value, forKey: property)
            }
        }
    }
    
    open func initializeProperties(of mirror: Mirror, with decoder: NSCoder) throws {
        if mirror.isAbstractModelMirror {
            return
        }
        if let superclassMirror = mirror.superclassMirror, !superclassMirror.isAbstractModelMirror {
            try initializeProperties(of: superclassMirror, with: decoder)
        }
        for child in mirror.children {
            guard let property = child.label else { continue }
            let propertyType = Mirror(reflecting: child.value).subjectType
            if let value = decoder.decodeObject(forKey: property), !(value is NSNull) {
                if let type = modelType.resolver.resolve(type: propertyType) as? StringRepresentable.Type, let string = value as? String, let representable = type.init(rawValue: string) {
                    assign(value: representable, from: decoder, forProperty: property)
                } else {
                    assign(value: value, from: decoder, forProperty: property)
                }
            }
        }
    }
    
    open func assign(value: Any, from decoder: NSCoder, forProperty property: String) {
        do {
            try assign(value: value, forProperty: property)
        } catch {
            setValue(value, forKey: property)
        }
    }
}
