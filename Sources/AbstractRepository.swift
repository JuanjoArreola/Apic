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
    open var checkReachability = true
#endif
    
    private var parser: ResponseParser
    
    public init(responseParser: ResponseParser) {
        self.parser = responseParser
    }
    
    open func requestSuccess(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getSuccess: () throws -> Bool) -> Void) -> ApicRequest<Bool> {
        let request = ApicRequest(completionHandler: completion)
        
        process(request: request, method: method, url: url) { (data, response, error) in
            do {
                _ = try self.parser.object(from: data, response: response, error: error)
                self.responseQueue.async { request.complete(withObject: true) }
            }
            catch {
                self.responseQueue.async { request.complete(withError: error) }
            }
        }
        
        return request
    }
    
    open func requestObject<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getObject: () throws -> T) -> Void) -> ApicRequest<T> {
        let request = ApicRequest(completionHandler: completion)
        
        process(request: request, method: method, url: url, params: params, encoding: encoding, headers: headers) { (data, response, error) in
            do {
                let dictionary = try self.parser.object(from: data, response: response, error: error)
                let object = try T(dictionary: dictionary)
                self.responseQueue.async { request.complete(withObject: object) }
            } catch {
                self.responseQueue.async { request.complete(withError: error) }
            }
        }

        return request
    }
    
    open func requestObjects<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getObjects: () throws -> [T]) -> Void) -> ApicRequest<[T]> {
        let request = ApicRequest(completionHandler: completion)
        
        process(request: request, method: method, url: url, params: params, encoding: encoding, headers: headers) { (data, response, error) in
            do {
                let array = try self.parser.array(from: data, response: response, error: error)
                let objects = try array.map({ try T(dictionary: $0) })
                self.responseQueue.async { request.complete(withObject: objects) }
            } catch {
                self.responseQueue.async { request.complete(withError: error) }
            }
        }

        return request
    }
    
    open func requestDictionaryOfObjects<T: InitializableWithDictionary>(method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ getDictionary: () throws -> [String: T]) -> Void) -> ApicRequest<[String: T]> {
        let request = ApicRequest(completionHandler: completion)
        
        process(request: request, method: method, url: url, params: params, encoding: encoding, headers: headers) { (data: Data?, response: URLResponse?, error: Error?) in
            do {
                let dictionary = try self.parser.dictionary(from: data, response: response, error: error)
                var objects = [String: T]()
                for (key, value) in dictionary {
                    objects[key] = try T(dictionary: value)
                    self.didAssign(object: objects[key]!, to: &objects, withKey: key)
                }
                self.responseQueue.async { request.complete(withObject: objects) }
            } catch {
                self.responseQueue.async { request.complete(withError: error) }
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
    
    @inline(__always) private func process<T>(request: ApicRequest<T>, method: HTTPMethod, url: URLConvertible, params: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        guard let url = url.url else {
            responseQueue.async { request.complete(withError: RepositoryError.invalidURL) }
            return
        }
        processQueue.async {
            do {
                try self.checkURLReachability(url: url)
                let parameterEncoding = encoding ?? method.preferredParameterEncoding
                
                request.dataTask = try self.request(url: url, method: method, parameters: params, parameterEncoding: parameterEncoding, headers: headers, completion: completion)
                
                self.repositorySessionDelegate?.add(reporter: request, for: request.dataTask!)
            } catch {
                self.responseQueue.async { request.complete(withError: error) }
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
    
    @inline(__always) func checkURLReachability(url: URL) throws {
        #if os(iOS) || os(OSX) || os(tvOS)
            if !self.checkReachability {
                return
            }
            guard let info = try? Reachability.reachabilityInfo(forURL: url) else {
                return
            }
            guard let reachable = info.isReachable else {
                return
            }
            if !reachable {
                throw RepositoryError.networkConnection
            }
        #endif
    }
    
}
