//
//  AbstractRepository.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation
import Alamofire

enum RepositoryError: ErrorType {
    case BadJSON
    case BadJSONContent
    case StatusFail(message: String?, code: Int?)
    case RequestError
}

public class AbstractRepository: NSObject {
    
    class func requestSuccess(method method: Alamofire.Method, url: String, params: [String: AnyObject] = [:], encoding: ParameterEncoding = .URL, completion: (complete: () throws -> Bool) -> Void) -> Request {
        return Alamofire.request(method, url, parameters: params, encoding: encoding).responseJSON { (_, _, result) in
            if result.isSuccess {
                do {
                    let _ = try dataFromJSON(result.value)
                    completion(complete: { return true })
                } catch RepositoryError.StatusFail {
                    completion(complete: { return false })
                } catch {
                    completion(complete: { throw error })
                }
            } else {
                completion(complete: { throw getErrorWithNSError(result.error) })
            }
        }
    }
    
    class func requestObject<T: InitializableWithDictionary>(method: Alamofire.Method, url: String, params: [String: AnyObject] = [:],
        encoding: ParameterEncoding = .URL, completion: (complete: () throws -> T?) -> Void) -> Request {
        return request(method, url, parameters: params, encoding: encoding).responseJSON { (_, _, result) in
            if result.isSuccess {
                do {
                    let data = try dataFromJSON(result.value)
                    guard let obj = data[Configuration.objectKey] as? [String: AnyObject] else {
                        throw RepositoryError.BadJSONContent
                    }
                    let object = try T(dictionary: obj)
                    completion(complete: { return object })
                } catch {
                    completion(complete: { throw error })
                }
            } else {
                completion(complete: { throw getErrorWithNSError(result.error) })
            }
        }
    }
    
    class func requestObjects<T: InitializableWithDictionary>(method: Alamofire.Method, url: String, params: Dictionary<String, AnyObject> = [:], encoding: ParameterEncoding = .URL, completion: (complete: () throws -> [T]?) -> Void) -> Request {
        return request(method, url, parameters: params, encoding: encoding).responseJSON { (_, _, result) in
            
            if result.isSuccess {
                do {
                    let data = try dataFromJSON(result.value)
                    guard let objs = data[Configuration.objectKey] as? [[String: AnyObject]] else {
                        throw RepositoryError.BadJSONContent
                    }
                    var objects = [T]()
                    for obj in objs {
                        objects.append(try T(dictionary: obj))
                    }
                    completion(complete: { return objects })
                } catch {
                    completion(complete: { throw error })
                }
            } else {
                completion(complete: { throw getErrorWithNSError(result.error) })
            }
        }
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
            throw RepositoryError.StatusFail(message: data[Configuration.errorDescriptionKey] as? String, code: data[Configuration.errorCodeKey] as? Int)
        }
    }
    throw RepositoryError.BadJSONContent
}

//                TODO: convert NSError to ErrorType
private func getErrorWithNSError(error: NSError?) -> ErrorType {
    return RepositoryError.RequestError
}
