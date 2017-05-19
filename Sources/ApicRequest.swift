//
//  ApicRequest.swift
//  Apic
//
//  Created by Juan Jose Arreola on 08/05/17.
//
//

import Foundation
import AsyncRequest

public protocol ProgressReporter: Any {
    var dataTask: URLSessionTask? { get }
    var progressHandler: ((_ progress: Double) -> Void)? { get }
}

open class ApicRequest<T: Any>: Request<T>, ProgressReporter, Equatable {
    
    open var dataTask: URLSessionTask?
    open var progressHandler: ((_ progress: Double) -> Void)?
    
    override open func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
}

public func ==<T>(lhs: ApicRequest<T>, rhs: ApicRequest<T>) -> Bool {
    return lhs.dataTask == rhs.dataTask
}
