//
//  IntInitializable.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 3/19/17.
//
//

import Foundation

public protocol IntInitializable: AnyInitializable {
    init?(rawValue: Int)
}

protocol IntRepresentable {
    var rawValue: Int { get }
}

public extension IntInitializable {
    init?(value: Any) {
        if let int = value as? Int {
            self.init(rawValue: int)
        } else {
            return nil
        }
    }
}
