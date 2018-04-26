import Foundation

open class RequestParameters {
    
    // MARK: -
    public var parameters: [String: Any]?
    public let encoding: ParameterEncoding?
    
    // MARK: -
    public let data: Data?
    
    // MARK: -
    public let parts: [Part]?
    
    // MARK: - Commmon
    public var headers: [String: String] = [:]
    public var error: Error?
    
    public init(parameters: [String: Any]? = nil, encoding: ParameterEncoding? = nil, headers: [String: String] = [:]) {
        self.parameters = parameters
        self.encoding = encoding
        self.headers = headers
        self.data = nil
        self.parts = nil
    }
    
    public init<T: Encodable>(body: T, headers: [String: String] = [:]) {
        do {
            self.data = try JSONEncoder().encode(body)
        } catch {
            self.data = nil
            self.error = error
        }
        self.headers = headers
        self.parameters = nil
        self.encoding = nil
        self.parts = nil
    }
    
    public init(parts: [Part], parameters: [String: Any]? = nil, headers: [String: String] = [:]) {
        self.parts = parts
        self.parameters = parameters
        self.headers = headers
        self.data = nil
        self.encoding = nil
    }
    
    public init(data: Data?, headers: [String: String] = [:]) {
        self.data = data
        self.headers = headers
        self.parameters = nil
        self.encoding = nil
        self.parts = nil
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
