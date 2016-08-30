//
//  Request.swift
//  Apic
//
//  Created by Juan Jose Arreola on 3/2/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import Foundation

public enum RequestError: ErrorType {
    case Canceled
}

public protocol Cancellable {
    func cancel()
}

private let syncQueue: dispatch_queue_t = dispatch_queue_create("com.apic.SyncQueue", DISPATCH_QUEUE_CONCURRENT)

public class Request<T: Any>: CustomDebugStringConvertible, Cancellable {
    
    private var completionHandlers: [(getObject: () throws -> T) -> Void]? = []
    private var result: (() throws -> T)?
    
    public var subrequest: Cancellable? {
        didSet {
            if canceled {
                subrequest?.cancel()
            }
        }
    }
    
    public var completed: Bool {
        return result != nil
    }
    
    public private(set) var canceled = false
    
    required public init() {}
    
    public required init(completionHandler: (getObject: () throws -> T) -> Void) {
        completionHandlers!.append(completionHandler)
    }
    
    public convenience init(subrequest: Cancellable) {
        self.init()
        self.subrequest = subrequest
    }
    
    public func cancel() {
        sync() { self.canceled = true }
        subrequest?.cancel()
        completeWithError(RequestError.Canceled)
    }
    
    public func completeWithObject(object: T) {
        if result == nil {
            result = { return object }
            callHandlers()
        }
    }
    
    public func completeWithError(error: ErrorType) {
        if result == nil {
            result = { throw error }
            callHandlers()
        }
    }
    
    private func callHandlers() {
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
        return String(unsafeAddressOf(self))
    }
}

private func sync(closure: () -> Void) {
    dispatch_barrier_async(syncQueue, closure)
}

public protocol ProgressReporter: AnyObject {
    var dataTask: NSURLSessionDataTask? { get }
    var progressHandler: ((progress: Double) -> Void)? { get }
}

public class ApicRequest<T: Any>: Request<T>, ProgressReporter, Equatable {
    
    public internal(set) var dataTask: NSURLSessionDataTask?
    public var progressHandler: ((progress: Double) -> Void)?
    
    public required init(completionHandler: (getObject: () throws -> T) -> Void) {
        super.init(completionHandler: completionHandler)
    }
    
    override public func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
    
    override public var debugDescription: String {
        var desc = "ApicRequest<\(T.self)>"
        if let url = dataTask?.originalRequest?.URL {
            desc += "(\(url))"
        }
        return desc
    }
}

public func ==<T>(lhs: ApicRequest<T>, rhs: ApicRequest<T>) -> Bool {
    return lhs.dataTask == rhs.dataTask
}