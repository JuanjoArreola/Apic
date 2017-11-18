import Foundation
import AsyncRequest

open class BaseRepository {
    
    let repositorySessionDelegate: RepositorySessionDataDelegate?
    
    let boundary = "Boundary-\(UUID().uuidString)"
    
    open var cachePolicy: URLRequest.CachePolicy?
    open var timeoutInterval: TimeInterval?
    open var allowsCellularAccess: Bool?
    open var session: URLSession?
    
    public init(repositorySessionDelegate: RepositorySessionDataDelegate? = nil) {
        self.repositorySessionDelegate = repositorySessionDelegate
    }
    
    func doRequest(route: Route, parameters: RequestParameters?, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) throws -> URLSessionDataTask {
        var request = URLRequest(url: try route.getURL())
        request.httpMethod = route.httpMethod
        request.cachePolicy = cachePolicy ?? request.cachePolicy
        request.timeoutInterval = timeoutInterval ?? request.timeoutInterval
        request.allowsCellularAccess = allowsCellularAccess ?? request.allowsCellularAccess
        
        try parameters?.preprocess()
        parameters?.headers?.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key) })
        if let params = parameters {
            try setParameters(params, to: &request, route: route)
        }
        return dataTask(with: request, completion: completion)
    }
    
    func setParameters(_ parameters: RequestParameters, to request: inout URLRequest, route: Route) throws {
        if let data = parameters.data {
            request.httpBody = data
        } else if let partData = try parameters.getData(withBoundary: boundary) {
            var data = try parameters.parameters?.encode(withBoundary: boundary) ?? Data()
            data.append(partData)
            request.httpBody = data
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        } else if let params = parameters.parameters {
            let encoding = parameters.encoding ?? route.preferredParameterEncoding
            try request.encode(parameters: params, with: encoding)
        }
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

