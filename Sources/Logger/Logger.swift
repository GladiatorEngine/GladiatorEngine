//
//  Logger.swift
//  
//
//  Created by Pavel Kasila on 11/26/20.
//

import Foundation
import LoggerC

/// Messages priority for `Logger`
@objc public enum LoggerType: UInt8 {
    case debug = 0x00
    case info = 0x01
    case lowWarning = 0x02
    case highWarning = 0x03
    case error = 0x04
}

extension LoggerType {
    public func loggableString() -> String {
        switch self {
        case .debug:
            return "DBG"
        case .info:
            return "INFO"
        case .lowWarning:
            return "LWARN"
        case .highWarning:
            return "HWARN"
        case .error:
            return "ERR"
        }
    }
}

@objc public class Logger: NSObject {
    #if DEBUG
    private static let loggingPriorityLevel = LoggerType.info.rawValue
    #else
    private static let loggingPriorityLevel = LoggerType.highWarning.rawValue
    #endif
    
    @objc public private(set) var path: String?
    private var logger: UnsafeMutablePointer<LoggerFile>?
    
    /// Initializes Logger with or without logging to file
    /// - Parameter path: optional String: if is set - Logger writes to file with this path, if `nil` - doesn't write to file
    @objc public init(path: String? = nil) {
        self.path = path
        self.logger = path != nil ? logger_init(path!.cString(using: .utf8)) : nil
    }
    
    deinit {
        logger_deinit(self.logger)
    }
    
    /// Writes message to log
    /// - Parameters:
    ///   - message: message that should be written to log
    ///   - type: message's type, priority
    @objc public func write(message: String, type: LoggerType) {
        #if !DEBUG
        if type == .debug {
            return
        }
        #endif
        let fullMessage = "[\(Date().isoString()) - \(type.loggableString())] \(message)"
        if type.rawValue >= Logger.loggingPriorityLevel {
            print(fullMessage)
        }
        if self.logger != nil {
            logger_write(fullMessage.cString(using: .utf8), self.logger)
        }
    }
}
