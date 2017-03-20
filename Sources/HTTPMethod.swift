//
//  HTTPMethod.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 3/19/17.
//
//

import Foundation

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    
    var preferredParameterEncoding: ParameterEncoding {
        switch self {
        case .GET: return .url
        case .POST: return .json
        case .PUT: return .json
        case .DELETE: return .url
        }
    }
}
