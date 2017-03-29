//
//  RepositoryError.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 3/19/17.
//
//

import Foundation

public enum RepositoryError: Error, CustomStringConvertible {
    case badJSON
    case badJSONContent
    case invalidURL
    case invalidParameters
    case statusFail(message: String?, code: String?)
    case networkConnection
    case httpError(statusCode: Int, message: String?)
    case encodingError
    
    public var description: String {
        switch self {
        case .httpError(let statusCode, _):
            return "HTTP Error: \(statusCode)"
        case .badJSON:
            return "Bad JSON"
        case .badJSONContent:
            return "Bad JOSN Content"
        case .invalidURL:
            return "Invalid URL"
        case .invalidParameters:
            return "Invalid parameters"
        case .statusFail(let message, let code):
            return "Status fail [\(code ?? "")]: \(message ?? "")"
        case .networkConnection:
            return "No network connection"
        case .encodingError:
            return "Encoding error"
        }
    }
}
