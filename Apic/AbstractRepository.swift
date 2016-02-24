//
//  AbstractRepository.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation
import Alamofire

private let processQueue: dispatch_queue_t = dispatch_queue_create("com.apic.ProcessQueue", DISPATCH_QUEUE_CONCURRENT)


public enum RepositoryError: ErrorType {
    case BadJSON
    case BadJSONContent
    case InvalidURL
    case InvalidParameters
    case RequestError(message: String?)
    case StatusFail(message: String?, code: String?)
    case NetworkConnection
}

public class AbstractRepository {
    
    public var objectKey: String?
    public var objectsKey: String?
    public var statusKey: String?
    public var statusFail: String?
    public var errorDescriptionKey: String?
    public var errorCodeKey: String?
    
#if os(iOS) || os(OSX) || os(tvOS)
    public var checkReachability = true
#endif
    
    public init(objectKey: String? = nil, objectsKey: String? = nil, statusKey: String? = nil, statusFail: String? = nil, errorDescriptionKey: String? = nil, errorCodeKey: String? = nil) {
        self.objectKey = objectKey
        self.objectsKey = objectsKey
        self.statusKey = statusKey
        self.statusFail = statusFail
        self.errorDescriptionKey = errorDescriptionKey
        self.errorCodeKey = errorCodeKey
    }
    
    public func requestSuccess(method method: Alamofire.Method, url: String, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, headers: [String: String]? = nil, completion: (getSuccess: () throws -> Bool) -> Void) -> Request? {
#if os(iOS) || os(OSX) || os(tvOS)
        if checkReachability && !Reachability.isConnectedToNetwork() {
            completion(getSuccess: { throw RepositoryError.NetworkConnection })
            return nil
        }
#endif
        let request = Alamofire.request(method, url, parameters: params, encoding: encoding, headers: headers)
        request.response(queue: processQueue, responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments)) { (response) in
            if response.result.isFailure {
                dispatch_async(dispatch_get_main_queue()) { completion(getSuccess: { throw response.result.error! }) }
                return
            }
            do {
                try self.dictionaryFromJSON(response.result.value)
                dispatch_async(dispatch_get_main_queue()) { completion(getSuccess: { return true }) }
            } catch RepositoryError.StatusFail {
                dispatch_async(dispatch_get_main_queue()) { completion(getSuccess: { return false }) }
            } catch {
                dispatch_async(dispatch_get_main_queue()) { completion(getSuccess: { throw error }) }
            }
        }
        return request
    }
    
    public func requestObject<T: InitializableWithDictionary>(method: Alamofire.Method, url: String, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, headers: [String: String]? = nil, completion: (getObject: () throws -> T) -> Void) -> Request? {
#if os(iOS) || os(OSX) || os(tvOS)
        if checkReachability && !Reachability.isConnectedToNetwork() {
            completion(getObject: { throw RepositoryError.NetworkConnection })
            return nil
        }
#endif
        let request = Alamofire.request(method, url, parameters: params, encoding: encoding, headers: headers)
        request.response(queue: processQueue, responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments)) { (response) in
            if response.result.isFailure {
                dispatch_async(dispatch_get_main_queue()) { completion(getObject: { throw response.result.error! }) }
                return
            }
            do {
                var dictionary = try self.dictionaryFromJSON(response.result.value)
                if let objectKey = self.objectKey {
                    if let objectDictionary = dictionary[objectKey] as? [String: AnyObject] {
                        dictionary = objectDictionary
                    } else {
                        throw RepositoryError.BadJSONContent
                    }
                }
                let object = try T(dictionary: dictionary)
                dispatch_async(dispatch_get_main_queue()) { completion(getObject: { return object }) }
            } catch {
                dispatch_async(dispatch_get_main_queue()) { completion(getObject: { throw error }) }
            }
        }
        return request
    }
    
    public func requestObjects<T: InitializableWithDictionary>(method: Alamofire.Method, url: String, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, headers: [String: String]? = nil, completion: (getObjects: () throws -> [T]) -> Void) -> Request? {
#if os(iOS) || os(OSX) || os(tvOS)
        if checkReachability && !Reachability.isConnectedToNetwork() {
            completion(getObjects: { throw RepositoryError.NetworkConnection })
            return nil
        }
#endif
        let request = Alamofire.request(method, url, parameters: params, encoding: encoding, headers: headers)
        request.response(queue: processQueue, responseSerializer: Request.JSONResponseSerializer(options: .AllowFragments)) { (response) in
            if response.result.isFailure {
                dispatch_async(dispatch_get_main_queue()) { completion(getObjects: { throw response.result.error! }) }
                return
            }
            do {
                var array: [[String: AnyObject]]!
                if let objectsKey = self.objectsKey {
                    let data = try self.dictionaryFromJSON(response.result.value)
                    array = data[objectsKey] as? [[String: AnyObject]]
                } else {
                    array = response.result.value as? [[String: AnyObject]]
                }
                if array == nil {
                    throw RepositoryError.BadJSONContent
                }
                var objects = [T]()
                for object in array {
                    objects.append(try T(dictionary: object))
                }
                dispatch_async(dispatch_get_main_queue()) { completion(getObjects: { return objects }) }
            } catch {
                dispatch_async(dispatch_get_main_queue()) { completion(getObjects: { throw error }) }
            }
        }
        return request
    }

    private func dictionaryFromJSON(JSON: AnyObject?) throws -> [String: AnyObject] {
        guard let data = JSON as? [String: AnyObject] else {
            throw RepositoryError.BadJSONContent
        }
        guard let statusKey = statusKey, statusFail = statusFail else {
            return data
        }
        guard let status = data[statusKey] as? String else {
            throw RepositoryError.BadJSONContent
        }
        if status == statusFail {
            let message = errorDescriptionKey != nil ? data[errorDescriptionKey!] as? String : nil
            let code = errorCodeKey != nil ? data[errorCodeKey!] as? String : nil
            throw RepositoryError.StatusFail(message: message, code: code)
        }
        return data
    }
    
}
