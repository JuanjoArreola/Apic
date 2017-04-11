//
//  AbstractRepository.swift
//  Apic
//
//  Created by Juanjo on 30/05/15.
//  Copyright (c) 2015 Juanjo. All rights reserved.
//

import Foundation

private let processQueue = DispatchQueue(label: "com.apic.ProcessQueue", attributes: DispatchQueue.Attributes.concurrent)

open class AbstractRepository {
    
    open var session: URLSession?
    open var cachePolicy: URLRequest.CachePolicy?
    open var timeoutInterval: TimeInterval?
    open var allowsCellularAccess: Bool?
    
    open var responseQueue = DispatchQueue.main
    
    open var repositorySessionDelegate: RepositorySessionDataDelegate?
    
#if os(iOS) || os(OSX) || os(tvOS)
    open var reachabilityManager: ReachabilityManager?
#endif
    
    private var parser: ResponseParser
    
    public init(responseParser: ResponseParser) {
        self.parser = responseParser
    }
    
    open func requestSuccess(_ route: Route, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (Bool) -> Void) -> ApicRequest<Bool> {
        let request = ApicRequest<Bool>(successHandler: completion)
        process(request: request, route: route, params: params, encoding: encoding, headers: headers, completion: successHandler(for: request))
        
        return request
    }
    
    open func requestSuccess(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getSuccess: () throws -> Bool) -> Void) -> ApicRequest<Bool> {
        let request = ApicRequest(completionHandler: completion)
        let route = method.route(url: url)
        process(request: request, route: route, params: params, encoding: encoding, headers: headers, completion: successHandler(for: request))
        
        return request
    }
    
    private func successHandler(for request: Request<Bool>) -> (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        return { (data, response, error) in
            do {
                let result = try self.parser.success(from: data, response: response, error: error)
                self.responseQueue.async { request.complete(with: result) }
            }
            catch {
                self.responseQueue.async { request.complete(with: error) }
            }
        }
    }
    
    open func requestObject<T: InitializableWithDictionary>(route: Route, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (T) -> Void) -> ApicRequest<T> {
        let request = ApicRequest(successHandler: completion)
        process(request: request, route: route, params: params, encoding: encoding, headers: headers, completion: objectHandler(for: request))
        
        return request
    }
    
    open func requestObject<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getObject: () throws -> T) -> Void) -> ApicRequest<T> {
        let request = ApicRequest(completionHandler: completion)
        let route = method.route(url: url)
        process(request: request, route: route, params: params, encoding: encoding, headers: headers, completion: objectHandler(for: request))

        return request
    }
    
    func objectHandler<T: InitializableWithDictionary>(for request: Request<T>) -> (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        return { (data, response, error) in
            do {
                let dictionary = try self.parser.object(from: data, response: response, error: error)
                let object = try T(dictionary: dictionary)
                self.responseQueue.async { request.complete(with: object) }
            } catch {
                self.responseQueue.async { request.complete(with: error) }
            }
        }
    }
    
    open func requestObjects<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getObjects: () throws -> [T]) -> Void) -> ApicRequest<[T]> {
        let request = ApicRequest(completionHandler: completion)
        let route = method.route(url: url)
        process(request: request, route: route, params: params, encoding: encoding, headers: headers, completion: objectsHandler(for: request))

        return request
    }
    
    private func objectsHandler<T: InitializableWithDictionary>(for request: ApicRequest<[T]>) -> (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        return { (data, response, error) in
            do {
                let array = try self.parser.array(from: data, response: response, error: error)
                let objects = try array.map({ try T(dictionary: $0) })
                self.responseQueue.async { request.complete(with: objects) }
            } catch {
                self.responseQueue.async { request.complete(with: error) }
            }
        }
    }
    
    open func requestDictionaryOfObjects<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getDictionary: () throws -> [String: T]) -> Void) -> ApicRequest<[String: T]> {
        let request = ApicRequest(completionHandler: completion)
        let route = method.route(url: url)
        
        process(request: request, route: route, params: params, encoding: encoding, headers: headers) { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                let dictionary = try self.parser.dictionary(from: data, response: response, error: error)
                var objects = [String: T]()
                for (key, value) in dictionary {
                    objects[key] = try T(dictionary: value)
                    self.didAssign(object: objects[key]!, to: &objects, withKey: key)
                }
                self.responseQueue.async { request.complete(with: objects) }
            } catch {
                self.responseQueue.async { request.complete(with: error) }
            }
        }

        return request
    }
    
    open func didAssign<T: InitializableWithDictionary>(object: T, to dictionary: inout [String: T], withKey key: String) {
    }
    
    // MARK: -
    
    open func request(url: URL, method: HTTPMethod = .GET, parameters: [String: Any]? = [:], parameterEncoding: ParameterEncoding = .url, headers: [String: String]? = nil, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) throws -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.cachePolicy = cachePolicy ?? request.cachePolicy
        request.timeoutInterval = timeoutInterval ?? request.timeoutInterval
        request.allowsCellularAccess = allowsCellularAccess ?? request.allowsCellularAccess
        headers?.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key) })
        try request.encode(parameters: parameters, with: parameterEncoding)
        
        return dataTask(with: request, completion: completion)
    }
    
    open func request(url: URL, method: HTTPMethod = .GET, data: Data?, headers: [String: String]? = nil, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.cachePolicy = cachePolicy ?? request.cachePolicy
        request.timeoutInterval = timeoutInterval ?? request.timeoutInterval
        request.allowsCellularAccess = allowsCellularAccess ?? request.allowsCellularAccess
        headers?.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key) })
        request.httpBody = data
        
        return dataTask(with: request, completion: completion)
    }
    
    // MARK: -
    
    @inline(__always) private func process<T>(request: ApicRequest<T>, route: Route, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        processQueue.async {
            do {
                let url = try route.url()
                let method = route.method()
                try self.reachabilityManager?.checkReachability(url: url)
                let parameterEncoding = encoding ?? method.preferredParameterEncoding
                
                request.dataTask = try self.request(url: url, method: method, parameters: params, parameterEncoding: parameterEncoding, headers: headers, completion: completion)
                
                self.repositorySessionDelegate?.add(reporter: request, for: request.dataTask!)
            } catch {
                self.responseQueue.async { request.complete(with: error) }
            }
        }
    }
    
    @inline(__always) private func dataTask(with request: URLRequest, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) -> URLSessionDataTask {
        let session = self.session ?? URLSession.shared
        
        var task: URLSessionDataTask
        if let delegate = repositorySessionDelegate {
            task = session.dataTask(with: request)
            delegate.add(completion: completion, for: task)
        } else {
            task = session.dataTask(with: request, completionHandler: completion)
        }
        task.resume()
        return task
    }
    
}
