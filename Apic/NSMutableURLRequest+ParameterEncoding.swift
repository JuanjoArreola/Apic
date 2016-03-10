//
//  NSMutableURLRequest+ParameterEncoding.swift
//  Apic
//
//  Created by Juan Jose Arreola on 3/2/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {
    
    func encodeParameters(parameters: [String: AnyObject]?, withEncoding encoding: ParameterEncoding) throws {
        switch encoding {
        case .URL:
            if NSMutableURLRequest.parametersInURLForMethod(self.HTTPMethod) {
                guard let params = parameters else {
                    return
                }
                if let URLComponents = NSURLComponents(URL: self.URL!, resolvingAgainstBaseURL: false) {
                    let parametersString = try NSMutableURLRequest.encodeParameters(params)
                    let percentEncodedQuery = (URLComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + parametersString
                    URLComponents.percentEncodedQuery = percentEncodedQuery
                    self.URL = URLComponents.URL
                }
            } else {
                setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                if let params = parameters {
                    let parametersString = try NSMutableURLRequest.encodeParameters(params)
                    self.HTTPBody = parametersString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                }
            }
            
        case .JSON:
            self.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let params = parameters {
                self.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
            }
        }
    }
    
    static func parametersInURLForMethod(method: String) -> Bool {
        switch method {
        case "GET", "HEAD", "DELETE":
            return true
        default:
            return false
        }
    }
    
    static func encodeParameters(parameters: [String: AnyObject]) throws -> String {
        let array = parameters.map { (key, value) -> String in
            let string = String(value)
            return "\(key)=\(string)"
        }
        if let string = array.joinWithSeparator("&").stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
            return string
        }
        throw RepositoryError.EncodingError
    }
}
