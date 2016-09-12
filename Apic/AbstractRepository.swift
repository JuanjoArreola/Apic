//
//  AbstractRepository.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation

private let processQueue: DispatchQueue = DispatchQueue(label: "com.apic.ProcessQueue", attributes: DispatchQueue.Attributes.concurrent)

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public enum ParameterEncoding {
    case url
    case json
}

public enum RepositoryError: Error, CustomStringConvertible {
    case badJSON
    case badJSONContent
    case invalidURL
    case invalidParameters
    case statusFail(message: String?, code: String?)
    case networkConnection
    case httpError(statusCode: Int, message: String?)
    case encodingError
    
    public var description: String {
        switch self {
        case .httpError(let statusCode, _):
            return "HTTP Error: \(statusCode)"
        case .badJSON:
            return "Bad JSON"
        case .badJSONContent:
            return "Bad JOSN Content"
        case .invalidURL:
            return "Invalid URL"
        case .invalidParameters:
            return "Invalid parameters"
        case .statusFail(let message, let code):
            return "Status fail(\(code)): \(message)"
        case .networkConnection:
            return "No network connection"
        case .encodingError:
            return "Encoding error"
        }
    }
}

public protocol URLConvertible {
    var URL: Foundation.URL? { get }
}

extension Foundation.URL: URLConvertible {
    public var URL: Foundation.URL? {
        return self
    }
}

extension String: URLConvertible {
    public var URL: Foundation.URL? {
        return Foundation.URL(string: self)
    }
}

open class AbstractRepository<StatusType: Equatable>: NSObject, URLSessionDataDelegate {
    
    open var objectKey: String?
    open var objectsKey: String?
    open var statusKey: String?
    open var statusOk: StatusType?
    open var errorDescriptionKey: String?
    open var errorCodeKey: String?
    
    open var session: Foundation.URLSession?
    open var cachePolicy: NSURLRequest.CachePolicy?
    open var timeoutInterval: TimeInterval?
    open var allowsCellularAccess: Bool?
    
    open var responseQueue = DispatchQueue.main
    
    fileprivate var completionHandlers: [URLSessionTask: (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void] = [:]
    fileprivate var buffers: [URLSessionTask: NSMutableData] = [:]
    fileprivate var progressReporters: [URLSessionTask: ProgressReporter] = [:]
    
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
    
    open func requestSuccess(method: HTTPMethod, url: URLConvertible, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .url, headers: [String: String]? = nil, completion: @escaping (_ getSuccess: () throws -> Bool) -> Void) -> ApicRequest<Bool> {
        let request = ApicRequest(completionHandler: completion)
        guard let URL = url.URL else {
            request.complete(withError: RepositoryError.invalidURL)
            return request
        }
        
        processQueue.async {
            do {
                try self.checkURLReachability(url: URL)
                
                request.dataTask = try self.request(url: URL, method: method, parameters: params, parameterEncoding: encoding, headers: headers) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    do {
                        if let error = error {
                            throw error
                        }
                        if let response = response, let error = self.getError(fromResponse: response, data: data) {
                            throw error
                        }
                        guard let data = data else {
                            throw RepositoryError.badJSON
                        }
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        _ = try self.dictionary(fromJSON: json)
                        self.responseQueue.async { request.complete(withObject: true) }
                    }
                    catch {
                        self.responseQueue.async { request.complete(withError: error) }
                    }
                }
                if self.session?.delegate === self {
                    self.progressReporters[request.dataTask!] = request
                }
            } catch {
                self.responseQueue.async { request.complete(withError: error) }
            }
        }
        return request
    }
    
    open func requestObject<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .url, headers: [String: String]? = nil, completion: @escaping (_ getObject: () throws -> T) -> Void) -> ApicRequest<T> {
        let request = ApicRequest(completionHandler: completion)
        
        guard let URL = url.URL else {
            request.complete(withError: RepositoryError.invalidURL)
            return request
        }

        processQueue.async {
            do {
                try self.checkURLReachability(url: URL)
        
                request.dataTask = try self.request(url: URL, method: method, parameters: params, parameterEncoding: encoding, headers: headers, completion: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    do {
                        if let error = error {
                            throw error
                        }
                        if let response = response, let error = self.getError(fromResponse: response, data: data) {
                            throw error
                        }
                        guard let data = data else {
                            throw RepositoryError.badJSON
                        }
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        var dictionary = try self.dictionary(fromJSON: json)
                        if let objectKey = self.objectKey {
                            if let objectDictionary = dictionary[objectKey] as? [String: AnyObject] {
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
    
    open func requestObjects<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .url, headers: [String: String]? = nil, completion: @escaping (_ getObjects: () throws -> [T]) -> Void) -> ApicRequest<[T]> {
        let request = ApicRequest(completionHandler: completion)

        guard let URL = url.URL else {
            request.complete(withError: RepositoryError.invalidURL)
            return request
        }
        
        processQueue.async {
            do {
                try self.checkURLReachability(url: URL)
                
                request.dataTask = try self.request(url: URL, method: method, parameters: params, parameterEncoding: encoding, headers: headers, completion: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                    do {
                        if let error = error {
                            throw error
                        }
                        if let response = response, let error = self.getError(fromResponse: response, data: data) {
                            throw error
                        }
                        guard let data = data else {
                            throw RepositoryError.badJSON
                        }
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        var array: [[String: AnyObject]]!
                        if let objectsKey = self.objectsKey {
                            let data = try self.dictionary(fromJSON: json)
                            array = data[objectsKey] as? [[String: AnyObject]]
                        } else {
                            array = json as? [[String: AnyObject]]
                        }
                        if array == nil {
                            throw RepositoryError.badJSONContent
                        }
                        var objects = [T]()
                        for object in array {
                            objects.append(try T(dictionary: object))
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
    
    open func request(url: URL, method: HTTPMethod = .GET, parameters: [String: AnyObject]? = [:], parameterEncoding: ParameterEncoding = .url, headers: [String: String]? = nil, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) throws -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let cachePolicy = cachePolicy {
            request.cachePolicy = cachePolicy
        }
        if let timeoutInterval = timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }
        if let allowsCellularAccess = allowsCellularAccess {
            request.allowsCellularAccess = allowsCellularAccess
        }
        if let headers = headers {
            for (header, value) in headers {
                request.addValue(value, forHTTPHeaderField: header)
            }
        }
        try request.encode(parameters: parameters, withEncoding: parameterEncoding)
        let session = self.session ?? Foundation.URLSession.shared
        
        var task: URLSessionDataTask!
        if self.session?.delegate === self {
            task = session.dataTask(with: request)
            completionHandlers[task] = completion
        } else {
            task = session.dataTask(with: request, completionHandler: completion)
        }
        task.resume()
        return task
    }
    
    open func request(url: URL, method: HTTPMethod = .GET, data: Data?, headers: [String: String]? = nil, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) throws -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let cachePolicy = cachePolicy {
            request.cachePolicy = cachePolicy
        }
        if let timeoutInterval = timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }
        if let allowsCellularAccess = allowsCellularAccess {
            request.allowsCellularAccess = allowsCellularAccess
        }
        if let headers = headers {
            for (header, value) in headers {
                request.addValue(value, forHTTPHeaderField: header)
            }
        }
        request.httpBody = data
        let session = self.session ?? Foundation.URLSession.shared
        
        var task: URLSessionDataTask!
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

    func dictionary(fromJSON JSON: Any?) throws -> [String: Any] {
        guard let data = JSON as? [String: AnyObject] else {
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
        throw RepositoryError.statusFail(message: message, code: code)
    }
    
    fileprivate func getError(fromResponse response: URLResponse, data: Data?) -> Error? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return nil
        }
        let code = httpResponse.statusCode
        if code >= 400 && code < 600 {
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
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
    
    // MARK: - NSURLSessionDataDelegate
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {
        progressReporters[dataTask]?.progressHandler?(Double(dataTask.countOfBytesReceived) / Double(dataTask.countOfBytesExpectedToReceive))
        completionHandler(Foundation.URLSession.ResponseDisposition.allow)
    }
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let bufferData = buffers[dataTask] {
            bufferData.append(data)
        } else {
            buffers[dataTask] = NSMutableData(data: data)
        }
        progressReporters[dataTask]?.progressHandler?(Double(dataTask.countOfBytesReceived) / Double(dataTask.countOfBytesExpectedToReceive))
    }
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        completionHandlers[task]?(buffers[task] as Data?, task.response, error as NSError?)
        completionHandlers[task] = nil
        progressReporters[task] = nil
        buffers[task] = nil
    }
    
}
