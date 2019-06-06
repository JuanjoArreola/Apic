import Foundation
import AsyncRequest

open class AbstractRepository: BaseRepository {
    
    public let responseParser: ResponseParser
    let reachabilityManager: ReachabilityManager?
    
    open var responseQueue = DispatchQueue.main
    
    public init(responseParser: ResponseParser, repositorySessionDelegate: RepositorySessionDataDelegate? = nil,
                reachabilityManager: ReachabilityManager? = nil) {
        self.responseParser = responseParser
        self.reachabilityManager = reachabilityManager
        super.init(repositorySessionDelegate: repositorySessionDelegate)
    }
    
    open func requestSuccess(route: Route, parameters: RequestParameters? = nil, success: ((Bool) -> Void)?) -> Request<Bool> {
        let request = URLSessionRequest<Bool>(successHandler: success)
        do {
            request.dataTask = try doRequest(route: route, parameters: parameters, completion: { (data, response, error) in
                do {
                    let success = try self.responseParser.success(from: data, response: response, error: error)
                    request.complete(with: success, in: self.responseQueue)
                } catch {
                    request.complete(with: error, in: self.responseQueue)
                }
            })
        } catch {
            request.complete(with: error, in: responseQueue)
        }
        return request
    }
    
    open func requestObject<T: Decodable>(route: Route, parameters: RequestParameters? = nil, success: ((T) -> Void)?) -> Request<T> {
        let request = URLSessionRequest<T>(successHandler: success)
        do {
            request.dataTask = try doRequest(route: route, parameters: parameters, completion: { (data, response, error) in
                do {
                    let object: T = try self.responseParser.object(from: data, response: response, error: error)
                    request.complete(with: object, in: self.responseQueue)
                } catch {
                    request.complete(with: error, in: self.responseQueue)
                }
            })
        } catch {
            request.complete(with: error, in: responseQueue)
        }
        return request
    }
    
    open func requestArray<T: Decodable>(route: Route, parameters: RequestParameters? = nil, success: (([T]) -> Void)?) -> Request<[T]> {
        let request = URLSessionRequest<[T]>(successHandler: success)
        do {
            request.dataTask = try doRequest(route: route, parameters: parameters, completion: { (data, response, error) in
                do {
                    let array: [T] = try self.responseParser.array(from: data, response: response, error: error)
                    request.complete(with: array, in: self.responseQueue)
                } catch {
                    request.complete(with: error, in: self.responseQueue)
                }
            })
        } catch {
            request.complete(with: error, in: responseQueue)
        }
        return request
    }
}
