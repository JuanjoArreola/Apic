//
//  RepositorySessionDataDelegate.swift
//  Apic
//
//  Created by Juan Jose Arreola on 05/04/17.
//
//

import Foundation

open class RepositorySessionDataDelegate: NSObject, URLSessionDataDelegate {
    
    private var completionHandlers: [URLSessionTask: (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void] = [:]
    private var buffers: [URLSessionTask: Data] = [:]
    private var progressReporters: [URLSessionTask: ProgressReporter] = [:]
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {
        progressReporters[dataTask]?.progressHandler?(Double(dataTask.countOfBytesReceived) / Double(dataTask.countOfBytesExpectedToReceive))
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let _ = buffers[dataTask] {
            buffers[dataTask]?.append(data)
        } else {
            buffers[dataTask] = data
        }
        progressReporters[dataTask]?.progressHandler?(Double(dataTask.countOfBytesReceived) / Double(dataTask.countOfBytesExpectedToReceive))
    }
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let handler = completionHandlers[task] {
            handler(buffers[task], task.response, error)
            completionHandlers[task] = nil
            progressReporters[task] = nil
            buffers[task] = nil
        }
    }
    
    open func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    
    func add(reporter: ProgressReporter, for task: URLSessionTask) {
        progressReporters[task] = reporter
    }
    
    func add(completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void, for task: URLSessionTask) {
        completionHandlers[task] = completion
    }
}
