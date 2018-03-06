import Foundation


public protocol LoggerProfile {
    var loggerProfileId: String {get}
    func writeLog(level: String, message: String)
}

extension LoggerProfile {
    public func getCurrentDateString() -> String{
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd hh:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    public func formatLogMessage(level: String, message: String) -> String {
        let now = getCurrentDateString()
        return "\(now): \(level) - \(message)"
    }
}

public struct LoggerNull: LoggerProfile {
    public init() {}
    public let loggerProfileId = "com.stbraun.logger.null"
    public func writeLog(level: String, message: String) {
        // Do nothing
    }
}

public struct LoggerConsole: LoggerProfile {
    public init() {}
    public let loggerProfileId = "com.stbraun.logger.console"
    public func writeLog(level: String, message: String) {
        print(formatLogMessage(level: level, message: message))
    }
}

public enum LogLevel: Int, Equatable, Comparable, Hashable {
    case FATAL = 5
    case ERROR = 4
    case WARN = 3
    case DEBUG = 2
    case INFO = 1
    
    var name: String {
        return "\(self)"
    }
    
    static let allValues = [INFO, DEBUG, WARN, ERROR, FATAL]
        
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public static func == (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    public var hashValue: Int {
        return self.rawValue
    }

}

public protocol Logger {
    static var loggers: [LogLevel:[LoggerProfile]] { get set }
    static var minLogLevel: LogLevel { get set }
    static func writeLog(logLevel: LogLevel, message: String)
}

extension Logger {
    /// Check the log level and return true if it already contains the logger profile
    static func logLevelContainsProfile(logLevel: LogLevel, loggerProfile: LoggerProfile) -> Bool {
        if let logProfiles = loggers[logLevel] {
            for logProfile in logProfiles where
                logProfile.loggerProfileId == loggerProfile.loggerProfileId {
                    return true
            }
        }
        return false
    }
    
    /// Adds a logger profile to the log level
    static func setLogLevel(logLevel: LogLevel, loggerProfile: LoggerProfile) {
        
        if let _ = loggers[logLevel] {
            if !logLevelContainsProfile(logLevel: logLevel,
                                        loggerProfile: loggerProfile) {
                loggers[logLevel]?.append(loggerProfile)
            }
        } else {
            var a = [LoggerProfile]()
            a.append(loggerProfile)
            loggers[logLevel] = a
        }
    }
    
    ///
    /// Add a logger profile to the log level.
    ///
    /// - paramster logLevel: the `LogLevel` to register the profile for
    /// - paramster loggerProfile: the `LoggerProfile` to add
    ///
    public static func addLogProfileToLevel(logLevel: LogLevel, loggerProfile: LoggerProfile) {
        setLogLevel(logLevel: logLevel, loggerProfile: loggerProfile)
    }
    
    ///
    /// Remove a logger profile from a log level.
    ///
    /// - paramster logLevel: the `LogLevel` to remove the profile from
    /// - paramster loggerProfile: the `LoggerProfile` to remove
    ///
    public static func removeLogProfileFromLevel(logLevel: LogLevel, loggerProfile: LoggerProfile) {
        if var logProfiles = loggers[logLevel] {
            if let index = logProfiles.index(where:
                {$0.loggerProfileId == loggerProfile.loggerProfileId}) {
                logProfiles.remove(at: index)
            }
            loggers[logLevel] = logProfiles
        }
    }

    ///
    /// Add a logger profile to all log levels.
    ///
    /// - paramster loggerProfile: the `LoggerProfile` to add
    ///
    public static func addLogProfileToAllLevels( defaultLoggerProfile: LoggerProfile) {
        for level in LogLevel.allValues {
            setLogLevel(logLevel: level, loggerProfile: defaultLoggerProfile)
        }
    }

    ///
    /// Remove a logger profile from all log levels.
    ///
    /// - paramster loggerProfile: the `LoggerProfile` to remove
    ///
    public static func removeLogProfileFromAllLevels(loggerProfile: LoggerProfile) {
        for level in LogLevel.allValues {
            removeLogProfileFromLevel(logLevel: level,
                                      loggerProfile: loggerProfile)
        }
    }
    
    static func hasLoggerForLevel(logLevel: LogLevel) -> Bool {
        if let loggers = loggers[logLevel] {
            return loggers.count > 0
        }
        return false
    }
    
    public static func fatal(_ message: String) {
        writeLog(logLevel: .FATAL, message: message)
    }
    
    public static func error(_ message: String) {
        writeLog(logLevel: .ERROR, message: message)
    }
    
    public static func warn(_ message: String) {
        writeLog(logLevel: .WARN, message: message)
    }
    
    public static func debug(_ message: String) {
        writeLog(logLevel: .DEBUG, message: message)
    }
    
    public static func info(_ message: String) {
        writeLog(logLevel: .INFO, message: message)
    }
}

public struct Log: Logger {
    public static var loggers = [LogLevel: [LoggerProfile]]()
    public static var minLogLevel = LogLevel.ERROR
    public init() {}
    public static func writeLog(logLevel: LogLevel, message: String) {
        guard minLogLevel <= logLevel else {return }
        guard hasLoggerForLevel(logLevel: logLevel) else {
            print("No logger registered for \(logLevel)")
            return
        }
        if let logProfiles = loggers[logLevel] {
            for logProfile in logProfiles {
                logProfile.writeLog(level: logLevel.name, message: message)
            }
        }
    }
}

