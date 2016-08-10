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
                self.URL = try self.URL?.urlByAppendingParameters(parameters)
            } else {
                setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                if let params = parameters {
                    let parametersString = try urlStringForParameters(params)
                    self.HTTPBody = parametersString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                }
            }
            
        case .JSON:
            self.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if var params = parameters {
                makeParametersJSONConvertible(&params)
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
}

func makeParametersJSONConvertible(inout parameters: [String: AnyObject]) {
    for (key, value) in parameters {
        if let url = value as? NSURL {
            parameters[key] = url.absoluteString
        }
    }
}

func urlStringForParameters(parameters: [String: AnyObject]) throws -> String {
    let array = parameters.map { (key, value) -> String in
        return "\(key)=\(String(value))"
    }
    if let string = array.joinWithSeparator("&").stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
        return string
    }
    throw RepositoryError.EncodingError
}

public extension NSURL {
    func urlByAppendingParameters(parameters: [String: AnyObject]?) throws -> NSURL {
        guard let params = parameters else { return self }
        guard let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false) else { return self }
        let parametersString = try urlStringForParameters(params)
        let percentEncodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + parametersString
        components.percentEncodedQuery = percentEncodedQuery
        if let url = components.URL {
            return url
        }
        throw RepositoryError.EncodingError
    }
}