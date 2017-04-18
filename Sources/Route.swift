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
            return try getURL(from: convertible)
        case .post(let convertible):
            return try getURL(from: convertible)
        case .put(let convertible):
            return try getURL(from: convertible)
        case .delete(let convertible):
            return try getURL(from: convertible)
        case .head(let convertible):
            return try getURL(from: convertible)
        case .patch(let convertible):
            return try getURL(from: convertible)
        }
    }
    
    private func getURL(from convertible: URLConvertible) throws -> URL {
        if let url = convertible.url { return url }
        if let string = convertible as? String {
            throw RepositoryError.invalidURL(url: string)
        }
        throw RepositoryError.invalidURL(url: String(describing: convertible))
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
