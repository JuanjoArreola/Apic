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
    
    public class func requestSuccess(method method: Alamofire.Method, url: String, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, completion: (getSuccess: () throws -> Bool) -> Void) -> Request? {
        if Configuration.checkReachability && !Reachability.isConnectedToNetwork() {
            completion(getSuccess: { throw RepositoryError.NetworkConnection })
            return nil
        }
        return Alamofire.request(method, url, parameters: params, encoding: encoding).responseJSON { response in
            if response.result.isFailure {
                completion(getSuccess: { throw response.result.error! })
                return
            }
            do {
                try dataFromJSON(response.result.value)
                completion(getSuccess: { return true })
            } catch RepositoryError.StatusFail {
                completion(getSuccess: { return false })
            } catch {
                completion(getSuccess: { throw error })
            }
        }
    }
    
    public class func requestObject<T: InitializableWithDictionary>(method: Alamofire.Method, url: String, params: [String: AnyObject]? = [:],
        encoding: ParameterEncoding = .URL, completion: (getObject: () throws -> T?) -> Void) -> Request? {
        if Configuration.checkReachability && !Reachability.isConnectedToNetwork() {
            completion(getObject: { throw RepositoryError.NetworkConnection })
            return nil
        }
        return request(method, url, parameters: params, encoding: encoding).responseJSON { response in
            if response.result.isFailure {
                completion(getObject: { throw response.result.error! })
                return
            }
            do {
                let data = try dataFromJSON(response.result.value)
                guard let obj = data[Configuration.objectKey] as? [String: AnyObject] else {
                    completion(getObject: { return nil })
                    return
                }
                let object = try T(dictionary: obj)
                completion(getObject: { return object })
            } catch {
                completion(getObject: { throw error })
            }
        }
    }
    
    public class func requestObject<T: InitializableWithDictionary>(method: Alamofire.Method, url: String, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, completion: (getObject: () throws -> T) -> Void) -> Request? {
        if Configuration.checkReachability && !Reachability.isConnectedToNetwork() {
            completion(getObject: { throw RepositoryError.NetworkConnection })
            return nil
        }
        return request(method, url, parameters: params, encoding: encoding).responseJSON { response in
            if response.result.isFailure {
                completion(getObject: { throw response.result.error! })
                return
            }
            do {
                let data = try dataFromJSON(response.result.value)
                guard let obj = data[Configuration.objectKey] as? [String: AnyObject] else {
                    throw RepositoryError.BadJSONContent
                }
                let object = try T(dictionary: obj)
                completion(getObject: { return object })
            } catch {
                completion(getObject: { throw error })
            }
        }
    }
    
    public class func requestObjects<T: InitializableWithDictionary>(method: Alamofire.Method, url: String, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, completion: (getObjects: () throws -> [T]) -> Void) -> Request? {
        if Configuration.checkReachability && !Reachability.isConnectedToNetwork() {
            completion(getObjects: { throw RepositoryError.NetworkConnection })
            return nil
        }
        return request(method, url, parameters: params, encoding: encoding).responseJSON { response in
            if response.result.isFailure {
                completion(getObjects: { throw response.result.error! })
                return
            }
            do {
                let data = try dataFromJSON(response.result.value)
                guard let objs = data[Configuration.objectsKey] as? [[String: AnyObject]] else {
                    throw RepositoryError.BadJSONContent
                }
                var objects = [T]()
                for obj in objs {
                    objects.append(try T(dictionary: obj))
                }
                completion(getObjects: { return objects })
            } catch {
                completion(getObjects: { throw error })
            }
        }
    }

}

private func dataFromJSON(JSON: AnyObject?) throws -> [String: AnyObject] {
    guard let data = JSON as? [String: AnyObject] else {
        throw RepositoryError.BadJSON
    }
    guard let status = data[Configuration.statusKey] as? String else {
        throw RepositoryError.BadJSONContent
    }
    if status == Configuration.statusOk {
        return data
    } else {
        throw RepositoryError.StatusFail(message: data[Configuration.errorDescriptionKey] as? String, code: data[Configuration.errorCodeKey] as? String)
    }
}
