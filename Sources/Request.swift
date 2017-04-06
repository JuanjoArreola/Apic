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
    
    private var successHandlers: [(T) -> Void]? = []
    private var errorHandlers: [(Error) -> Void]? = []
    private var finishHandlers: [() -> Void]? = []
    
    private var object: T?
    private var error: Error?
    
    open var subrequest: Cancellable? {
        didSet {
            if canceled {
                subrequest?.cancel()
            }
        }
    }
    
    open var completed: Bool {
        return object != nil || error != nil
    }
    
    open private(set) var canceled = false
    
    required public init() {}
    
    required public init(successHandler: @escaping (T) -> Void) {
        successHandlers?.append(successHandler)
    }
    
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
        complete(with: RequestError.canceled)
    }
    
    open func complete(with object: T) {
        if !completed {
            self.object = object
            callHandlers()
        }
    }
    
    open func complete(with error: Error) {
        if !completed {
            self.error = error
            callHandlers()
        }
    }
    
    @discardableResult
    public func success(handler: @escaping (T) -> Void) -> Self {
        if let object = object {
            handler(object)
        } else if error == nil {
            successHandlers?.append(handler)
        }
        return self
    }
    
    @discardableResult
    public func fail(handler: @escaping (Error) -> Void) -> Self {
        if let error = error {
            handler(error)
        } else if object == nil {
            errorHandlers?.append(handler)
        }
        return self
    }
    
    @discardableResult
    public func finished(handler: @escaping () -> Void) -> Self {
        if completed {
            handler()
        } else {
            finishHandlers?.append(handler)
        }
        return self
    }
    
    private func callHandlers() {
        guard let handlers = completionHandlers else { return }
        if let object = object {
            handlers.forEach({ $0({ return object }) })
            successHandlers?.forEach({ $0(object) })
        } else if let error = error {
            handlers.forEach({ $0({ throw error }) })
            errorHandlers?.forEach({ $0(error) })
        }
        finishHandlers?.forEach({ $0() })
        sync() {
            self.completionHandlers = nil
            self.successHandlers = nil
            self.errorHandlers = nil
            self.finishHandlers = nil
        }
    }
    
    open func add(completionHandler completion: @escaping (_ getObject: () throws -> T) -> Void) {
        if let object = object {
            completion({ return object })
        } else if let error = error {
            completion({ throw error })
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
    
    required public init(successHandler: @escaping (T) -> Void) {
        super.init(successHandler: successHandler)
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
