import Foundation
import AsyncRequest

open class BaseRepository {
    open var session: URLSession?
    open var cachePolicy: URLRequest.CachePolicy?
    open var timeoutInterval: TimeInterval?
    open var allowsCellularAccess: Bool?
    open var responseQueue = DispatchQueue.main
    open var responseParser: ResponseParser
    open var reachabilityManager: ReachabilityManager?
    open var repositorySessionDelegate: RepositorySessionDataDelegate?
    
    public init(responseParser: ResponseParser) {
        self.responseParser = responseParser
    }
    
    func successHandler(for request: Request<Bool>) -> (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        return { (data, response, error) in
            do {
                let success = try self.responseParser.success(from: data, response: response, error: error)
                self.responseQueue.async { request.complete(with: success) }
            } catch {
                self.responseQueue.async { request.complete(with: error) }
            }
        }
    }
    
    func objectHandler<T: Codable>(for request: Request<T>) -> (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        return { (data, response, error) in
            do {
                let object: T = try self.responseParser.object(from: data, response: response, error: error)
                self.responseQueue.async { request.complete(with: object) }
            } catch {
                self.responseQueue.async { request.complete(with: error) }
            }
        }
    }
    
    func arrayHandler<T: Codable>(for request: Request<[T]>) -> (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        return { (data, response, error) in
            do {
                let array: [T] = try self.responseParser.array(from: data, response: response, error: error)
                self.responseQueue.async { request.complete(with: array) }
            } catch {
                self.responseQueue.async { request.complete(with: error) }
            }
        }
    }
    
    func dictionaryHandler<T: Codable>(for request: Request<[String: T]>) -> (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void {
        return { (data, response, error) in
            do {
                let array: [String: T] = try self.responseParser.dictionary(from: data, response: response, error: error)
                self.responseQueue.async { request.complete(with: array) }
            } catch {
                self.responseQueue.async { request.complete(with: error) }
            }
        }
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

