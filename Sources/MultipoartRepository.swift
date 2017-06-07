//
//  MultipoartRepository.swift
//  Apic
//
//  Created by Juan Jose Arreola on 07/06/17.
//
//

import Foundation
import AsyncRequest

public enum MultipartError: Error {
    case dataEncoding
}

open class MultipartRepository: BaseRepository {
    
    let boundary = "Boundary-\(NSUUID().uuidString)"
    
    open func multipartSuccess(url: URLConvertible, parts: [Part], params: [String: Any]? = [:], headers: [String: String]? = nil, completion: @escaping (Bool) -> Void) -> Request<Bool> {
        let request = ApicRequest<Bool>(successHandler: completion)
        do {
            let url = try getURL(from: url)
            request.dataTask = try multipart(url: url, parts: parts, parameters: params, headers: headers, completion: successHandler(for: request))
        } catch {
            self.responseQueue.async { request.complete(with: error) }
        }
        
        return request
    }
    
    open func requestObject<T: InitializableWithDictionary>(url: URLConvertible, parts: [Part], params: [String: Any]? = [:], headers: [String: String]? = nil, completion: @escaping (T) -> Void) -> Request<T> {
        let request = ApicRequest(successHandler: completion)
        do {
            let url = try getURL(from: url)
            request.dataTask = try multipart(url: url, parts: parts, parameters: params, headers: headers, completion: objectHandler(for: request))
        } catch {
            self.responseQueue.async { request.complete(with: error) }
        }
        return request
    }
    
    open func requestObjects<T: InitializableWithDictionary>(url: URLConvertible, parts: [Part], params: [String: Any]? = [:], headers: [String: String]? = nil, completion: @escaping ([T]) -> Void) -> ApicRequest<[T]> {
        let request = ApicRequest(successHandler: completion)
        do {
            let url = try getURL(from: url)
            request.dataTask = try multipart(url: url, parts: parts, parameters: params, headers: headers, completion: objectsHandler(for: request))
        } catch {
            self.responseQueue.async { request.complete(with: error) }
        }
        return request
    }
    
    open func multipart(url: URL, parts: [Part], parameters: [String: Any]? = nil, headers: [String: String]? = nil, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) throws -> URLSessionDataTask {
        var data = try parameters?.encode(withBoundary: boundary) ?? Data()
        try parts.forEach({ data.append(try $0.encode(withBoundary: boundary))})
        
        return requestMultipart(url: url, data: data, headers: headers, completion: completion)
    }
    
    open func requestMultipart(url: URL, data: Data?, headers: [String: String]? = nil, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = cachePolicy ?? request.cachePolicy
        request.timeoutInterval = timeoutInterval ?? request.timeoutInterval
        request.allowsCellularAccess = allowsCellularAccess ?? request.allowsCellularAccess
        headers?.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key) })
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let session = self.session ?? URLSession.shared
        
        var task: URLSessionDataTask
        if let delegate = repositorySessionDelegate {
            task = session.dataTask(with: request)
            delegate.add(completion: completion, for: task)
        } else {
            task = session.dataTask(with: request, completionHandler: completion)
        }
        task.resume()
        return task
    }
}

extension Dictionary where Key == String {
    func encode(withBoundary boundary: String) throws -> Data {
        var content = Data()
        for (key, value) in self {
            try content.append(string: "--\(boundary)\r\n")
            try content.append(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            try content.append(string: "\(value)\r\n")
        }
        return content
    }
}

extension Data {
    
    mutating func append(string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw MultipartError.dataEncoding
        }
        append(data)
    }
}
