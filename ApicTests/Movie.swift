//
//  Movie.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 9/12/15.
//  Copyright © 2015 Juanjo. All rights reserved.
//

import Foundation
@testable import Apic

class DefaultModel: AbstractModel {
    static var defaultResolver = DefaultTypeResolver()
    override class var resolver: TypeResolver! { return defaultResolver }
}

enum MovieFormat: RawRepresentable, StringInitializable {
    case Widescreen
    case Standard
    
    init?(rawValue: String) {
        if rawValue == "16:9" {
            self = .Widescreen
        } else if rawValue == "4:3" {
            self = .Standard
        }
        return nil
    }
    
    var rawValue: String {
        switch self {
        case .Standard:
            return "4:3"
        case .Widescreen:
            return "16:9"
        }
    }
}

class Movie: DefaultModel {
    var id: String!
    var name: String!
    var year: Int = 0
    var country: [String]!
    var director: Director!
    var cast: [Actor]!
    
    var rating: Float?
    
//    MARK: - Specifications
    var duration: Int = 0
    var format: MovieFormat!
    
    var releaseDate: NSDate?
    
    var budget: NSDecimalNumber?
    var gross: NSDecimalNumber?
    
    
    var nominations: [Nomination]?
    
    var synopsis: Synopsis?
    
    var reproductions = 0
    
    override class var ignoredProperties: [String] { return ["reproductions"] }
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return ["id", "name", "year", "rating", "duration", "format", "country"].contains(property)
    }
    
    override func assignValue(value: AnyObject, forProperty property: String) throws {
        switch property {
        case "rating": rating = value as? Float
        default: try super.assignValue(value, forProperty: property)
        }
    }
}

class Person: DefaultModel {
    var name: String!
}

class Director: Person {
    var filmography: [Movie]?
}

class Nomination: DefaultModel {
    var name: String!
}

class Actor: Person {
    var country: String?
}

class Synopsis: DefaultModel {
    var text: String!
    var author: Person?
}

class DefaultTypeResolver: TypeResolver {
    
    func resolveType(type: Any) -> Any? {
        if type is Actor.Type || type is Actor?.Type || type is [Actor]?.Type {
            return Actor.self
        } else if type is Director.Type || type is Director?.Type {
            return Director.self
        }
        return nil
    }
}

