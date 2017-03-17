//
//  Mirror+Util.swift
//  Apic
//
//  Created by Juan Jose Arreola on 16/03/17.
//
//

import Foundation

extension Mirror {
    
    var isAbstractModelMirror: Bool {
        return String(describing: self.subjectType) == String(describing: AbstractModel.self)
    }
    
    func findChild(withName name: String) -> Mirror.Child? {
        for child in children {
            if child.label == name {
                return child
            }
        }
        return nil
    }
}

