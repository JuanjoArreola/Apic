//
//  Part.swift
//  Apic
//
//  Created by Juan Jose Arreola on 07/06/17.
//
//

import Foundation

public class Part {
    var type: String
    var name: String
    var filename: String
    var data: Data
    
    public init(type: String, name: String, filename: String, data: Data) {
        self.type = type
        self.name = name
        self.filename = filename
        self.data = data
    }
    
    convenience init(mimeType type: MimeType, name: String, filename: String, data: Data) {
        self.init(type: type.rawValue, name: name, filename: filename, data: data)
    }
    
    func encode(withBoundary boundary: String) throws -> Data {
        var content = Data()
        try content.append(string: "--\(boundary)\r\n")
        try content.append(string: "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        try content.append(string: "Content-Type: \(type)\r\n\r\n")
        content.append(data)
        try content.append(string: "\r\n")
        return content
    }
}

enum MimeType: String {
    case bmp = "image/bmp"
    case css = "text/css"
    case csv = "text/csv"
    case html = "text/html"
    case json = "application/json"
    case jpeg = "image/jpeg"
    case png = "image/png"
    case text = "text/plain"
}
