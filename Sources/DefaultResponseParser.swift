import Foundation

open class DefaultResponseParser: ResponseParser {
    
    public let decoder = JSONDecoder()
    private let formatter = DateFormatter()
    
    public init() {
        guard let parser = self as? CustomDateParsing else {
            decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.secondsSince1970
            return
        }
        formatter.locale = parser.locale
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.custom({ decoder -> Date in
            let string = try decoder.singleValueContainer().decode(String.self)
            if let date = self.date(from: string, using: parser.dateFormats) {
                return date
            }
            throw ResponseError.invalidDate(string: string)
        })
    }
    
    open func date(from string: String, using formats: [String]) -> Date? {
        for format in formats {
            self.formatter.dateFormat = format
            if let date = self.formatter.date(from: string) {
                return date
            }
        }
        return nil
    }
    
    // MARK: -
    
    open func success(from data: Data?, response: URLResponse?, error: Error?) throws -> Bool {
        if let error = try parseError(data: data, response: response, error: error) {
            throw error
        }
        return true
    }
    
    open func object<T: Decodable>(from data: Data?, response: URLResponse?, error: Error?) throws -> T {
        let container: ResponseContainer<T> = try parse(data: data, response: response, error: error)
        if let object = container.object {
            return object
        }
        throw ResponseError.objectNotFound
    }
    
    open func array<T: Decodable>(from data: Data?, response: URLResponse?, error: Error?) throws -> [T] {
        let container: ResponseContainer<T> = try parse(data: data, response: response, error: error)
        if let array = container.array {
            return array
        }
        throw ResponseError.arrayNotFound
    }
    
    // MARK: - Parsing
    
    public func parse<T: Decodable>(data: Data?, response: URLResponse?, error: Error?) throws -> ResponseContainer<T> {
        if let error = try parseError(data: data, response: response, error: error) {
            throw error
        }
        guard let data = data else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "No data"))
        }
        return try getContainer(from: data, response: response)
    }
    
    open func getContainer<T: Decodable>(from data: Data, response: URLResponse?) throws -> ResponseContainer<T> {
        let container: ResponseContainer<T> = try decoder.decode(ResponseContainer<T>.self, from: data)
        return container
    }
    
    open func getErrorContainer(from data: Data) throws -> ErrorContainerProtocol {
        return try decoder.decode(ErrorContainer.self, from: data)
    }
    
    // MARK: - Parse error
    
    public func parseError(data: Data?, response: URLResponse?, error: Error?) throws -> Error? {
        if let error = error { throw error }
        if let data = data, let container = try? getErrorContainer(from: data), let error = container.getError() {
            return error
        }
        if let code = (response as? HTTPURLResponse)?.statusCode, code >= 400, code < 600 {
            if let error = parseError(code: code, data: data, response: response) {
                return error
            } else if let data = data {
                return ResponseError.httpError(statusCode: code, message: String(data: data, encoding: .utf8))
            }
            return ResponseError.httpError(statusCode: code, message: nil)
        }
        return nil
    }
    
    open func parseError(code: Int, data: Data?, response: URLResponse?) -> Error? {
        switch code {
        case 404:
            return ResponseError.httpError(statusCode: code, message: response?.url?.absoluteString)
        default:
            return nil
        }
    }
}

public protocol CustomDateParsing {
    var dateFormats: [String] { get }
    var locale: Locale { get }
}

public extension CustomDateParsing {
    var locale: Locale {
        return Locale(identifier: "en_US_POSIX")
    }
}
