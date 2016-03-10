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

public enum RepositoryError: ErrorType {
    case BadJSON
    case BadJSONContent
    case InvalidURL
    case InvalidParameters
    case RequestError(message: String?)
    case StatusFail(message: String?, code: String?)
    case NetworkConnection
    case HTTPError(statusCode: Int)
    case EncodingError
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

public class AbstractRepository<StatusType: Equatable> {
    
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
#if os(iOS) || os(OSX) || os(tvOS)
        if checkReachability && !Reachability.isConnectedToNetwork() {
            request.completeWithError(RepositoryError.NetworkConnection)
            return request
        }
#endif
        guard let URL = url.URL else {
            request.completeWithError(RepositoryError.InvalidURL)
            return request
        }
        dispatch_async(processQueue) {
            do {
                request.dataTask = try self.requestURL(URL, method: method, parameters: params, parameterEncoding: encoding, headers: headers) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    do {
                        if let error = error {
                            throw error
                        }
                        if let response = response, error = self.getErrorFromResponse(response) {
                            throw error
                        }
                        guard let data = data else {
                            throw RepositoryError.BadJSON
                        }
                        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                        try self.dictionaryFromJSON(json)
                        dispatch_async(dispatch_get_main_queue()) { request.completeWithObject(true) }
                    }
                    catch RepositoryError.StatusFail {
                        dispatch_async(dispatch_get_main_queue()) { request.completeWithObject(false) }
                    }
                    catch {
                        dispatch_async(dispatch_get_main_queue()) { request.completeWithError(error) }
                    }
                }
            } catch {
                dispatch_async(dispatch_get_main_queue()) { request.completeWithError(error) }
            }
        }
        return request
    }
    
    public func requestObject<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, headers: [String: String]? = nil, completion: (getObject: () throws -> T) -> Void) -> ApicRequest<T> {
        let request = ApicRequest(completionHandler: completion)
#if os(iOS) || os(OSX) || os(tvOS)
        if checkReachability && !Reachability.isConnectedToNetwork() {
            request.completeWithError(RepositoryError.NetworkConnection)
            return request
        }
#endif
        guard let URL = url.URL else {
            request.completeWithError(RepositoryError.InvalidURL)
            return request
        }
        
        dispatch_async(processQueue) {
            do {
                request.dataTask = try self.requestURL(URL, method: method, parameters: params, parameterEncoding: encoding, headers: headers, completion: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    do {
                        if let error = error {
                            throw error
                        }
                        if let response = response, error = self.getErrorFromResponse(response) {
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
                        dispatch_async(dispatch_get_main_queue()) { request.completeWithObject(object) }
                    } catch {
                        dispatch_async(dispatch_get_main_queue()) { request.completeWithError(error) }
                    }
                })
            } catch {
                dispatch_async(dispatch_get_main_queue()) { request.completeWithError(error) }
            }
        }
        return request
    }
    
    public func requestObjects<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, headers: [String: String]? = nil, completion: (getObjects: () throws -> [T]) -> Void) -> ApicRequest<[T]> {
        let request = ApicRequest(completionHandler: completion)
#if os(iOS) || os(OSX) || os(tvOS)
        if checkReachability && !Reachability.isConnectedToNetwork() {
            request.completeWithError(RepositoryError.NetworkConnection)
            return request
        }
#endif
        guard let URL = url.URL else {
            request.completeWithError(RepositoryError.InvalidURL)
            return request
        }
        dispatch_async(processQueue) {
            do {
                request.dataTask = try self.requestURL(URL, method: method, parameters: params, parameterEncoding: encoding, headers: headers, completion: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                    do {
                        if let error = error {
                            throw error
                        }
                        if let response = response, error = self.getErrorFromResponse(response) {
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
                        dispatch_async(dispatch_get_main_queue()) { request.completeWithObject(objects) }
                    } catch {
                        dispatch_async(dispatch_get_main_queue()) { request.completeWithError(error) }
                    }
                })
            } catch {
                dispatch_async(dispatch_get_main_queue()) { request.completeWithError(error) }
            }
        }
        return request
    }
    
    func requestURL(url: NSURL, method: HTTPMethod = .GET, parameters: [String: AnyObject]? = [:], parameterEncoding: ParameterEncoding = .URL, headers: [String: String]? = nil, completion: ((data: NSData?, response: NSURLResponse?, error:NSError?)) -> Void) throws -> NSURLSessionDataTask {
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
        
        let task = session.dataTaskWithRequest(request, completionHandler: completion)
        task.resume()
        return task
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
    
    private func getErrorFromResponse(response: NSURLResponse) -> ErrorType? {
        guard let httpResponse = response as? NSHTTPURLResponse else {
            return nil
        }
        let code = httpResponse.statusCode
        if code >= 400 && code < 600 {
            return RepositoryError.HTTPError(statusCode: code)
        }
        return nil
    }
    
}
