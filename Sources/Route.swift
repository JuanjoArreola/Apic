import Foundation

public enum Route {
    case get(String)
    case post(String)
    case put(String)
    case delete(String)
    case head(String)
    case patch(String)
    
    func getURL() throws -> URL {
        switch self {
        case .get(let string): return try url(from: string)
        case .post(let string): return try url(from: string)
        case .put(let string): return try url(from: string)
        case .delete(let string): return try url(from: string)
        case .head(let string): return try url(from: string)
        case .patch(let string): return try url(from: string)
        }
    }
    
    var httpMethod: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .delete: return "DELETE"
        case .head: return "HEAD"
        case .patch: return "PATCH"
        }
    }
    
    var preferredParameterEncoding: ParameterEncoding {
        switch self {
        case .get: return .url
        case .post: return .json
        case .put: return .json
        case .delete: return .url
        case .head: return .url
        case .patch: return .json
        }
    }
    
    private func url(from string: String) throws -> URL {
        if let url = URL(string: string) {
            return url
        }
        throw RepositoryError.invalidURL(url: string)
    }
}

public enum RepositoryError: Error {
    case invalidURL(url: String)
    case encodingError
    case networkConnection
}
