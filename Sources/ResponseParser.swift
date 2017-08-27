import Foundation

public protocol ResponseParser {
    func success(from data: Data?, response: URLResponse?, error: Error?) throws -> Bool
    func object<T: Codable>(from data: Data?, response: URLResponse?, error: Error?) throws -> T
    func array<T: Codable>(from data: Data?, response: URLResponse?, error: Error?) throws -> [T]
    func dictionary<T: Codable>(from data: Data?, response: URLResponse?, error: Error?) throws -> [String: T]
}
