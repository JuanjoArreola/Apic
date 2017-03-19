//
//  StringInitializable.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 3/19/17.
//
//

import Foundation

public protocol StringInitializable: AnyInitializable {
    init?(rawValue: String)
}

public protocol StringRepresentable: StringInitializable {
    var rawValue: String { get }
}

extension StringInitializable {
    
    init?(value: Any) {
        if let string = value as? String {
            self.init(rawValue: string)
        } else {
            return nil
        }
    }
}
