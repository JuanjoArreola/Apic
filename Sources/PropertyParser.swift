//
//  PropertyParser.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 3/20/17.
//
//

import Foundation

public protocol PropertyParser {
    
    func parsed<T: AnyMatchBuilder>(value: Any, property: String, type: Any.Type, target: T.Type) throws -> Bool
    
    func safeParsed<T: AnyMatchBuilder>(value: Any, property: String, type: Any.Type, target: T.Type) throws -> Bool
    
    func parsedArray<T: AnyMatchBuilder>(value: Any, property: String, type: Any.Type, target: T.Type) throws -> Bool
    
    func parsedDate(value: Any, property: String, type: Any.Type) throws -> Bool
    
    func parsedDateArray(value: Any, property: String, type: Any.Type) throws -> Bool
    
    func parsedStringDictionary(value: Any, property: String, type: Any.Type) throws -> Bool
    
    func parseDictionary(value: Any, property: String, type: InitializableWithDictionary.Type) throws
    
    func parseInitializable(value: Any, property: String, type: InitializableWithDictionary.Type) throws
    
    func parseInitializableArray(value: Any, property: String, type: InitializableWithDictionary.Type) throws
    
    func parseAnyInitializable(value: Any, property: String, type: AnyInitializable.Type) throws
    
    func parseAnyInitializableArray(value: Any, property: String, type: AnyInitializable.Type) throws
}
