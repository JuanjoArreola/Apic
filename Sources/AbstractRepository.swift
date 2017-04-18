//
//  AbstractRepository.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation

open class AbstractRepository: BaseRepository {
    
    open func requestSuccess(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getSuccess: () throws -> Bool) -> Void) -> ApicRequest<Bool> {
        let request = ApicRequest(completionHandler: completion)
        let route = method.route(url: url)
        process(request: request, route: route, params: params, encoding: encoding, headers: headers, completion: successHandler(for: request))
        
        return request
    }
    
    open func requestObject<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getObject: () throws -> T) -> Void) -> ApicRequest<T> {
        let request = ApicRequest(completionHandler: completion)
        let route = method.route(url: url)
        process(request: request, route: route, params: params, encoding: encoding, headers: headers, completion: objectHandler(for: request))

        return request
    }
    
    open func requestObjects<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getObjects: () throws -> [T]) -> Void) -> ApicRequest<[T]> {
        let request = ApicRequest(completionHandler: completion)
        let route = method.route(url: url)
        process(request: request, route: route, params: params, encoding: encoding, headers: headers, completion: objectsHandler(for: request))

        return request
    }
    
    open func requestDictionaryOfObjects<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getDictionary: () throws -> [String: T]) -> Void) -> ApicRequest<[String: T]> {
        let request = ApicRequest(completionHandler: completion)
        let route = method.route(url: url)
        process(request: request, route: route, params: params, encoding: encoding, headers: headers, completion: dictionaryHandler(for: request))

        return request
    }
    
}
