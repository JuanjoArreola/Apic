//
//  Float+FromAny.swift
//  Apic
//
//  Created by Juan Jose Arreola on 16/03/17.
//
//

import Foundation

extension Float {
    init?(value: Any?) {
        guard let value = value else { return nil }
        if let float = value as? Float {
            self = float
        }
        else if let string = value as? String {
            if let float = Float(string) {
                self = float
            } else {
                return nil
            }
        }
        else if let double = value as? Double {
            self = Float(double)
        } else {
            return nil
        }
    }
}
