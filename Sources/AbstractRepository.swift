import Foundation
import AsyncRequest

open class AbstractRepository: BaseRepository {
    
    public var encoder = JSONEncoder()
    
    open func requestSuccess(route: Route, parameters: HTTPParameters, completion: ((Bool) -> Void)?) -> Request<Bool> {
        let request = URLSessionRequest<Bool>(successHandler: completion)
        do {
            try self.reachabilityManager?.checkReachability(route: route)
            request.dataTask = try doRequest(route: route, parameters: parameters, completion: successHandler(for: request))
        } catch {
            request.complete(with: error, in: responseQueue)
        }
        return request
    }
    
    open func requestObject<T: Decodable>(route: Route, parameters: HTTPParameters, completion: ((T) -> Void)?) -> Request<T> {
        let request = URLSessionRequest<T>(successHandler: completion)
        do {
            try self.reachabilityManager?.checkReachability(route: route)
            request.dataTask = try doRequest(route: route, parameters: parameters, completion: objectHandler(for: request))
        } catch {
            request.complete(with: error, in: responseQueue)
        }
        return request
    }
    
    open func requestArray<T: Decodable>(route: Route, parameters: HTTPParameters, completion: (([T]) -> Void)?) -> Request<[T]> {
        let request = URLSessionRequest<[T]>(successHandler: completion)
        do {
            try self.reachabilityManager?.checkReachability(route: route)
            request.dataTask = try doRequest(route: route, parameters: parameters, completion: arrayHandler(for: request))
        } catch {
            request.complete(with: error, in: responseQueue)
        }
        return request
    }
}

public struct HTTPParameters {
    let parameters: [String: Any]?
    var headers: [String: String]?
    let encoding: ParameterEncoding?
    let data: Data?
    
    init(parameters: [String: Any]? = nil, encoding: ParameterEncoding? = nil, headers: [String: String]? = nil) {
        self.parameters = parameters
        self.encoding = encoding
        self.headers = headers
        self.data = nil
    }
    
    init<T: Encodable>(body: T, headers: [String: String]? = nil) throws {
        self.parameters = nil
        self.encoding = nil
        self.headers = headers
        self.data = try JSONEncoder().encode(body)
    }
}
