//
//  Request.swift
//  Apic
//
//  Created by Juan Jose Arreola on 3/2/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import Foundation

enum RequestError: ErrorType {
    case Canceled
}

private let syncQueue: dispatch_queue_t = dispatch_queue_create("com.apic.SyncQueue", DISPATCH_QUEUE_CONCURRENT)

public class Request<T: Any>: CustomDebugStringConvertible {
    
    private var completionHandlers: [(getObject: () throws -> T) -> Void]? = []
    private var result: (() throws -> T)?
    
    var subrequest: Request? {
        didSet {
            if canceled {
                subrequest?.cancel()
            }
        }
    }
    
    public var completed: Bool {
        return result != nil
    }
    
    public var canceled = false
    
    required public init() {}
    
    public required init(completionHandler: (getObject: () throws -> T) -> Void) {
        completionHandlers!.append(completionHandler)
    }
    
    public func cancel() {
        sync() { self.canceled = true }
        subrequest?.cancel()
        completeWithError(RequestError.Canceled)
    }
    
    func completeWithObject(object: T) {
        if result == nil {
            result = { return object }
            callHandlers()
        }
    }
    
    func completeWithError(error: ErrorType) {
        if result == nil {
            result = { throw error }
            callHandlers()
        }
    }
    
    func callHandlers() {
        guard let getClosure = result else { return }
        for handler in completionHandlers! {
            handler(getObject: getClosure)
        }
        sync() { self.completionHandlers = nil }
    }
    
    public func addCompletionHandler(completion: (getObject: () throws -> T) -> Void) {
        if let getClosure = result {
            completion(getObject: getClosure)
        } else {
            sync() { self.completionHandlers?.append(completion) }
        }
    }
    
    public var debugDescription: String {
        return String(self)
    }
}

private func sync(closure: () -> Void) {
    dispatch_barrier_async(syncQueue, closure)
}


public class URLRequest<T: Any>: Request<T> {
    
    public var dataTask: NSURLSessionDataTask?
    
    public required init(completionHandler: (getObject: () throws -> T) -> Void) {
        super.init(completionHandler: completionHandler)
    }
    
    override public func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
    
    override public var debugDescription: String {
        var desc = "URLRequest<\(T.self)>"
        if let url = dataTask?.originalRequest?.URL {
            desc += "(\(url))"
        }
        return desc
    }
}