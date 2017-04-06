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

private let syncQueue: DispatchQueue = DispatchQueue(label: "com.apic.SyncQueue", attributes: .concurrent)

open class Request<T: Any>: CustomDebugStringConvertible, Cancellable {
    
    private var completionHandlers: [(_ getObject: () throws -> T) -> Void]? = []
    private var result: (() throws -> T)?
    
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
    
    open private(set) var canceled = false
    
    required public init() {}
    
    required public init(completionHandler: @escaping (_ getObject: () throws -> T) -> Void) {
        completionHandlers?.append(completionHandler)
    }
    
    public convenience init(subrequest: Cancellable) {
        self.init()
        self.subrequest = subrequest
    }
    
    open func cancel() {
        sync() { self.canceled = true }
        subrequest?.cancel()
        complete(withError: RequestError.canceled)
    }
    
    open func complete(withObject object: T) {
        if result == nil {
            result = { return object }
            callHandlers()
        }
    }
    
    open func complete(withError error: Error) {
        if result == nil {
            result = { throw error }
            callHandlers()
        }
    }
    
    private func callHandlers() {
        guard let getClosure = result else { return }
        completionHandlers?.forEach({ $0(getClosure) })
        sync() { self.completionHandlers = nil }
    }
    
    open func add(completionHandler completion: @escaping (_ getObject: () throws -> T) -> Void) {
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

public protocol ProgressReporter: Any {
    var dataTask: URLSessionTask? { get }
    var progressHandler: ((_ progress: Double) -> Void)? { get }
}

open class ApicRequest<T: Any>: Request<T>, ProgressReporter, Equatable {
    
    open var dataTask: URLSessionTask?
    open var progressHandler: ((_ progress: Double) -> Void)?
    
    public required init(completionHandler: @escaping (_ getObject: () throws -> T) -> Void) {
        super.init(completionHandler: completionHandler)
    }

    required public init() {
        super.init()
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
