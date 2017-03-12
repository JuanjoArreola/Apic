//
//  Configuration.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation

public final class Configuration {
    
//    private static let defaultProperties: [String: Any] = {
//        let bundle = Bundle(for: Configuration.self)
//        let path = bundle.path(forResource: "apic_properties", ofType: "plist")
//        return NSDictionary(contentsOfFile: path!) as! [String: Any]
//    }()
    
    private static let properties: [String: Any]? = {
        if let path = Bundle.main.path(forResource: "ApicProperties", ofType: "plist") {
            return NSDictionary(contentsOfFile: path) as? [String: Any]
        }
        return nil
    }()
   
    static var statusKey: String = {
        return properties?["status_key"] as? String ?? "status"
    }()
    
    static var statusOk: String = {
        return properties?["status_ok"] as? String ?? "OK"
    }()
    
    static var statusFail: String = {
        return properties?["status_fail"] as? String ?? "FAIL"
    }()
    
    static var errorCodeKey: String = {
        return properties?["error_code_key"] as? String ?? "errorCode"
    }()
    
    static var errorDescriptionKey: String = {
        return properties?["error_description_key"] as? String ?? "error"
    }()
    
    static var objectKey: String = {
        return properties?["object_key"] as? String ?? "object"
    }()
    
    static var objectsKey: String = {
        return properties?["objects_key"] as? String ?? "objects"
    }()
    
    static var dateFormats: [String] = {
        return properties?["date_formats"] as? [String] ?? ["y-MM-dd HH:mm:ssZ"]
    }()
    
    static var locale: Locale = {
        let identifier = (properties?["locale_identifier"] as? String) ?? "en_US_POSIX"
        return Locale(identifier: identifier)
    }()
    
    static var logLevel: Int = {
        return properties?["log_level"] as? Int ?? 1
    }()
    
    static var showFile: Bool = {
        return properties?["show_file"] as? Bool ?? true
    }()
    
    static var showFunc: Bool = {
        return properties?["show_func"] as? Bool ?? true
    }()
    
    static var showLine: Bool = {
        return properties?["show_line"] as? Bool ?? true
    }()
    
    static let useDefaultStrings: Bool = {
        return Bundle.main.path(forResource: "ApicStrings", ofType: "strings") == nil ? true : false
    }()
    
    static let checkReachability: Bool = {
        return properties?["check_reachability"] as? Bool ?? false
    }()
    
}
