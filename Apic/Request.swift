//
//  Request.swift
//  Apic
//
//  Created by Juan Jose Arreola on 3/2/16.
//  Copyright © 2016 Juanjo. All rights reserved.
//

import Foundation

public enum RequestError: Error {
    case canceled
}

public protocol Cancellable {
    func cancel()
}

private let syncQueue: DispatchQueue = DispatchQueue(label: "com.apic.SyncQueue", attributes: DispatchQueue.Attributes.concurrent)

open class Request<T: Any>: CustomDebugStringConvertible, Cancellable {
    
    fileprivate var completionHandlers: [(_ getObject: () throws -> T) -> Void]? = []
    fileprivate var result: (() throws -> T)?
    
    open var subrequest: Cancellable? {
        didSet {
            if canceled {
                subrequest?.cancel()
            }
        }
    }
    
    open var completed: Bool {
        return result != nil
    }
    
    open fileprivate(set) var canceled = false
    
    required public init() {}
    
    public required init(completionHandler: @escaping (_ getObject: () throws -> T) -> Void) {
        completionHandlers!.append(completionHandler)
    }
    
    public convenience init(subrequest: Cancellable) {
        self.init()
        self.subrequest = subrequest
    }
    
    open func cancel() {
        sync() { self.canceled = true }
        subrequest?.cancel()
        completeWithError(RequestError.canceled)
    }
    
    open func completeWithObject(_ object: T) {
        if result == nil {
            result = { return object }
            callHandlers()
        }
    }
    
    open func completeWithError(_ error: Error) {
        if result == nil {
            result = { throw error }
            callHandlers()
        }
    }
    
    fileprivate func callHandlers() {
        guard let getClosure = result else { return }
        for handler in completionHandlers! {
            handler(getClosure)
        }
        sync() { self.completionHandlers = nil }
    }
    
    open func addCompletionHandler(_ completion: @escaping (_ getObject: () throws -> T) -> Void) {
        if let getClosure = result {
            completion(getClosure)
        } else {
            sync() { self.completionHandlers?.append(completion) }
        }
    }
    
    open var debugDescription: String {
        return String(describing: Unmanaged.passUnretained(self).toOpaque())
    }
}

private func sync(_ closure: @escaping () -> Void) {
    syncQueue.async(flags: .barrier, execute: closure)
}

public protocol ProgressReporter: AnyObject {
    var dataTask: URLSessionDataTask? { get }
    var progressHandler: ((_ progress: Double) -> Void)? { get }
}

open class ApicRequest<T: Any>: Request<T>, ProgressReporter, Equatable {
    
    open internal(set) var dataTask: URLSessionDataTask?
    open var progressHandler: ((_ progress: Double) -> Void)?
    
    public required init(completionHandler: @escaping (_ getObject: () throws -> T) -> Void) {
        super.init(completionHandler: completionHandler)
    }

    required public init() {
        fatalError("init() has not been implemented")
    }
    
    override open func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
    
    override open var debugDescription: String {
        var desc = "ApicRequest<\(T.self)>"
        if let url = dataTask?.originalRequest?.url {
            desc += "(\(url))"
        }
        return desc
    }
}

public func ==<T>(lhs: ApicRequest<T>, rhs: ApicRequest<T>) -> Bool {
    return lhs.dataTask == rhs.dataTask
}
