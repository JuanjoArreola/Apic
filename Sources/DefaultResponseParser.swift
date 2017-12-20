import Foundation

open class DefaultResponseParser: ResponseParser {
    
    public let decoder = JSONDecoder()
    private let formatter = DateFormatter()
    
    public init() {
        if let parser = self as? CustomDateParsing {
            formatter.locale = parser.locale
            decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.custom({ decoder -> Date in
                let string = try decoder.singleValueContainer().decode(String.self)
                for format in parser.dateFormats {
                    self.formatter.dateFormat = format
                    if let date = self.formatter.date(from: string) { return date }
                }
                throw ResponseError.invalidDate(string: string)
            })
        } else {
            decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.secondsSince1970
        }
    }
    
    open func success(from data: Data?, response: URLResponse?, error: Error?) throws -> Bool {
        let container: ResponseContainer<Bool> = try validate(data: data, response: response, error: error)
        if let success = container.object {
            return success
        }
        return container.successful()
    }
    
    open func object<T: Decodable>(from data: Data?, response: URLResponse?, error: Error?) throws -> T {
        let container: ResponseContainer<T> = try validate(data: data, response: response, error: error)
        if let object = container.object {
            return object
        }
        throw ResponseError.objectNotFound
    }
    
    open func array<T: Decodable>(from data: Data?, response: URLResponse?, error: Error?) throws -> [T] {
        let container: ResponseContainer<T> = try validate(data: data, response: response, error: error)
        if let array = container.array {
            return array
        }
        throw ResponseError.arrayNotFound
    }
    
    open func getContainer<T: Decodable>(from data: Data) throws -> ResponseContainer<T> {
        let container: ResponseContainer<T> = try decoder.decode(ResponseContainer<T>.self, from: data)
        return container
    }
    
    public func validate<T: Decodable>(data: Data?, response: URLResponse?, error: Error?) throws -> ResponseContainer<T> {
        if let error = error { throw error }
        if let code = (response as? HTTPURLResponse)?.statusCode, code == 404 {
            throw ResponseError.httpError(statusCode: code, message: response?.url?.absoluteString)
        }
        else if let code = (response as? HTTPURLResponse)?.statusCode, code >= 400, code < 600 {
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
        } else if let data = data {
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
