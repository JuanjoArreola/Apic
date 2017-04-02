//
//  ChildProperty.swift
//  Apic
//
//  Created by Juan Jose Arreola on 4/2/17.
//
//

import Foundation

struct ChildProperty {
    var name: String
    var type: Any.Type
    
    init?(child: Mirror.Child) {
        if let label = child.label {
            name = label
        } else {
            return nil
        }
        type = type(of: child.value)
    }
}
