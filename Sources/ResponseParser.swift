//
//  ResponseParser.swift
//  Apic
//
//  Created by Juan Jose Arreola on 05/04/17.
//
//

import Foundation

public protocol ResponseParser {
    
    func success(from data: Data?, response: URLResponse?, error: Error?) throws -> Bool
    func object(from data: Data?, response: URLResponse?, error: Error?) throws -> [String: Any]
    func array(from data: Data?, response: URLResponse?, error: Error?) throws -> [[String: Any]]
    func dictionary(from data: Data?, response: URLResponse?, error: Error?) throws -> [String: [String: Any]]
    
    func getError(from response: URLResponse, data: Data?) -> Error?
}
