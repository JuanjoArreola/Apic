//
//  ModelParserProvider.swift
//  Apic
//
//  Created by Juan Jose Arreola on 4/2/17.
//
//

import Foundation

class ModelParserProvider {
    
    static var shared = ModelParserProvider()
    
    var parsers: [ObjectIdentifier: ModelParser] = [:]
    
    func parser(for type: AbstractModel.Type) -> ModelParser {
        if let parser = parsers[ObjectIdentifier(type)] {
            return parser
        }
        let parser = ModelParser(type: type)
        parsers[ObjectIdentifier(type)] = parser
        return parser
    }
}
