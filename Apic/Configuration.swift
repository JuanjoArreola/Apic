//
//  Configuration.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation

public final class Configuration: NSObject {
    
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
    
    static var dateFormat: String = {
        return properties?["date_format"] as? String ?? defaultProperties["date_format"] as! String
        }()
    
    static let useDefaultStrings: Bool = {
        return NSBundle.mainBundle().pathForResource("ApicStrings", ofType: "strings") == nil ? true : false
    }()
}
