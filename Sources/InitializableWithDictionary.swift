//
//  InitializableWithDictionary.swift
//  Apic
//
//  Created by Juan Jose Arreola Simon on 3/20/17.
//
//

import Foundation

public protocol InitializableWithDictionary {
    init(dictionary: [String: Any]) throws
}
