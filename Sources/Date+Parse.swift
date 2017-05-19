//
//  Date+Parse.swift
//  Apic
//
//  Created by Juan Jose Arreola on 17/03/17.
//
//

import Foundation

private var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Configuration.locale
    return formatter
}()

extension Date {
    
    init?(value: Any, format: String) {
        guard let string = value as? String else { return nil }
        self.init(string: string, format: format)
    }
    
    init?(string: String, format: String) {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: string) {
            self = date
        } else {
            return nil
        }
    }
    
    func toString(format: String) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    static var apicFormatter: DateFormatter {
        return dateFormatter
    }
}
