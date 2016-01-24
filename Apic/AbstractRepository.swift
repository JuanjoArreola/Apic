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
}

public class AbstractRepository {
    
    public class func requestSuccess(method method: Alamofire.Method, url: String, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, completion: (getSuccess: () throws -> Bool) -> Void) -> Request {
        return Alamofire.request(method, url, parameters: params, encoding: encoding).responseJSON { response in
            if response.result.isSuccess {
                do {
                    try dataFromJSON(response.result.value)
                    completion(getSuccess: { return true })
                } catch RepositoryError.StatusFail {
                    completion(getSuccess: { return false })
                } catch {
                    completion(getSuccess: { throw error })
                }
            } else {
                completion(getSuccess: { throw response.result.error! })
            }
        }
    }
    
    public class func requestObject<T: InitializableWithDictionary>(method: Alamofire.Method, url: String, params: [String: AnyObject]? = [:],
        encoding: ParameterEncoding = .URL, completion: (getObject: () throws -> T?) -> Void) -> Request {
        return request(method, url, parameters: params, encoding: encoding).responseJSON { response in
            if response.result.isSuccess {
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
            } else {
                completion(getObject: { throw response.result.error! })
            }
        }
    }
    
    public class func requestObject<T: InitializableWithDictionary>(method: Alamofire.Method, url: String, params: [String: AnyObject]? = [:],
        encoding: ParameterEncoding = .URL, completion: (getObject: () throws -> T) -> Void) -> Request {
            return request(method, url, parameters: params, encoding: encoding).responseJSON { response in
                if response.result.isSuccess {
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
                } else {
                    completion(getObject: { throw response.result.error! })
                }
            }
    }
    
    public class func requestObjects<T: InitializableWithDictionary>(method: Alamofire.Method, url: String, params: [String: AnyObject]? = [:], encoding: ParameterEncoding = .URL, completion: (getObjects: () throws -> [T]) -> Void) -> Request {
        return request(method, url, parameters: params, encoding: encoding).responseJSON { response in
            if response.result.isSuccess {
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
            } else {
                completion(getObjects: { throw response.result.error! })
            }
        }
    }
    
    public class func defaultIdentifier(function: StaticString = __FUNCTION__) -> String {
        return String(self) + ".\(function)"
    }
}

private func dataFromJSON(JSON: AnyObject?) throws -> [String: AnyObject] {
    guard let data = JSON as? [String: AnyObject] else {
        throw RepositoryError.BadJSON
    }
    if let status = data[Configuration.statusKey] as? String {
        if status == Configuration.statusOk {
            return data
        } else {
            throw RepositoryError.StatusFail(message: data[Configuration.errorDescriptionKey] as? String, code: data[Configuration.errorCodeKey] as? String)
        }
    }
    throw RepositoryError.BadJSONContent
}

