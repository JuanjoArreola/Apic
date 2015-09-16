//
//  Movie.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 9/12/15.
//  Copyright © 2015 Juanjo. All rights reserved.
//

import WatchKit
import Apic

class Movie: AbstractModel {
    var id: String!
    var name: String!
    var duration: Int? = 0
    var releaseDate: NSDate?
    
    var director: Director!
    var cast: [Actor]!
    var nominations: [Nomination]?
    
    var synopsis: Synopsis?
    
    override class var modelProperties: [String: AbstractModel.Type] { return ["director": Director.self, "synopsis": Synopsis.self] }
    override class var arrayOfModelProperties: [String: AbstractModel.Type] { return ["cast": Actor.self, "nominations": Nomination.self] }
    
    override func assignValue(value: AnyObject, forProperty property: String) throws {
        switch property {
        case "duration": duration = value as? Int
        case "releaseDate": releaseDate = value as? NSDate
        case "nominations": nominations = value as? [Nomination]
        case "synopsis": synopsis = value as? Synopsis
        default: try super.assignValue(value, forProperty: property)
        }
    }
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return ["id", "name", "director", "cast"].contains(property)
    }
}

class Person: AbstractModel {
    var name: String!
    
    override func shouldFailWithInvalidValue(value: AnyObject?, forProperty property: String) -> Bool {
        return ["name"].contains(property)
    }
}

class Director: Person {
    var filmography: [Movie]?
}

class Nomination: AbstractModel {
    var name: String!
}

class Actor: Person {
    var country: String?
}

class Synopsis: AbstractModel {
    var text: String!
    var author: Person?
    
    
}