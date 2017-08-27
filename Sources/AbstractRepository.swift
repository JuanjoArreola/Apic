import Foundation
import AsyncRequest

open class AbstractRepository: BaseRepository {
    
    let encoder = JSONEncoder()
    
    open func requestSuccess(route: Route, parameters: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: ((Bool) -> Void)?) -> Request<Bool> {
        let request = URLSessionRequest<Bool>(successHandler: completion)
        do {
            try self.reachabilityManager?.checkReachability(route: route)
            request.dataTask = try doRequest(route: route, parameters: parameters, encoding: encoding, headers: headers, completion: successHandler(for: request))
        } catch {
            self.responseQueue.async { request.complete(with: error) }
        }
        return request
    }
    
    open func requestObject<T: Codable>(route: Route, parameters: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: ((T) -> Void)?) -> Request<T> {
        let request = URLSessionRequest<T>(successHandler: completion)
        do {
            try self.reachabilityManager?.checkReachability(route: route)
            request.dataTask = try doRequest(route: route, parameters: parameters, encoding: encoding, headers: headers, completion: objectHandler(for: request))
        } catch {
            self.responseQueue.async { request.complete(with: error) }
        }
        return request
    }
    
    open func requestArray<T: Codable>(route: Route, parameters: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: (([T]) -> Void)?) -> Request<[T]> {
        let request = URLSessionRequest<[T]>(successHandler: completion)
        do {
            try self.reachabilityManager?.checkReachability(route: route)
            request.dataTask = try doRequest(route: route, parameters: parameters, encoding: encoding, headers: headers, completion: arrayHandler(for: request))
        } catch {
            self.responseQueue.async { request.complete(with: error) }
        }
        return request
    }
    
    open func requestDictionary<T: Codable>(route: Route, parameters: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: (([String: T]) -> Void)?) -> Request<[String: T]> {
        let request = URLSessionRequest<[String: T]>(successHandler: completion)
        do {
            try self.reachabilityManager?.checkReachability(route: route)
            request.dataTask = try doRequest(route: route, parameters: parameters, encoding: encoding, headers: headers, completion: dictionaryHandler(for: request))
        } catch {
            self.responseQueue.async { request.complete(with: error) }
        }
        return request
    }
    
    // MARK: -
    
    open func requestObject<T: Codable, U: Encodable>(route: Route, body: U, headers: [String: String]? = nil, completion: ((T) -> Void)?) -> Request<T> {
        let request = URLSessionRequest<T>(successHandler: completion)
        do {
            try self.reachabilityManager?.checkReachability(route: route)
            let data = try encoder.encode(body)
            request.dataTask = try doRequest(route: route, data: data, headers: headers, completion: objectHandler(for: request))
        } catch {
            self.responseQueue.async { request.complete(with: error) }
        }
        return request
    }
}
