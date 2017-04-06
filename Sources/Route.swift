//
//  Route.swift
//  Apic
//
//  Created by Juan Jose Arreola on 06/04/17.
//
//

import Foundation

public enum Route {
    case get(URLConvertible)
    case post(URLConvertible)
    case put(URLConvertible)
    case delete(URLConvertible)
    case head(URLConvertible)
    case patch(URLConvertible)
    
    func url() throws -> URL {
        switch self {
        case .get(let convertible):
            if let url = convertible.url { return url }
        case .post(let convertible):
            if let url = convertible.url { return url }
        case .put(let convertible):
            if let url = convertible.url { return url }
        case .delete(let convertible):
            if let url = convertible.url { return url }
        case .head(let convertible):
            if let url = convertible.url { return url }
        case .patch(let convertible):
            if let url = convertible.url { return url }
        }
        throw RepositoryError.invalidURL
    }
    
    func method() -> HTTPMethod {
        switch self {
        case .get: return HTTPMethod.GET
        case .post: return HTTPMethod.POST
        case .put: return HTTPMethod.PUT
        case .delete: return HTTPMethod.DELETE
        case .head: return HTTPMethod.HEAD
        case .patch: return HTTPMethod.PATCH
        }
    }
}
