//
//  Configuration.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation

public final class Configuration {
    
    private static let properties: [String: Any]? = {
        if let path = Bundle.main.path(forResource: "ApicProperties", ofType: "plist") {
            return NSDictionary(contentsOfFile: path) as? [String: Any]
        }
        return nil
    }()
    
    static var dateFormat: String = {
        return properties?["date_format"] as? String ?? "y-MM-dd HH:mm:ssZ"
    }()
    
    static var locale: Locale = {
        let identifier = (properties?["locale_identifier"] as? String) ?? "en_US_POSIX"
        return Locale(identifier: identifier)
    }()
    
}
