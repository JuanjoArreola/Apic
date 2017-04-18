//
//  AbstractRequestRepository.swift
//  Apic
//
//  Created by Juan Jose Arreola on 18/04/17.
//
//

import Foundation


open class AbstractRequestRepository: BaseRepository {
    
    open func requestSuccess(_ route: Route, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (Bool) -> Void) -> ApicRequest<Bool> {
        let request = ApicRequest<Bool>(successHandler: completion)
        process(request: request, route: route, params: params, encoding: encoding, headers: headers, completion: successHandler(for: request))
        
        return request
    }
    
    open func requestObject<T: InitializableWithDictionary>(route: Route, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (T) -> Void) -> ApicRequest<T> {
        let request = ApicRequest(successHandler: completion)
        process(request: request, route: route, params: params, encoding: encoding, headers: headers, completion: objectHandler(for: request))
        
        return request
    }
    
    open func requestObjects<T: InitializableWithDictionary>(route: Route, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping ([T]) -> Void) -> ApicRequest<[T]> {
        let request = ApicRequest(successHandler: completion)
        process(request: request, route: route, params: params, encoding: encoding, headers: headers, completion: objectsHandler(for: request))
        
        return request
    }
    
    open func requestDictionaryOfObjects<T: InitializableWithDictionary>(route: Route, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping ([String: T]) -> Void) -> ApicRequest<[String: T]> {
        let request = ApicRequest(successHandler: completion)
        process(request: request, route: route, params: params, encoding: encoding, headers: headers, completion: dictionaryHandler(for: request))
        
        return request
    }
    
}
