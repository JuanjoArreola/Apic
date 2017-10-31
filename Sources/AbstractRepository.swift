import Foundation
import AsyncRequest

open class AbstractRepository: BaseRepository {
    
    public var encoder = JSONEncoder()
    
    open func requestSuccess(route: Route, parameters: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: ((Bool) -> Void)?) -> Request<Bool> {
        let request = URLSessionRequest<Bool>(successHandler: completion)
        do {
            try self.reachabilityManager?.checkReachability(route: route)
            request.dataTask = try doRequest(route: route, parameters: parameters, encoding: encoding, headers: headers, completion: successHandler(for: request))
        } catch {
            request.complete(with: error, in: responseQueue)
        }
        return request
    }
    
    open func requestObject<T: Decodable>(route: Route, parameters: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: ((T) -> Void)?) -> Request<T> {
        let request = URLSessionRequest<T>(successHandler: completion)
        do {
            try self.reachabilityManager?.checkReachability(route: route)
            request.dataTask = try doRequest(route: route, parameters: parameters, encoding: encoding, headers: headers, completion: objectHandler(for: request))
        } catch {
            request.complete(with: error, in: responseQueue)
        }
        return request
    }
    
    open func requestArray<T: Decodable>(route: Route, parameters: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: (([T]) -> Void)?) -> Request<[T]> {
        let request = URLSessionRequest<[T]>(successHandler: completion)
        do {
            try self.reachabilityManager?.checkReachability(route: route)
            request.dataTask = try doRequest(route: route, parameters: parameters, encoding: encoding, headers: headers, completion: arrayHandler(for: request))
        } catch {
            request.complete(with: error, in: responseQueue)
        }
        return request
    }
    
    // MARK: - Encodable body
    
    open func requestObject<T: Decodable, U: Encodable>(route: Route, body: U, headers: [String: String]? = nil, completion: ((T) -> Void)?) -> Request<T> {
        let request = URLSessionRequest<T>(successHandler: completion)
        do {
            try self.reachabilityManager?.checkReachability(route: route)
            let data = try encoder.encode(body)
            request.dataTask = try doRequest(route: route, data: data, headers: headers, completion: objectHandler(for: request))
        } catch {
            request.complete(with: error, in: responseQueue)
        }
        return request
    }
    
    open func requestArray<T: Decodable, U: Encodable>(route: Route, body: U, headers: [String: String]? = nil, completion: (([T]) -> Void)?) -> Request<[T]> {
        let request = URLSessionRequest<[T]>(successHandler: completion)
        do {
            try self.reachabilityManager?.checkReachability(route: route)
            let data = try encoder.encode(body)
            request.dataTask = try doRequest(route: route, data: data, headers: headers, completion: arrayHandler(for: request))
        } catch {
            request.complete(with: error, in: responseQueue)
        }
        return request
    }
    
    open func requestSuccess<U: Encodable>(route: Route, body: U, headers: [String: String]? = nil, completion: ((Bool) -> Void)?) -> Request<Bool> {
        let request = URLSessionRequest<Bool>(successHandler: completion)
        do {
            try self.reachabilityManager?.checkReachability(route: route)
            let data = try encoder.encode(body)
            request.dataTask = try doRequest(route: route, data: data, headers: headers, completion: successHandler(for: request))
        } catch {
            request.complete(with: error, in: responseQueue)
        }
        return request
    }
}
