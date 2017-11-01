import Foundation
import AsyncRequest

open class BaseRepository {
    
    let responseParser: ResponseParser
    
    open var session: URLSession?
    open var cachePolicy: URLRequest.CachePolicy?
    open var timeoutInterval: TimeInterval?
    open var allowsCellularAccess: Bool?
    open var responseQueue = DispatchQueue.main
    open var reachabilityManager: ReachabilityManager?
    open var repositorySessionDelegate: RepositorySessionDataDelegate?
    
    public init(responseParser: ResponseParser) {
        self.responseParser = responseParser
    }
    
    func successHandler(for request: Request<Bool>) -> (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        return { (data, response, error) in
            do {
                let success = try self.responseParser.success(from: data, response: response, error: error)
                request.complete(with: success, in: self.responseQueue)
            } catch {
                request.complete(with: error, in: self.responseQueue)
            }
        }
    }
    
    func objectHandler<T: Decodable>(for request: Request<T>) -> (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        return { (data, response, error) in
            do {
                let object: T = try self.responseParser.object(from: data, response: response, error: error)
                request.complete(with: object, in: self.responseQueue)
            } catch {
                request.complete(with: error, in: self.responseQueue)
            }
        }
    }
    
    func arrayHandler<T: Decodable>(for request: Request<[T]>) -> (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        return { (data, response, error) in
            do {
                let array: [T] = try self.responseParser.array(from: data, response: response, error: error)
                request.complete(with: array, in: self.responseQueue)
            } catch {
                request.complete(with: error, in: self.responseQueue)
            }
        }
    }
    
    func doRequest(route: Route, parameters: HTTPParameters, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) throws -> URLSessionDataTask {
        var request = URLRequest(url: try route.getURL())
        request.httpMethod = route.httpMethod
        request.cachePolicy = cachePolicy ?? request.cachePolicy
        request.timeoutInterval = timeoutInterval ?? request.timeoutInterval
        request.allowsCellularAccess = allowsCellularAccess ?? request.allowsCellularAccess
        parameters.headers?.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key) })
        let parameterEncoding = parameters.encoding ?? route.preferredParameterEncoding
        try request.encode(parameters: parameters.parameters, with: parameterEncoding)
        
        return dataTask(with: request, completion: completion)
    }
    
    func doRequest(route: Route, parameters: [String: Any]? = [:], encoding: ParameterEncoding? = nil, headers: [String: String]? = nil, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) throws -> URLSessionDataTask {
        var request = URLRequest(url: try route.getURL())
        request.httpMethod = route.httpMethod
        request.cachePolicy = cachePolicy ?? request.cachePolicy
        request.timeoutInterval = timeoutInterval ?? request.timeoutInterval
        request.allowsCellularAccess = allowsCellularAccess ?? request.allowsCellularAccess
        headers?.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key) })
        let parameterEncoding = encoding ?? route.preferredParameterEncoding
        try request.encode(parameters: parameters, with: parameterEncoding)
        
        return dataTask(with: request, completion: completion)
    }
    
    func doRequest(route: Route, data: Data, headers: [String: String]? = nil, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) throws -> URLSessionDataTask {
        var request = URLRequest(url: try route.getURL())
        request.httpMethod = route.httpMethod
        request.cachePolicy = cachePolicy ?? request.cachePolicy
        request.timeoutInterval = timeoutInterval ?? request.timeoutInterval
        request.allowsCellularAccess = allowsCellularAccess ?? request.allowsCellularAccess
        headers?.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key) })
        request.httpBody = data
        
        return dataTask(with: request, completion: completion)
    }
    
    @inline(__always) func dataTask(with request: URLRequest, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) -> URLSessionDataTask {
        let session = self.session ?? URLSession.shared
        
        let task: URLSessionDataTask
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

