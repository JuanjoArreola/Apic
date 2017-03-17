//
//  Movie.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 9/12/15.
//  Copyright © 2015 Juanjo. All rights reserved.
//

import Foundation
@testable import Apic


enum MovieFormat: StringRepresentable {
    case widescreen
    case standard
    
    init?(rawValue: String) {
        switch rawValue {
        case "16:9": self = .widescreen
        case "4:3": self = .standard
        default:
            return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .standard: return "4:3"
        case .widescreen: return "16:9"
        }
    }
}

class Movie: AbstractModel {
    var id: String = ""
    var name: String = ""
    var year: Int = 0
    var country: [String]!
    var director: Director!
    var cast: [Actor]!
    
    var rating: Float?
    
    override class func initialize() {
        super.initialize()
        
        DefaultTypeResolver.shared.register(type: MovieFormat.self)
    }
    
//    MARK: - Specifications
    var duration: Int = 0
    var format: MovieFormat = .standard
    
    var releaseDate: Date?
    
    var budget: NSDecimalNumber?
    var gross: NSDecimalNumber?
    
    
    var nominations: [Nomination]?
    
    var synopsis: Synopsis?
    
    var reproductions = 0
    
    override class var ignoredProperties: [String] { return ["reproductions"] }
    
    override class var propertyDateFormats: [String: String] { return ["releaseDate": "y-MM-dd HH:mm:ss"] }
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["id", "name", "year", "rating", "duration", "format", "country", "cast"].contains(property)
    }
    
    override func assign(value: Any, forProperty property: String) throws {
        switch property {
        case "format": format = value as! MovieFormat
        case "rating": rating = value as? Float
        default: try super.assign(value: value, forProperty: property)
        }
    }
}

class Person: AbstractModel {
    var name: String!
}

class Director: Person {
    var filmography: [Movie]?
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["name"].contains(property)
    }
}

class Nomination: AbstractModel {
    var name: String = ""
}

class Actor: Person {
    var country: String?
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["name"].contains(property)
    }
}

class Synopsis: AbstractModel {
    var text: String = ""
    var author: Person?
    
    override func shouldFail(withInvalidValue value: Any?, forProperty property: String) -> Bool {
        return ["text"].contains(property)
    }
}
