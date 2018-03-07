//
//  LoggerTests.swift
//  LoggerTests
//
//  Created by Stefan Braun on 06.03.18.
//  Copyright © 2018 Stefan Braun. All rights reserved.
//

import XCTest
//@testable import Logger

class LoggerForTest: LoggerProfile {
    var level: String = ""
    var message: String = ""
    var loggerProfileId = "com.stbraun.LoggerForTest"
    func writeLog(level: String, message: String) {
        self.level = level
        self.message = message
    }
}

class LoggerTests: XCTestCase {
    
    let loggerForTest = LoggerForTest()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Log.addLogProfileToAllLevels(defaultLoggerProfile: loggerForTest)
        loggerForTest.message = ""
        loggerForTest.level = ""
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        Log.removeLogProfileFromAllLevels(loggerProfile: loggerForTest)
    }
    
    /// Try to erite a log with a above below minimal log level
    func testWriteAbove() {
        Log.minLogLevel = LogLevel.ERROR
        Log.fatal("Fatal")
        XCTAssertEqual("Fatal", loggerForTest.message)
        XCTAssertEqual("FATAL", loggerForTest.level)
    }
    
    /// Try to erite a log with a level equal to minimal log level
    func testWriteEqual() {
        Log.minLogLevel = LogLevel.ERROR
        Log.error("Error")
        XCTAssertEqual("Error", loggerForTest.message)
        XCTAssertEqual("ERROR", loggerForTest.level)
    }
    
    /// Try to erite a log with a level below minimal log level
    func testWriteBelow() {
        Log.minLogLevel = LogLevel.ERROR
        Log.debug("Debug")
        XCTAssertEqual("", loggerForTest.message)
        XCTAssertEqual("", loggerForTest.level)
    }
    
    /// Test registration of logger profile for all levels
    func testLoggerProfileForAllLevels() {
        Log.addLogProfileToAllLevels(defaultLoggerProfile: loggerForTest)
        for level in LogLevel.allValues {
            XCTAssert(Log.hasLoggerForLevel(logLevel: level))
        }
    }
    
    /// Test removing a logger profile from all levels
    func testRemoveLoggerProfilesFromAllLevels() {
        // verify that profile is set for all levels.
        testLoggerProfileForAllLevels()
        Log.removeLogProfileFromAllLevels(loggerProfile: loggerForTest)
        for level in LogLevel.allValues {
            XCTAssertFalse(Log.hasLoggerForLevel(logLevel: level))
        }
    }
    
    /// Test registration of logger profiles for specific levels
    func testLoggerProfileForSpecificLevels() {
        for testLevel in LogLevel.allValues {
            testRemoveLoggerProfilesFromAllLevels()
            Log.addLogProfileToLevel(logLevel: testLevel, loggerProfile: loggerForTest)
            for level in LogLevel.allValues {
                if level == testLevel {
                    XCTAssert(Log.hasLoggerForLevel(logLevel: level))
                } else {
                    XCTAssertFalse(Log.hasLoggerForLevel(logLevel: level))
                }
            }
        }

    }
    
    /// Test removing a logger profile from a specific level
    func testRemoveLoggerProfilesFromSpecificLevel() {
        // verify that profile is set for all levels.
        for testLevel in LogLevel.allValues {
            testLoggerProfileForAllLevels()
            Log.removeLogProfileFromLevel(logLevel: testLevel, loggerProfile: loggerForTest)
            for level in LogLevel.allValues {
                if level == testLevel {
                    XCTAssertFalse(Log.hasLoggerForLevel(logLevel: level))
                } else {
                    XCTAssert(Log.hasLoggerForLevel(logLevel: level))
                }
            }
        }
    }
    
    /// Test registration of error logging profile
    func testErrorLoggingProfile() {
        testRemoveLoggerProfilesFromAllLevels()
        Log.addLogProfileToErrorLevels(errorLoggerProfile: loggerForTest)
        let errorLevels = [LogLevel.ERROR, LogLevel.FATAL]
        for level in LogLevel.allValues {
            if errorLevels.contains(level) {
                XCTAssert(Log.hasLoggerForLevel(logLevel: level))
            } else {
                XCTAssertFalse(Log.hasLoggerForLevel(logLevel: level))
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
