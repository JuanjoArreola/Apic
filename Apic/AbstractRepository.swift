//
//  AbstractRepository.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation

public let ERROR_BAD_JSON = 400
public let ERROR_BAD_JSON_CONTENT = 401
public let ERROR_STATUS_FAIL = 402

public let ApicErrorDomain = "com.apic.error"

public class AbstractRepository: NSObject {
    
    class func requestSuccess(method: Method, url: String, params: Dictionary<String, AnyObject> = [:], encoding: ParameterEncoding = .URL, completion: (success: Bool, error: NSError?) -> Void) -> Request {
        return request(method, url, parameters: params, encoding: encoding).responseJSON { (_, _, JSON, error) in
            if error == nil {
                let (data, jsonError) = dataFromJSON(JSON)
                if jsonError == nil {
                    completion(success: true, error: nil)
                } else if jsonError?.code != ERROR_BAD_JSON && jsonError?.code != ERROR_BAD_JSON_CONTENT {
                    completion(success: false, error: nil)
                } else {
                    completion(success: false, error: jsonError)
                }
            } else {
                completion(success: false, error: error)
            }
        }
    }
    
    class func requestObject<T: InitializableWithDictionary>(method: Method, url: String, params: Dictionary<String, AnyObject> = [:],
        encoding: ParameterEncoding = .URL, completion: (object: T?, error: NSError?) -> Void) -> Request {
        return request(method, url, parameters: params, encoding: encoding).responseJSON { (_, _, JSON, error) in
            if error == nil {
                let (data, error) = dataFromJSON(JSON)
                if error == nil {
                    if let obj = data![Configuration.objectKey] as? Dictionary<String, AnyObject> {
                        var object: T? = T(dictionary: obj)
                        if object != nil {
                            completion(object: object, error: nil)
                            return
                        }
                    }
                    completion(object: nil, error: getErrorWithCode(ERROR_BAD_JSON_CONTENT, descriptionKey: "bad_json_content"))
                    return
                }
                completion(object: nil, error: error)
            } else {
                completion(object: nil, error: error)
            }
        }
    }
    
    class func requestObjects<T: InitializableWithDictionary>(method: Method, url: String, params: Dictionary<String, AnyObject> = [:],
        encoding: ParameterEncoding = .URL, completion: (objects: [T]?, error: NSError?) -> Void) -> Request {
            return request(method, url, parameters: params, encoding: encoding).responseJSON { (_, _, JSON, error) in
            if error == nil {
                let (data, jsonError) = dataFromJSON(JSON)
                if jsonError == nil {
                    if let objs = data![Configuration.objectsKey] as? Array<Dictionary<String, AnyObject>> {
                        var objects = [T]()
                        for obj in objs {
                            var object: T? = T(dictionary: obj)
                            if object != nil {
                                objects.append(object!)
                            } else {
                                completion(objects: nil, error: getErrorWithCode(ERROR_BAD_JSON_CONTENT, descriptionKey: "bad_json_content"))
                                return
                            }
                        }
                        completion(objects: objects, error: nil)
                        return
                    }
                }
                completion(objects: nil, error: jsonError)
            } else {
                completion(objects: nil, error: error)
            }
        }
    }
}

private func dataFromJSON(JSON: AnyObject?) -> (data: Dictionary<String, AnyObject>?, error: NSError?) {
    if let data = JSON as? Dictionary<String, AnyObject> {
        if let status = data[Configuration.statusKey] as? String {
            if status == Configuration.statusOk {
                return (data, nil)
            } else {
                let description: String = data[Configuration.errorDescriptionKey] as? String ??
                    NSLocalizedString("status_fail_desc", tableName: "apic_strings", comment: "")
                let code = data[Configuration.errorCodeKey] as? Int ?? ERROR_STATUS_FAIL
                return (nil, NSError(domain: ApicErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: description]))
            }
        } else {
            return (nil, getErrorWithCode(ERROR_BAD_JSON_CONTENT, descriptionKey: "bad_json_content"))
        }
    } else {
        return (nil, getErrorWithCode(ERROR_BAD_JSON, descriptionKey: "bad_json"))
    }
}

private func getErrorWithCode(code: Int, #descriptionKey: String) -> NSError? {
    let tableName = Configuration.useDefaultStrings ? "apic_strings" : "ApicStrings"
    return NSError(domain: ApicErrorDomain, code: code,
        userInfo: [NSLocalizedDescriptionKey: NSLocalizedString(descriptionKey, tableName: tableName, comment: "")])
}
