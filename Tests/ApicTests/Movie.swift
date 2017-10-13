//
//  Movie.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 9/12/15.
//  Copyright © 2015 Juanjo. All rights reserved.
//

import Foundation
@testable import Apic


enum MovieFormat: String, Codable {
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

class Movie: Codable {
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
    
    var budget: Decimal?
    var gross: Decimal?
    
    
    var nominations: [Nomination]?
    
    var synopsis: Synopsis?
    
    var reproductions = 0
}

class Person: Codable {
    var name: String!
}

class Director: Person {
    var filmography: [Movie]?
}

class Nomination: Codable {
    var name: String = ""
}

class Actor: Person {
    var country: String?
}

class Synopsis: Codable {
    var text: String = ""
    var author: Person?
}
