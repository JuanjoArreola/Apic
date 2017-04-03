//
//  Log.swift
//
//  Created by Juanjo on 09/05/15.
//

import Foundation

public enum LogLevel: Int {
    case debug, warning, error
    
    var name: String {
        switch self {
        case .debug: return "Debug"
        case .warning: return "Warning"
        case .error: return "Error"
        }
    }
}

public class Log {
    
    public static var logLevels: [LogLevel] = [.debug, .warning, .error]
    public static var showDate = true
    public static var showLocation = false
    
    private static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    public class func debug(_ message: @autoclosure () -> Any) {
        log(message, level: .debug)
    }
    
    public class func warn(_ message: @autoclosure () -> Any) {
        log(message, level: .warning)
    }
    
    public class func error(_ message: @autoclosure () -> Any) {
        log(message, level: .error)
    }
    
    private class func log(_ message: () -> Any, level: LogLevel) {
        if !logLevels.contains(level) { return }
        
        var string = showDate ? formatter.string(from: Date()) + " " : ""
        string += level.name + ": " + String(describing: message())
        print(string)
    }
}
