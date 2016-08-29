//
//  Log.swift
//  MiCava
//
//  Created by Juanjo on 09/05/15.
//  Copyright (c) 2015 Crayon. All rights reserved.
//

import Foundation

enum LogLevel: Int {
    case debug = 1, warning, error, severe
}

class Log {
    
    static var logLevel = LogLevel(rawValue: Configuration.logLevel) ?? LogLevel.debug
    static var showDate = true
    static var showFile = Configuration.showFile
    static var showFunc = Configuration.showFunc
    static var showLine = Configuration.showLine
    
    static var formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM-dd HH:mm:ss.SSS"
        return f
        }()
    
    class func debug(_ message: @autoclosure () -> Any, file: String = #file, function: StaticString = #function, line: Int = #line) {
        if LogLevel.debug.rawValue >= logLevel.rawValue {
            log("Debug", message: String(describing: message()), file: file, function: function, line: line)
        }
    }
    
    class func warn(_ message: @autoclosure () -> Any, file: String = #file, function: StaticString = #function, line: Int = #line) {
        if LogLevel.warning.rawValue >= logLevel.rawValue {
            log("Warning", message: String(describing: message()), file: file, function: function, line: line)
        }
    }
    
    class func error(_ message: @autoclosure () -> Any, file: String = #file, function: StaticString = #function, line: Int = #line) {
        if LogLevel.error.rawValue >= logLevel.rawValue {
            log("Error", message: String(describing: message()), file: file, function: function, line: line)
        }
    }
    
    class func severe(_ message: @autoclosure () -> Any, file: String = #file, function: StaticString = #function, line: Int = #line) {
        if LogLevel.severe.rawValue >= logLevel.rawValue {
            log("Severe", message: String(describing: message()), file: file, function: function, line: line)
        }
    }
    
    fileprivate class func log(_ level: String, message: String, file: String, function: StaticString, line: Int) {
        var s = ""
        s += showDate ? formatter.string(from: Date()) + " " : ""
        s += showFile ? file.components(separatedBy: "/").last ?? "" : ""
        s += showFunc ? " \(function)" : ""
        s += showLine ? " [\(line)] " : ""
        s += level + ": "
        s += message
        print(s)
    }
    
}
