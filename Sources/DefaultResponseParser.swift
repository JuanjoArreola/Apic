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
            for format in parser.dateFormats {
                self.formatter.dateFormat = format
                if let date = self.formatter.date(from: string) { return date }
            }
            throw ResponseError.invalidDate(string: string)
        })
    }
    
    open func success(from data: Data?, response: URLResponse?, error: Error?) throws -> Bool {
        let container: ResponseContainer<Bool> = try parse(data: data, response: response, error: error)
        if let success = container.object {
            return success
        }
        return container.successful()
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
    
    open func getContainer<T: Decodable>(from data: Data) throws -> ResponseContainer<T> {
        let container: ResponseContainer<T> = try decoder.decode(ResponseContainer<T>.self, from: data)
        return container
    }
    
    // MARK: - Error
    
    public func parseError<T: Decodable>(data: Data?, response: URLResponse?, error: Error?) throws -> ResponseContainer<T>? {
        if let error = error { throw error }
        if let code = (response as? HTTPURLResponse)?.statusCode, code >= 400, code < 600 {
            if let error = parseError(code: code, data: data, response: response) {
                throw error
            }
            guard let data = data else {
                throw ResponseError.httpError(statusCode: code, message: nil)
            }
            do {
                let container: ResponseContainer<T> = try getContainer(from: data)
                if let error = container.getError() {
                    throw error
                }
                return container
            } catch is DecodingError {
                throw ResponseError.httpError(statusCode: code, message: String(data: data, encoding: .utf8))
            }
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
    
    // MARK: - Parse
    
    public func parse<T: Decodable>(data: Data?, response: URLResponse?, error: Error?) throws -> ResponseContainer<T> {
        if let container = try parseError(data: data, response: response, error: error) as ResponseContainer<T>? {
            return container
        }
        if let data = data {
            let container: ResponseContainer<T> = try getContainer(from: data)
            if let error = container.getError() {
                throw error
            }
            return container
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "No data"))
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
