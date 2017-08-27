import Foundation

open class DefaultResponseParser: ResponseParser {
    
    public let decoder = JSONDecoder()
    private let formatter = DateFormatter()
    
    public init() {
        if let parser = self as? CustomDateParsing {
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
        let data = try validate(data: data, response: response, error: error)
        let container: ResponseContainer<Bool> = try getContainer(from: data)
        if let success = container.object {
            return success
        }
        return container.successful()
    }
    
    open func object<T: Codable>(from data: Data?, response: URLResponse?, error: Error?) throws -> T {
        let data = try validate(data: data, response: response, error: error)
        let container: ResponseContainer<T> = try getContainer(from: data)
        if let object = container.object {
            return object
        }
        throw ResponseError.invalidResponse
    }
    
    open func array<T: Codable>(from data: Data?, response: URLResponse?, error: Error?) throws -> [T] {
        let data = try validate(data: data, response: response, error: error)
        let container: ResponseContainer<T> = try getContainer(from: data)
        if let array = container.array {
            return array
        }
        throw ResponseError.invalidResponse
    }
    
    open func dictionary<T: Codable>(from data: Data?, response: URLResponse?, error: Error?) throws -> [String : T] {
        let data = try validate(data: data, response: response, error: error)
        let container: ResponseContainer<T> = try getContainer(from: data)
        if let dictionary = container.dictionary {
            return dictionary
        }
        throw ResponseError.invalidResponse
    }
    
    func getContainer<T: Codable>(from data: Data) throws -> ResponseContainer<T> {
        let container: ResponseContainer<T> = try decoder.decode(ResponseContainer<T>.self, from: data)
        if let error = container.getError() {
            throw error
        }
        return container
    }
    
    public func validate(data: Data?, response: URLResponse?, error: Error?) throws -> Data {
        if let error = error { throw error }
        guard let validData = data else {
            if let code = (response as? HTTPURLResponse)?.statusCode, code >= 400, code < 600 {
                throw ResponseError.httpError(statusCode: code, message: nil)
            }
            throw ResponseError.invalidResponse
        }
        return validData
    }
    
}

public protocol CustomDateParsing {
    var dateFormats: [String] { get }
}

