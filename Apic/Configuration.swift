//
//  Configuration.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation

public final class Configuration {
    
    private static let defaultProperties: [String: AnyObject] = {
        let bundle = NSBundle(forClass: Configuration.self)
        let path = bundle.pathForResource("apic_properties", ofType: "plist")
        return NSDictionary(contentsOfFile: path!) as! [String: AnyObject]
    }()
    
    private static let properties: [String: AnyObject]? = {
        if let path = NSBundle.mainBundle().pathForResource("ApicProperties", ofType: "plist") {
            return NSDictionary(contentsOfFile: path) as? [String: AnyObject]
        }
        return nil
    }()
   
    static var statusKey: String = {
        return properties?["status_key"] as? String ?? defaultProperties["status_key"] as! String
    }()
    
    static var statusOk: String = {
        return properties?["status_ok"] as? String ?? defaultProperties["status_ok"] as! String
    }()
    
    static var statusFail: String = {
        return properties?["status_fail"] as? String ?? defaultProperties["status_fail"] as! String
    }()
    
    static var errorCodeKey: String = {
        return properties?["error_code_key"] as? String ?? defaultProperties["error_code_key"] as! String
    }()
    
    static var errorDescriptionKey: String = {
        return properties?["error_description_key"] as? String ?? defaultProperties["error_description_key"] as! String
    }()
    
    static var objectKey: String = {
        return properties?["object_key"] as? String ?? defaultProperties["object_key"] as! String
    }()
    
    static var objectsKey: String = {
        return properties?["objects_key"] as? String ?? defaultProperties["objects_key"] as! String
    }()
    
    static var dateFormats: [String] = {
        return properties?["date_formats"] as? [String] ?? defaultProperties["date_formats"] as! [String]
    }()
    
    static var logLevel: Int = {
        return properties?["log_level"] as? Int ?? defaultProperties["log_level"] as! Int
    }()
    
    static var showFile: Bool = {
        return properties?["show_file"] as? Bool ?? defaultProperties["show_file"] as! Bool
    }()
    
    static var showFunc: Bool = {
        return properties?["show_func"] as? Bool ?? defaultProperties["show_func"] as! Bool
    }()
    
    static var showLine: Bool = {
        return properties?["show_line"] as? Bool ?? defaultProperties["show_line"] as! Bool
    }()
    
    static let useDefaultStrings: Bool = {
        return NSBundle.mainBundle().pathForResource("ApicStrings", ofType: "strings") == nil ? true : false
    }()
    
    static let checkReachability: Bool = {
        return properties?["check_reachability"] as? Bool ?? defaultProperties["check_reachability"] as! Bool
    }()
    
}
