//
//  Created by Pavel Dolezal on 26/06/15.
//  Copyright (c) 2013 eMan s.r.o. All rights reserved.
//

import Foundation

/**
Simple logging tool for Swift projects.

Use global logger whenever possible:

    #if DEBUG
    Log.enabled = true
    #endif
    Log.level = .Info
    Log.info("Hello \(name)")

Alternatively you can use custom logger which is useful mostly during
develompment time if you are debugging certain parts of the app:

   let privateLogger = Log(level: .Debug)
   privateLogger.debug("User tapped button")
*/
public class Log {
    
    /// Log level indicates how serious the log entry is.
    /// Lower number means higher priority.
    public enum Level: Int {
        case None, Error, Warn, Info, Debug
        
        /// String representation for printing.
        private var str: String {
            switch(self) {
            case .None: return  ""
            case .Error: return "ERROR"
            case .Warn: return  "WARN "
            case .Info: return  "INFO "
            case .Debug: return "DEBUG"
            }
        }
    }
    
    /// Sets wether logging is enabled. Useful for keeping all logging off
    /// for production deployment.
    public static var enabled = false
    
    /// Minimum log level for output. Levels with lower priority are ignored.
    public var level: Level
    
    public init(level: Level) {
        self.level = level
    }
    
    private let dateFormatter: NSDateFormatter = {
        let fmt = NSDateFormatter()
        fmt.locale = NSLocale(localeIdentifier: "en_US")
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return fmt
    }()

    // MARK: - Instance methods

    private func log(level: Level, str: String, file: String = #file, line: Int = #line) {
        if Log.enabled && level.rawValue <= self.level.rawValue {
            let dateString = dateFormatter.stringFromDate(NSDate())
            let url = NSURL(string: file)
            let file: String = url?.lastPathComponent ?? "unknown"
            NSLog("\(dateString) \(level.str) [\(file):\(line)]: \(str)")
        }
    }
    
    /// Logs error if level is at least .Error.
    public func error(str: String, file: String = #file, line: Int = #line) {
        log(.Error, str: str, file: file, line: line)
    }
    
    /// Logs warning if level is at least .Warn.
    public func warn(str: String, file: String = #file, line: Int = #line) {
        log(.Warn, str: str, file: file, line: line)
    }
    
    /// Logs info if level is at least .Info.
    public func info(str: String, file: String = #file, line: Int = #line) {
        log(.Info, str: str, file: file, line: line)
    }
    
    /// Logs error if level is at least .Debug.
    public func debug(str: String, file: String = #file, line: Int = #line) {
        log(.Debug, str: str, file: file, line: line)
    }
    
    // MARK: - Shared logger
    
    static var sharedLogger: Log = Log(level: .Info)
    
    public static var level: Level {
    get {
        return sharedLogger.level
    }
    set {
        sharedLogger.level = newValue
    }
    }
    
    public static func error(str: String, file: String = #file, line: Int = #line) {
        self.sharedLogger.error(str, file: file, line: line)
    }
    
    public static func warn(str: String, file: String = #file, line: Int = #line) {
        self.sharedLogger.warn(str, file: file, line: line)
    }
    
    public static func info(str: String, file: String = #file, line: Int = #line) {
        self.sharedLogger.info(str, file: file, line: line)
    }
    
    public static func debug(str: String, file: String = #file, line: Int = #line) {
        self.sharedLogger.debug(str, file: file, line: line)
    }
   
}
