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
    
//    MARK: - Specifications
    var duration: Int = 0
    var format: MovieFormat = .standard
    
    var releaseDate: Date?
    
    var budget: NSDecimalNumber?
    var gross: NSDecimalNumber?
    
    
    var nominations: [Nomination]?
    
    var synopsis: Synopsis?
    
    var reproductions = 0
    
    override class var ignoredProperties: [String] {
        return ["reproductions"]
    }
    
    override class var propertyDateFormats: [String: String] {
        return ["releaseDate": "y-MM-dd HH:mm:ss"]
    }
    
    override func assign(value: Any, forProperty property: String) throws {
        switch property {
        case "format": format = value as! MovieFormat
        case "rating": rating = value as? Float
        default: try super.assign(value: value, forProperty: property)
        }
    }
    
    override func value(forKey key: String) -> Any? {
        if key == "rating" {
            return rating
        } else if key == "format" {
            return format.rawValue
        } else {
            return super.value(forKey: key)
        }
    }
}

class Person: AbstractModel {
    var name: String!
}

class Director: Person {
    var filmography: [Movie]?
}

class Nomination: AbstractModel {
    var name: String = ""
}

class Actor: Person {
    var country: String?
}

class Synopsis: AbstractModel {
    var text: String = ""
    var author: Person?
}
