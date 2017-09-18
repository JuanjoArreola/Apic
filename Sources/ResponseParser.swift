import Foundation

public protocol ResponseParser {
    func success(from data: Data?, response: URLResponse?, error: Error?) throws -> Bool
    func object<T: Decodable>(from data: Data?, response: URLResponse?, error: Error?) throws -> T
    func array<T: Decodable>(from data: Data?, response: URLResponse?, error: Error?) throws -> [T]
}
