//
//  AbstractRepository.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation

private let processQueue: dispatch_queue_t = dispatch_queue_create("com.apic.ProcessQueue", DISPATCH_QUEUE_CONCURRENT)

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public enum ParameterEncoding {
    case URL
    case JSON
}

public enum RepositoryError: ErrorType, CustomStringConvertible {
    case BadJSON
    case BadJSONContent
    case InvalidURL
    case InvalidParameters
    case StatusFail(message: String?, code: String?)
    case NetworkConnection
    case HTTPError(statusCode: Int, message: String?)
    case EncodingError
    
    public var description: String {
        switch self {
        case .HTTPError(let statusCode, _):
            return "HTTP Error: \(statusCode)"
        case BadJSON:
            return "Bad JSON"
        case .BadJSONContent:
            return "Bad JOSN Content"
        case InvalidURL:
            return "Invalid URL"
        case InvalidParameters:
            return "Invalid parameters"
        case StatusFail(let message, let code):
            return "Status fail(\(code)): \(message)"
        case NetworkConnection:
            return "No network connection"
        case EncodingError:
            return "Encoding error"
        }
    }
}

public protocol URLConvertible {
    var URL: NSURL? { get }
}

extension NSURL: URLConvertible {
    public var URL: NSURL? {
        return self
    }
}

extension String: URLConvertible {
    public var URL: NSURL? {
        return NSURL(string: self)
    }
}

public class AbstractRepository<StatusType: Equatable>: NSObject, NSURLSessionDataDelegate {
    
    public var objectKey: String?
    public var objectsKey: String?
    public var statusKey: String?
    public var statusOk: StatusType?
    public var errorDescriptionKey: String?
    public var errorCodeKey: String?
    
    public var session: NSURLSession?
    public var cachePolicy: NSURLRequestCachePolicy?
    public var timeoutInterval: NSTimeInterval?
    public var allowsCellularAccess: Bool?
    
    public var responseQueue = dispatch_get_main_queue()
    
    private var completionHandlers: [NSURLSessionTask: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void] = [:]
    private var buffers: [NSURLSessionTask: NSMutableData] = [:]
    private var progressReporters: [NSURLSessionTask: ProgressReporter] = [:]
    
#if os(iOS) || os(OSX) || os(tvOS)
    public var checkReachability = true
#endif
    
    public init(objectKey: String? = nil, objectsKey: String? = nil, statusKey: String? = nil, statusOk: StatusType? = nil, errorDescriptionKey: String? = nil, errorCodeKey: String? = nil) {
        self.objectKey = objectKey
        self.objectsKey = objectsKey
        self.statusKey = statusKey
        self.statusOk = statusOk
        self.errorDescriptionKey = errorDescriptionKey
        self.errorCodeKey = errorCodeKey
    }
    
    public func requestSuccess(method method: HTTPMethod, url: URLConvertible, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, headers: [String: String]? = nil, completion: (getSuccess: () throws -> Bool) -> Void) -> ApicRequest<Bool> {
        let request = ApicRequest(completionHandler: completion)
        guard let URL = url.URL else {
            request.completeWithError(RepositoryError.InvalidURL)
            return request
        }
        
        dispatch_async(processQueue) {
            do {
                try self.checkURLReachability(URL)
                
                request.dataTask = try self.requestURL(URL, method: method, parameters: params, parameterEncoding: encoding, headers: headers) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    do {
                        if let error = error {
                            throw error
                        }
                        if let response = response, error = self.getErrorFromResponse(response, data: data) {
                            throw error
                        }
                        guard let data = data else {
                            throw RepositoryError.BadJSON
                        }
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                        try self.dictionaryFromJSON(json)
                        dispatch_async(self.responseQueue) { request.completeWithObject(true) }
                    }
                    catch {
                        dispatch_async(self.responseQueue) { request.completeWithError(error) }
                    }
                }
                if self.session?.delegate === self {
                    self.progressReporters[request.dataTask!] = request
                }
            } catch {
                dispatch_async(self.responseQueue) { request.completeWithError(error) }
            }
        }
        return request
    }
    
    public func requestObject<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, headers: [String: String]? = nil, completion: (getObject: () throws -> T) -> Void) -> ApicRequest<T> {
        let request = ApicRequest(completionHandler: completion)
        
        guard let URL = url.URL else {
            request.completeWithError(RepositoryError.InvalidURL)
            return request
        }

        dispatch_async(processQueue) {
            do {
                try self.checkURLReachability(URL)
        
                request.dataTask = try self.requestURL(URL, method: method, parameters: params, parameterEncoding: encoding, headers: headers, completion: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    do {
                        if let error = error {
                            throw error
                        }
                        if let response = response, error = self.getErrorFromResponse(response, data: data) {
                            throw error
                        }
                        guard let data = data else {
                            throw RepositoryError.BadJSON
                        }
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                        var dictionary = try self.dictionaryFromJSON(json)
                        if let objectKey = self.objectKey {
                            if let objectDictionary = dictionary[objectKey] as? [String: AnyObject] {
                                dictionary = objectDictionary
                            } else {
                                throw RepositoryError.BadJSONContent
                            }
                        }
                        let object = try T(dictionary: dictionary)
                        dispatch_async(self.responseQueue) { request.completeWithObject(object) }
                    } catch {
                        dispatch_async(self.responseQueue) { request.completeWithError(error) }
                    }
                })
                if self.session?.delegate === self {
                    self.progressReporters[request.dataTask!] = request
                }
            } catch {
                dispatch_async(self.responseQueue) { request.completeWithError(error) }
            }
        }
        return request
    }
    
    public func requestObjects<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, headers: [String: String]? = nil, completion: (getObjects: () throws -> [T]) -> Void) -> ApicRequest<[T]> {
        let request = ApicRequest(completionHandler: completion)

        guard let URL = url.URL else {
            request.completeWithError(RepositoryError.InvalidURL)
            return request
        }
        
        dispatch_async(processQueue) {
            do {
                try self.checkURLReachability(URL)
                
                request.dataTask = try self.requestURL(URL, method: method, parameters: params, parameterEncoding: encoding, headers: headers, completion: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    do {
                        if let error = error {
                            throw error
                        }
                        if let response = response, error = self.getErrorFromResponse(response, data: data) {
                            throw error
                        }
                        guard let data = data else {
                            throw RepositoryError.BadJSON
                        }
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                        var array: [[String: AnyObject]]!
                        if let objectsKey = self.objectsKey {
                            let data = try self.dictionaryFromJSON(json)
                            array = data[objectsKey] as? [[String: AnyObject]]
                        } else {
                            array = json as? [[String: AnyObject]]
                        }
                        if array == nil {
                            throw RepositoryError.BadJSONContent
                        }
                        var objects = [T]()
                        for object in array {
                            objects.append(try T(dictionary: object))
                        }
                        dispatch_async(self.responseQueue) { request.completeWithObject(objects) }
                    } catch {
                        dispatch_async(self.responseQueue) { request.completeWithError(error) }
                    }
                })
                if self.session?.delegate === self {
                    self.progressReporters[request.dataTask!] = request
                }
            } catch {
                dispatch_async(self.responseQueue) { request.completeWithError(error) }
            }
        }
        return request
    }
    
    public func requestURL(url: NSURL, method: HTTPMethod = .GET, parameters: [String: AnyObject]? = [:], parameterEncoding: ParameterEncoding = .URL, headers: [String: String]? = nil, completion: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) throws -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
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
        try request.encodeParameters(parameters, withEncoding: parameterEncoding)
        let session = self.session ?? NSURLSession.sharedSession()
        
        var task: NSURLSessionDataTask!
        if self.session?.delegate === self {
            task = session.dataTaskWithRequest(request)
            completionHandlers[task] = completion
        } else {
            task = session.dataTaskWithRequest(request, completionHandler: completion)
        }
        task.resume()
        return task
    }
    
    public func requestURL(url: NSURL, method: HTTPMethod = .GET, data: NSData?, headers: [String: String]? = nil, completion: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) throws -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method.rawValue
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
        request.HTTPBody = data
        let session = self.session ?? NSURLSession.sharedSession()
        
        var task: NSURLSessionDataTask!
        if self.session?.delegate === self {
            task = session.dataTaskWithRequest(request)
            completionHandlers[task] = completion
        } else {
            task = session.dataTaskWithRequest(request, completionHandler: completion)
        }
        task.resume()
        return task
    }
    
    @inline(__always) func checkURLReachability(url: NSURL) throws {
        #if os(iOS) || os(OSX) || os(tvOS)
            if !self.checkReachability {
                return
            }
            guard let info = try? Reachability.reachabilityInfoForURL(url) else {
                return
            }
            guard let reachable = info.isReachable else {
                return
            }
            if !reachable {
                throw RepositoryError.NetworkConnection
            }
        #endif
    }

    private func dictionaryFromJSON(JSON: AnyObject?) throws -> [String: AnyObject] {
        guard let data = JSON as? [String: AnyObject] else {
            throw RepositoryError.BadJSONContent
        }
        guard let statusKey = statusKey, statusOk = statusOk else {
            return data
        }
        guard let status = data[statusKey] as? StatusType else {
            throw RepositoryError.BadJSONContent
        }
        if status == statusOk {
            return data
        }
        let message = errorDescriptionKey != nil ? data[errorDescriptionKey!] as? String : nil
        let code = errorCodeKey != nil ? data[errorCodeKey!] as? String : nil
        throw RepositoryError.StatusFail(message: message, code: code)
    }
    
    private func getErrorFromResponse(response: NSURLResponse, data: NSData?) -> RepositoryError? {
        guard let httpResponse = response as? NSHTTPURLResponse else {
            return nil
        }
        let code = httpResponse.statusCode
        if code >= 400 && code < 600 {
            if let data = data, json = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] {
                if let key = errorDescriptionKey, message = json?[key] as? String, codeKey = errorCodeKey, code = json?[codeKey] as? String {
                    return RepositoryError.StatusFail(message: message, code: code)
                }
            }
            var message: String?
            if let data = data {
                message = String(data: data, encoding: NSISOLatin1StringEncoding)
            }
            return RepositoryError.HTTPError(statusCode: code, message: message)
        }
        return nil
    }
    
    // MARK: - NSURLSessionDataDelegate
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        progressReporters[dataTask]?.progressHandler?(progress: Double(dataTask.countOfBytesReceived) / Double(dataTask.countOfBytesExpectedToReceive))
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let data = buffers[dataTask] {
            data.appendData(data)
        } else {
            buffers[dataTask] = NSMutableData(data: data)
        }
        progressReporters[dataTask]?.progressHandler?(progress: Double(dataTask.countOfBytesReceived) / Double(dataTask.countOfBytesExpectedToReceive))
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        completionHandlers[task]?(data: buffers[task], response: task.response, error: error)
        completionHandlers[task] = nil
        progressReporters[task] = nil
        buffers[task] = nil
    }
    
}
