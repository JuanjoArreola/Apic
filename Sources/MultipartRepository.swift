import Foundation
import AsyncRequest

open class MultipartRepository: BaseRepository {
    
    let boundary = "Boundary-\(UUID().uuidString)"
    
    open func multipartSuccess(url: URL, parts: [Part], params: [String: Any]? = [:], headers: [String: String]? = nil, completion: ((Bool) -> Void)?) -> Request<Bool> {
        let request = URLSessionRequest<Bool>(successHandler: completion)
        do {
            request.dataTask = try multipart(url: url, parts: parts, parameters: params, headers: headers, completion: successHandler(for: request))
        } catch {
            self.responseQueue.async { request.complete(with: error) }
        }
        
        return request
    }
    
    open func multipartObject<T: Decodable>(url: URL, parts: [Part], params: [String: Any]? = [:], headers: [String: String]? = nil, completion: @escaping (T) -> Void) -> Request<T> {
        let request = URLSessionRequest(successHandler: completion)
        do {
            request.dataTask = try multipart(url: url, parts: parts, parameters: params, headers: headers, completion: objectHandler(for: request))
        } catch {
            self.responseQueue.async { request.complete(with: error) }
        }
        return request
    }
    
    open func multipartArray<T: Decodable>(url: URL, parts: [Part], params: [String: Any]? = [:], headers: [String: String]? = nil, completion: @escaping ([T]) -> Void) -> Request<[T]> {
        let request = URLSessionRequest(successHandler: completion)
        do {
            request.dataTask = try multipart(url: url, parts: parts, parameters: params, headers: headers, completion: arrayHandler(for: request))
        } catch {
            self.responseQueue.async { request.complete(with: error) }
        }
        return request
    }
    
    open func multipart(url: URL, parts: [Part], parameters: [String: Any]? = nil, headers: [String: String]? = nil, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) throws -> URLSessionDataTask {
        var data = try parameters?.encode(withBoundary: boundary) ?? Data()
        try parts.forEach({ data.append(try $0.encode(withBoundary: boundary))})
        try data.append(string: "--\(boundary)--\r\n")
        
        return requestMultipart(url: url, data: data, headers: headers, completion: completion)
    }
    
    open func requestMultipart(url: URL, data: Data?, headers: [String: String]? = nil, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = cachePolicy ?? request.cachePolicy
        request.timeoutInterval = timeoutInterval ?? request.timeoutInterval
        request.allowsCellularAccess = allowsCellularAccess ?? request.allowsCellularAccess
        headers?.forEach({ request.addValue($0.value, forHTTPHeaderField: $0.key) })
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        return dataTask(with: request, completion: completion)
    }
}

