//
//  Log.swift
//  MiCava
//
//  Created by Juanjo on 09/05/15.
//  Copyright (c) 2015 Crayon. All rights reserved.
//

import Foundation

enum LogLevel: Int {
    case DEBUG = 1, WARNING, ERROR, SEVERE
}

class Log {
    
    static var logLevel = LogLevel(rawValue: Configuration.logLevel) ?? LogLevel.DEBUG
    static var showDate = true
    static var showFile = Configuration.showFile
    static var showFunc = Configuration.showFunc
    static var showLine = Configuration.showLine
    
    static var formatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "MM-dd HH:mm:ss.SSS"
        return f
        }()
    
    class func debug(@autoclosure message: () -> String, file: String = __FILE__, function: StaticString = __FUNCTION__, line: Int = __LINE__) {
        if LogLevel.DEBUG.rawValue >= logLevel.rawValue {
            log("Debug", message: message(), file: file, function: function, line: line)
        }
    }
    
    class func warn(@autoclosure message: () -> String, file: String = __FILE__, function: StaticString = __FUNCTION__, line: Int = __LINE__) {
        if LogLevel.WARNING.rawValue >= logLevel.rawValue {
            log("Warning", message: message(), file: file, function: function, line: line)
        }
    }
    
    class func error(@autoclosure message: () -> String, file: String = __FILE__, function: StaticString = __FUNCTION__, line: Int = __LINE__) {
        if LogLevel.ERROR.rawValue >= logLevel.rawValue {
            log("Error", message: message(), file: file, function: function, line: line)
        }
    }
    
    class func severe(@autoclosure message: () -> String, file: String = __FILE__, function: StaticString = __FUNCTION__, line: Int = __LINE__) {
        if LogLevel.SEVERE.rawValue >= logLevel.rawValue {
            log("Severe", message: message(), file: file, function: function, line: line)
        }
    }
    
    private class func log(level: String, message: String, file: String, function: StaticString, line: Int) {
        var s = ""
        s += showDate ? formatter.stringFromDate(NSDate()) + " " : ""
        s += showFile ? file.componentsSeparatedByString("/").last ?? "" : ""
        s += showFunc ? " \(function)" : ""
        s += showLine ? " [\(line)] " : ""
        s += level + ": "
        s += message
        print(s)
    }
    
}
