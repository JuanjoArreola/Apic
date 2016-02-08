//
//  AbstractRepository.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation
import Alamofire

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
    public var checkReachability = true
    
    public init(objectKey: String? = nil, objectsKey: String? = nil, statusKey: String? = nil, statusFail: String? = nil, errorDescriptionKey: String? = nil, errorCodeKey: String? = nil) {
        self.objectKey = objectKey
        self.objectsKey = objectsKey
        self.statusKey = statusKey
        self.statusFail = statusFail
        self.errorDescriptionKey = errorDescriptionKey
        self.errorCodeKey = errorCodeKey
    }
    
    public func requestSuccess(method method: Alamofire.Method, url: String, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, completion: (getSuccess: () throws -> Bool) -> Void) -> Request? {
        if checkReachability && !Reachability.isConnectedToNetwork() {
            completion(getSuccess: { throw RepositoryError.NetworkConnection })
            return nil
        }
        return Alamofire.request(method, url, parameters: params, encoding: encoding).responseJSON { response in
            if response.result.isFailure {
                completion(getSuccess: { throw response.result.error! })
                return
            }
            do {
                try self.dictionaryFromJSON(response.result.value)
                completion(getSuccess: { return true })
            } catch RepositoryError.StatusFail {
                completion(getSuccess: { return false })
            } catch {
                completion(getSuccess: { throw error })
            }
        }
    }
    
    public func requestObject<T: InitializableWithDictionary>(method: Alamofire.Method, url: String, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, completion: (getObject: () throws -> T) -> Void) -> Request? {
        if checkReachability && !Reachability.isConnectedToNetwork() {
            completion(getObject: { throw RepositoryError.NetworkConnection })
            return nil
        }
        return request(method, url, parameters: params, encoding: encoding).responseJSON { response in
            if response.result.isFailure {
                completion(getObject: { throw response.result.error! })
                return
            }
            do {
                guard let dictionary = try self.dictionaryFromJSON(response.result.value) else {
                    throw RepositoryError.BadJSONContent
                }
                let object = try T(dictionary: dictionary)
                completion(getObject: { return object })
            } catch {
                completion(getObject: { throw error })
            }
        }
    }
    
    public func requestObjects<T: InitializableWithDictionary>(method: Alamofire.Method, url: String, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, completion: (getObjects: () throws -> [T]) -> Void) -> Request? {
        if checkReachability && !Reachability.isConnectedToNetwork() {
            completion(getObjects: { throw RepositoryError.NetworkConnection })
            return nil
        }
        return request(method, url, parameters: params, encoding: encoding).responseJSON { response in
            if response.result.isFailure {
                completion(getObjects: { throw response.result.error! })
                return
            }
            do {
                var array: [[String: AnyObject]]!
                if let objectsKey = self.objectsKey {
                    guard let data = try self.dictionaryFromJSON(response.result.value) else {
                        throw RepositoryError.BadJSONContent
                    }
                    array = data[objectsKey] as? [[String: AnyObject]]
                    if array == nil {
                        throw RepositoryError.BadJSONContent
                    }
                } else {
                    array = response.result.value as? [[String: AnyObject]]
                    if array == nil {
                        throw RepositoryError.BadJSONContent
                    }
                }
                var objects = [T]()
                let start = CFAbsoluteTimeGetCurrent()
                for object in array {
                    objects.append(try T(dictionary: object))
                }
                let end = CFAbsoluteTimeGetCurrent()
                let time = (end - start) * 1000
                Log.debug(">>> \(time) milliseconds")
                
                completion(getObjects: { return objects })
            } catch {
                completion(getObjects: { throw error })
            }
        }
    }

    private func dictionaryFromJSON(JSON: AnyObject?) throws -> [String: AnyObject]? {
        guard let data = JSON as? [String: AnyObject] else {
            return nil
        }
        guard let statusKey = statusKey, statusFail = statusFail else {
            return data
        }
        guard let status = data[statusKey] as? String else {
            return data
        }
        if status == statusFail {
            let message = errorDescriptionKey != nil ? data[errorDescriptionKey!] as? String : nil
            let code = errorCodeKey != nil ? data[errorCodeKey!] as? String : nil
            throw RepositoryError.StatusFail(message: message, code: code)
        }
        return data
    }
    
}
