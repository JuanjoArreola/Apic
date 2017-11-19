import Foundation

enum EncodeError: Error {
    case invalidMethod
}

public extension URLRequest {
    
    mutating func encode(parameters: [String: Any], with encoding: ParameterEncoding) throws {
        guard let method = httpMethod else { throw EncodeError.invalidMethod }
        switch encoding {
        case .url:
            if ["GET", "HEAD", "DELETE"].contains(method) {
                self.url = try self.url?.appending(parameters: parameters)
            } else if let queryString = parameters.urlQueryString {
                setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                self.httpBody = queryString.data(using: .utf8, allowLossyConversion: false)
            } else {
                throw RepositoryError.encodingError
            }
        case .json:
            self.setValue("application/json", forHTTPHeaderField: "Content-Type")
            self.httpBody = try JSONEncoder().encode(parameters)
        }
    }
}

public extension Dictionary where Key: ExpressibleByStringLiteral {
    
    public var urlQueryString: String? {
        let string = self.map({ "\($0)=\(String(describing: $1))" }).joined(separator: "&")
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}

public extension URL {
    func appending(parameters: [String: Any]) throws -> URL {
        guard let queryString = parameters.urlQueryString,
              var components = URLComponents(url: self, resolvingAgainstBaseURL: false)else {
            throw RepositoryError.encodingError
        }
        let percentEncodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + queryString
        components.percentEncodedQuery = percentEncodedQuery
        if let url = components.url {
            return url
        }
        throw RepositoryError.encodingError
    }
}
