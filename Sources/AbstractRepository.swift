//
//  AbstractRepository.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation

private let processQueue = DispatchQueue(label: "com.apic.ProcessQueue", attributes: DispatchQueue.Attributes.concurrent)

public enum ParameterEncoding {
    case url
    case json
}

public protocol URLConvertible {
    var url: URL? { get }
}

extension URL: URLConvertible {
    public var url: URL? {
        return self
    }
}

extension String: URLConvertible {
    public var url: URL? {
        return URL(string: self)
    }
}

open class AbstractRepository<StatusType: Equatable>: NSObject, URLSessionDataDelegate {
    
    open var objectKey: String?
    open var objectsKey: String?
    open var statusKey: String?
    open var statusOk: StatusType?
    open var errorDescriptionKey: String?
    open var errorCodeKey: String?
    
    open var session: URLSession?
    open var cachePolicy: URLRequest.CachePolicy?
    open var timeoutInterval: TimeInterval?
    open var allowsCellularAccess: Bool?
    
    open var responseQueue = DispatchQueue.main
    
    private var completionHandlers: [URLSessionTask: (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void] = [:]
    private var buffers: [URLSessionTask: Data] = [:]
    private var progressReporters: [URLSessionTask: ProgressReporter] = [:]
    
#if os(iOS) || os(OSX) || os(tvOS)
    open var checkReachability = true
#endif
    
    public init(objectKey: String? = nil, objectsKey: String? = nil, statusKey: String? = nil, statusOk: StatusType? = nil, errorDescriptionKey: String? = nil, errorCodeKey: String? = nil) {
        self.objectKey = objectKey
        self.objectsKey = objectsKey
        self.statusKey = statusKey
        self.statusOk = statusOk
        self.errorDescriptionKey = errorDescriptionKey
        self.errorCodeKey = errorCodeKey
    }
    
    open func requestSuccess(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getSuccess: () throws -> Bool) -> Void) -> ApicRequest<Bool> {
        let request = ApicRequest(completionHandler: completion)
        guard let url = url.url else {
            responseQueue.async { request.complete(withError: RepositoryError.invalidURL) }
            return request
        }
        
        processQueue.async {
            do {
                try self.checkURLReachability(url: url)
                let parameterEncoding = encoding ?? method.preferredParameterEncoding
                
                request.dataTask = try self.request(url: url, method: method, parameters: params, parameterEncoding: parameterEncoding, headers: headers) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    do {
                        let json = try self.getJSON(data: data, response: response, error: error)
                        _ = try self.dictionary(fromJSON: json)
                        self.responseQueue.async { request.complete(withObject: true) }
                    }
                    catch {
                        self.responseQueue.async { request.complete(withError: error) }
                    }
                }
                if self.session?.delegate === self, let task = request.dataTask {
                    self.progressReporters[task] = request
                }
            } catch {
                self.responseQueue.async { request.complete(withError: error) }
            }
        }
        return request
    }
    
    open func requestObject<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getObject: () throws -> T) -> Void) -> ApicRequest<T> {
        let request = ApicRequest(completionHandler: completion)
        guard let url = url.url else {
            responseQueue.async { request.complete(withError: RepositoryError.invalidURL) }
            return request
        }

        processQueue.async {
            do {
                try self.checkURLReachability(url: url)
                let parameterEncoding = encoding ?? method.preferredParameterEncoding
                
                request.dataTask = try self.request(url: url, method: method, parameters: params, parameterEncoding: parameterEncoding, headers: headers, completion: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    do {
                        let json = try self.getJSON(data: data, response: response, error: error)
                        var dictionary = try self.dictionary(fromJSON: json)
                        if let objectKey = self.objectKey {
                            if let objectDictionary = dictionary[objectKey] as? [String: Any] {
                                dictionary = objectDictionary
                            } else {
                                throw RepositoryError.badJSONContent
                            }
                        }
                        let object = try T(dictionary: dictionary)
                        self.responseQueue.async { request.complete(withObject: object) }
                    } catch {
                        self.responseQueue.async { request.complete(withError: error) }
                    }
                })
                if self.session?.delegate === self {
                    self.progressReporters[request.dataTask!] = request
                }
            } catch {
                self.responseQueue.async { request.complete(withError: error) }
            }
        }
        return request
    }
    
    open func requestObjects<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getObjects: () throws -> [T]) -> Void) -> ApicRequest<[T]> {
        let request = ApicRequest(completionHandler: completion)
        guard let url = url.url else {
            responseQueue.async { request.complete(withError: RepositoryError.invalidURL) }
            return request
        }
        
        processQueue.async {
            do {
                try self.checkURLReachability(url: url)
                let parameterEncoding = encoding ?? method.preferredParameterEncoding
                
                request.dataTask = try self.request(url: url, method: method, parameters: params, parameterEncoding: parameterEncoding, headers: headers, completion: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    do {
                        let json = try self.getJSON(data: data, response: response, error: error)
                        var array: [[String: Any]]!
                        if let objectsKey = self.objectsKey {
                            let data = try self.dictionary(fromJSON: json)
                            array = data[objectsKey] as? [[String: Any]]
                        } else {
                            array = json as? [[String: Any]]
                        }
                        if array == nil {
                            throw RepositoryError.badJSONContent
                        }
                        let objects = try array.map({ try T(dictionary: $0) })
                        self.responseQueue.async { request.complete(withObject: objects) }
                    } catch {
                        self.responseQueue.async { request.complete(withError: error) }
                    }
                })
                if self.session?.delegate === self {
                    self.progressReporters[request.dataTask!] = request
                }
            } catch {
                self.responseQueue.async { request.complete(withError: error) }
            }
        }
        return request
    }
    
    open func requestDictionaryOfObjects<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getDictionary: () throws -> [String: T]) -> Void) -> ApicRequest<[String: T]> {
        let request = ApicRequest(completionHandler: completion)
        guard let url = url.url else {
            responseQueue.async { request.complete(withError: RepositoryError.invalidURL) }
            return request
        }
        processQueue.async {
            do {
                try self.checkURLReachability(url: url)
                let parameterEncoding = encoding ?? method.preferredParameterEncoding
                
                request.dataTask = try self.request(url: url, method: method, parameters: params, parameterEncoding: parameterEncoding, headers: headers, completion: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    do {
                        let json = try self.getJSON(data: data, response: response, error: error)
                        var dictionary: [String: [String: Any]]!
                        if let objectsKey = self.objectsKey {
                            let data = try self.dictionary(fromJSON: json)
                            dictionary = data[objectsKey] as? [String: [String: Any]]
                        } else {
                            dictionary = json as? [String: [String: Any]]
                        }
                        if dictionary == nil {
                            throw RepositoryError.badJSONContent
                        }
                        var objects = [String: T]()
                        for (key, value) in dictionary {
                            objects[key] = try T(dictionary: value)
                            self.didAssign(object: objects[key]!, to: &objects, withKey: key)
                        }
                        self.responseQueue.async { request.complete(withObject: objects) }
                    } catch {
                        self.responseQueue.async { request.complete(withError: error) }
                    }
                })
                if self.session?.delegate === self {
                    self.progressReporters[request.dataTask!] = request
                }
            } catch {
                self.responseQueue.async { request.complete(withError: error) }
            }
        }
        return request
    }
    
    open func didAssign<T: InitializableWithDictionary>(object: T, to dictionary: inout [String: T], withKey key: String) {
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
    
    // MARK: -
    
    open func request(url: URL, method: HTTPMethod = .GET, parameters: [String: Any]? = [:], parameterEncoding: ParameterEncoding = .url, headers: [String: String]? = nil, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) throws -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.cachePolicy = cachePolicy ?? request.cachePolicy
        request.timeoutInterval = timeoutInterval ?? request.timeoutInterval
        request.allowsCellularAccess = allowsCellularAccess ?? request.allowsCellularAccess
        headers?.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key) })
        try request.encode(parameters: parameters, with: parameterEncoding)
        
        return dataTask(with: request, completion: completion)
    }
    
    open func request(url: URL, method: HTTPMethod = .GET, data: Data?, headers: [String: String]? = nil, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.cachePolicy = cachePolicy ?? request.cachePolicy
        request.timeoutInterval = timeoutInterval ?? request.timeoutInterval
        request.allowsCellularAccess = allowsCellularAccess ?? request.allowsCellularAccess
        headers?.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key) })
        request.httpBody = data
        
        return dataTask(with: request, completion: completion)
    }
    
    @inline(__always) private func dataTask(with request: URLRequest, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) -> URLSessionDataTask {
        let session = self.session ?? URLSession.shared
        
        var task: URLSessionDataTask
        if self.session?.delegate === self {
            task = session.dataTask(with: request)
            completionHandlers[task] = completion
        } else {
            task = session.dataTask(with: request, completionHandler: completion)
        }
        task.resume()
        return task
    }
    
    @inline(__always) func checkURLReachability(url: URL) throws {
        #if os(iOS) || os(OSX) || os(tvOS)
            if !self.checkReachability {
                return
            }
            guard let info = try? Reachability.reachabilityInfo(forURL: url) else {
                return
            }
            guard let reachable = info.isReachable else {
                return
            }
            if !reachable {
                throw RepositoryError.networkConnection
            }
        #endif
    }

    public func dictionary(fromJSON JSON: Any?) throws -> [String: Any] {
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
    
    open func error(forCode code: String, message: String?) -> Error? {
        return nil
    }
    
    public func getError(from response: URLResponse, data: Data?) -> Error? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return nil
        }
        let code = httpResponse.statusCode
        if code >= 400 && code < 600 {
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                if let key = errorDescriptionKey, let message = json?[key] as? String, let codeKey = errorCodeKey, let code = json?[codeKey] as? String {
                    return RepositoryError.statusFail(message: message, code: code)
                }
            }
            var message: String?
            if let data = data {
                message = String(data: data, encoding: String.Encoding.isoLatin1)
            }
            return RepositoryError.httpError(statusCode: code, message: message)
        }
        return nil
    }
    
    // MARK: - URLSessionDataDelegate
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {
        progressReporters[dataTask]?.progressHandler?(Double(dataTask.countOfBytesReceived) / Double(dataTask.countOfBytesExpectedToReceive))
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let _ = buffers[dataTask] {
            buffers[dataTask]?.append(data)
        } else {
            buffers[dataTask] = data
        }
        progressReporters[dataTask]?.progressHandler?(Double(dataTask.countOfBytesReceived) / Double(dataTask.countOfBytesExpectedToReceive))
    }
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let handler = completionHandlers[task] {
            handler(buffers[task], task.response, error)
            completionHandlers[task] = nil
            progressReporters[task] = nil
            buffers[task] = nil
        }
    }
    
    open func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    
}
