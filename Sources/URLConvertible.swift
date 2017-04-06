//
//  URLConvertible.swift
//  Apic
//
//  Created by Juan Jose Arreola on 05/04/17.
//
//

import Foundation

public protocol URLConvertible {
    var url: URL? { get }
}

extension URL: URLConvertible {
    public var url: URL? {
        return self
    }
}

extension String: URLConvertible {
    public var url: URL? {
        return URL(string: self)
    }
}
