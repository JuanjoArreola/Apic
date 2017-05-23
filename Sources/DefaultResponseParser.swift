//
//  DefaultResponseParser.swift
//  Apic
//
//  Created by Juan Jose Arreola on 05/04/17.
//
//

import Foundation

open class DefaultResponseParser<StatusType: Equatable>: ResponseParser {
    
    public var objectKey: String?
    public var objectsKey: String?
    public var statusKey: String?
    public var statusOk: StatusType?
    public var errorDescriptionKey: String?
    public var errorCodeKey: String?
    
    public init() {}
    
    open func success(from data: Data?, response: URLResponse?, error: Error?) throws -> Bool {
        let json = try getJSON(data: data, response: response, error: error)
        _ = try self.dictionary(fromJSON: json)
        return true
    }
    
    open func object(from data: Data?, response: URLResponse?, error: Error?) throws -> [String : Any] {
        let json = try getJSON(data: data, response: response, error: error)
        let dictionary = try self.dictionary(fromJSON: json)
        
        if let objectKey = self.objectKey {
            if let objectDictionary = dictionary[objectKey] as? [String: Any] {
                return objectDictionary
            }
            throw RepositoryError.badJSONContent
        }
        return dictionary
    }
    
    open func array(from data: Data?, response: URLResponse?, error: Error?) throws -> [[String : Any]] {
        let json = try self.getJSON(data: data, response: response, error: error)
        
        if let objectsKey = self.objectsKey {
            let data = try self.dictionary(fromJSON: json)
            if let array = data[objectsKey] as? [[String: Any]] {
                return array
            }
        } else if let array = json as? [[String: Any]] {
            return array
        }
        throw RepositoryError.badJSONContent
    }
    
    open func dictionary(from data: Data?, response: URLResponse?, error: Error?) throws -> [String : [String : Any]] {
        let json = try self.getJSON(data: data, response: response, error: error)
        
        if let objectsKey = self.objectsKey {
            let data = try self.dictionary(fromJSON: json)
            if let dictionary = data[objectsKey] as? [String: [String: Any]] {
                return dictionary
            }
        } else if let dictionary = json as? [String: [String: Any]] {
            return dictionary
        }
        throw RepositoryError.badJSONContent
    }
    
    open func getError(from response: URLResponse, data: Data?) -> Error? {
        guard let code = (response as? HTTPURLResponse)?.statusCode, code >= 400, code < 600 else {
            return nil
        }
        guard let data = data else {
            return RepositoryError.httpError(statusCode: code, message: nil)
        }
        if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            if let key = errorDescriptionKey,
                let message = json?[key] as? String,
                let codeKey = errorCodeKey,
                let code = json?[codeKey] as? String {
                return RepositoryError.statusFail(message: message, code: code)
            }
        }
        let message = String(data: data, encoding: String.Encoding.isoLatin1)
        return RepositoryError.httpError(statusCode: code, message: message)
    }

    open func error(forCode code: String, message: String?) -> Error? {
        return nil
    }
    
    @inline(__always) private func getJSON(data: Data?, response: URLResponse?, error: Error?) throws -> Any {
        if let error = error {
            throw error
        }
        if let response = response, let error = self.getError(from: response, data: data) {
            throw error
        }
        guard let data = data else {
            throw RepositoryError.badJSON
        }
        return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
    
    open func dictionary(fromJSON JSON: Any?) throws -> [String: Any] {
        guard let data = JSON as? [String: Any] else {
            throw RepositoryError.badJSONContent
        }
        guard let statusKey = statusKey, let statusOk = statusOk else {
            return data
        }
        guard let status = data[statusKey] as? StatusType else {
            throw RepositoryError.badJSONContent
        }
        if status == statusOk {
            return data
        }
        let message = errorDescriptionKey != nil ? data[errorDescriptionKey!] as? String : nil
        let code = errorCodeKey != nil ? data[errorCodeKey!] as? String : nil
        if let code = code, let error = error(forCode: code, message: message) {
            throw error
        }
        throw RepositoryError.statusFail(message: message, code: code)
    }
}
