//
//  HTTPMethod.swift
//  Apic
//
//  Created by Juan Jose Arreola on 3/19/17.
//
//

import Foundation

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case HEAD
    case PATCH
    
    var preferredParameterEncoding: ParameterEncoding {
        switch self {
        case .GET: return .url
        case .POST: return .json
        case .PUT: return .json
        case .DELETE: return .url
        case .HEAD: return .url
        case .PATCH: return .json
        }
    }
}

extension HTTPMethod {
    func route(url: URLConvertible) -> Route {
        switch self {
        case .GET: return Route.get(url)
        case .POST: return Route.post(url)
        case .PUT: return Route.put(url)
        case .DELETE: return Route.delete(url)
        case .HEAD: return Route.head(url)
        case .PATCH: return Route.patch(url)
        }
    }
}
