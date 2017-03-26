//
//  Log.swift
//
//  Created by Juanjo on 09/05/15.
//

import Foundation

public enum LogLevel: Int, Comparable {
    case debug = 1, warning, error, severe
    
    var name: String {
        switch self {
        case .debug: return "Debug"
        case .warning: return "Warning"
        case .error: return "Error"
        case .severe: return "Severe"
        }
    }
}

public func <(left: LogLevel, right: LogLevel) -> Bool {
    return left.rawValue < right.rawValue
}

public class Log {
    
    public static var logLevel = LogLevel.debug
    public static var showDate = true
    public static var showLocation = true
    
    private static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    public class func debug(_ message: @autoclosure () -> Any, file: String = #file, function: StaticString = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    public class func warn(_ message: @autoclosure () -> Any, file: String = #file, function: StaticString = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    public class func error(_ message: @autoclosure () -> Any, file: String = #file, function: StaticString = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    public class func severe(_ message: @autoclosure () -> Any, file: String = #file, function: StaticString = #function, line: Int = #line) {
        log(message, level: .severe, file: file, function: function, line: line)
    }
    
    private class func log(_ message: () -> Any, level: LogLevel, file: String, function: StaticString, line: Int) {
        if level < logLevel { return }
        var string = ""
        string += showDate ? formatter.string(from: Date()) + " " : ""
        if showLocation {
            let file = file.components(separatedBy: "/").last ?? ""
            string += "\(file) \(function) [\(line)] "
        }
        string += level.name + ": " + String(describing: message())
        print(string)
    }
}
