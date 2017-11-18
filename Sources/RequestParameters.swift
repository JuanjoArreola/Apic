import Foundation

public class RequestParameters {
    
    // MARK: -
    let parameters: [String: Any]?
    let encoding: ParameterEncoding?
    
    // MARK: -
    let data: Data?
    
    // MARK: -
    let parts: [Part]?
    
    // MARK: - Commmon
    var headers: [String: String]?
    
    
    public init(parameters: [String: Any]? = nil, encoding: ParameterEncoding? = nil, headers: [String: String]? = nil) {
        self.parameters = parameters
        self.encoding = encoding
        self.headers = headers
        self.data = nil
        self.parts = nil
    }
    
    public init<T: Encodable>(body: T, headers: [String: String]? = nil) throws {
        self.parameters = nil
        self.encoding = nil
        self.headers = headers
        self.data = try JSONEncoder().encode(body)
        self.parts = nil
    }
    
    public init(parts: [Part], parameters: [String: Any]? = nil, headers: [String: String]? = nil) {
        self.parts = parts
        self.parameters = parameters
        self.headers = headers
        self.data = nil
        self.encoding = nil
    }
    
    func getData(withBoundary boundary: String) throws -> Data? {
        guard let parts = parts else { return nil }
        var data = try parameters?.encode(withBoundary: boundary) ?? Data()
        try parts.forEach({ data.append(try $0.encode(withBoundary: boundary))})
        try data.append(string: "--\(boundary)--\r\n")
        return data
    }
    
    open func preprocess() throws {}
}
