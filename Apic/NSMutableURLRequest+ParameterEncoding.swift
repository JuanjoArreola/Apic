//
//  NSMutableURLRequest+ParameterEncoding.swift
//  Apic
//
//  Created by Juan Jose Arreola on 3/2/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import Foundation

enum EncodeError: Error {
    case invalidMethod
}

extension URLRequest {
    
    mutating func encode(parameters: [String: Any]?, withEncoding encoding: ParameterEncoding) throws {
        guard let method = httpMethod else { throw EncodeError.invalidMethod }
        switch encoding {
        case .url:
            if URLRequest.parametersInURLForMethod(method) {
                self.url = try self.url?.url(appendingParameters: parameters)
            } else {
                setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                if let params = parameters {
                    let parametersString = try urlString(forParameters: params)
                    self.httpBody = parametersString.data(using: String.Encoding.utf8, allowLossyConversion: false)
                }
            }
            
        case .json:
            self.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if var params = parameters {
                makeJSONConvertible(parameters: &params)
                self.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
            }
        }
    }
    
    static func parametersInURLForMethod(_ method: String) -> Bool {
        switch method {
        case "GET", "HEAD", "DELETE":
            return true
        default:
            return false
        }
    }
}

func makeJSONConvertible(parameters: inout [String: Any]) {
    for (key, value) in parameters {
        if let url = value as? URL {
            parameters[key] = url.absoluteString
        }
    }
}

func urlString(forParameters parameters: [String: Any]) throws -> String {
    let array = parameters.map { (key, value) -> String in
        return "\(key)=\(String(describing: value))"
    }
    if let string = array.joined(separator: "&").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed) {
        return string
    }
    throw RepositoryError.encodingError
}

public extension Foundation.URL {
    func url(appendingParameters parameters: [String: Any]?) throws -> Foundation.URL {
        guard let params = parameters else { return self }
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        let parametersString = try urlString(forParameters: params)
        let percentEncodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + parametersString
        components.percentEncodedQuery = percentEncodedQuery
        if let url = components.url {
            return url
        }
        throw RepositoryError.encodingError
    }
}
