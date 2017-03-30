//
//  Collection+find.swift
//  Apic
//
//  Created by Juan Jose Arreola on 29/03/17.
//
//

import Foundation

public extension Collection {
    
    func find(_ compare: (_ element: Iterator.Element) -> Bool) -> Iterator.Element? {
        for element in self {
            if compare(element) {
                return element
            }
        }
        return nil
    }
}
