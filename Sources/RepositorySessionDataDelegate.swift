import Foundation

open class RepositorySessionDataDelegate: NSObject, URLSessionDataDelegate {
    
    private var completionHandlers: [URLSessionTask: (Data?, URLResponse?, Error?) -> Void] = [:]
    private var buffers: [URLSessionTask: Data] = [:]
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let _ = buffers[dataTask] {
            buffers[dataTask]?.append(data)
        } else {
            buffers[dataTask] = data
        }
    }
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let handler = completionHandlers[task] {
            handler(buffers[task], task.response, error)
            completionHandlers[task] = nil
            buffers[task] = nil
        }
    }
    
    open func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    
    func add(completion: @escaping (Data?, URLResponse?, Error?) -> Void, for task: URLSessionTask) {
        completionHandlers[task] = completion
    }
}
