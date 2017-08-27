import Foundation

enum EncodeError: Error {
    case invalidMethod
}

public extension URLRequest {
    
    mutating func encode(parameters: [String: Any]?, with encoding: ParameterEncoding) throws {
        guard let method = httpMethod else { throw EncodeError.invalidMethod }
        switch encoding {
        case .url:
            if ["GET", "HEAD", "DELETE"].contains(method) {
                self.url = try self.url?.appending(parameters: parameters)
            } else {
                setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                if let params = parameters {
                    guard let queryString = params.urlQueryString else { throw RepositoryError.encodingError }
                    self.httpBody = queryString.data(using: .utf8, allowLossyConversion: false)
                }
            }
            
        case .json:
            self.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let params = parameters {
                self.httpBody = try JSONSerialization.data(withJSONObject: params.jsonValid, options: [])
            }
        }
    }
}

public extension Dictionary where Key: ExpressibleByStringLiteral {
    
    public var urlQueryString: String? {
        let string = self.map({ "\($0)=\(String(describing: $1))" }).joined(separator: "&")
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    public var jsonValid: [Key: Any] {
        var result = [Key: Any]()
        self.forEach({ result[$0] = JSONSerialization.isValidJSONObject(["_": $1]) ? $1 : String(describing: $1) })
        return result
    }
}

public extension URL {
    func appending(parameters: [String: Any]?) throws -> URL {
        guard let params = parameters else { return self }
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return self }
        guard let queryString = params.urlQueryString else { throw RepositoryError.encodingError }
        let percentEncodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + queryString
        components.percentEncodedQuery = percentEncodedQuery
        if let url = components.url {
            return url
        }
        throw RepositoryError.encodingError
    }
}
