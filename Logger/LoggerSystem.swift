//
//  LoggerSystem.swift
//  Logger
//
//  Created by Stefan Braun on 07.03.18.
//  Copyright © 2018 Stefan Braun. All rights reserved.
//

import os


/// Write to system log.
public class LoggerSystem: LoggerProfile {
    public let loggerProfileId: String
    private let subSystem: String
    private let category: String
    private let osLog: OSLog
    private static let levelMap: [String: OSLogType] = [LogLevel.INFO.name: OSLogType.info, LogLevel.DEBUG.name: OSLogType.debug, LogLevel.WARN.name: OSLogType.default, LogLevel.ERROR.name: OSLogType.error, LogLevel.FATAL.name: OSLogType.fault]

    public init(subSystem: String, category: String) {
        loggerProfileId = "com.stbraun.logger.system." + subSystem
        self.subSystem = subSystem
        self.category = category
        self.osLog = OSLog(subsystem: self.subSystem, category: self.category)
    }
    
    public func writeLog(level: String, message: String) {
        os_log("%@", log: osLog, type: LoggerSystem.levelMap[level] ?? OSLogType.default, message)
    }
}
