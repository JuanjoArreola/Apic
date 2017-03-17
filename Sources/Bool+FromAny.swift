//
//  Bool+FromAny.swift
//  Apic
//
//  Created by Juan Jose Arreola on 16/03/17.
//
//

import Foundation

extension Bool {
    init?(value: Any?) {
        guard let value = value else { return nil }
        if let bool = value as? Bool {
            self = bool
        }
        else if let string = value as? String {
            switch string.lowercased() {
            case "true", "t", "1":
                self = true
            case "false", "f", "0":
                self = false
            default:
                return nil
            }
        }
        else if let number = value as? NSNumber {
            self = Bool(number)
        }
        else {
            return nil
        }
    }
}
