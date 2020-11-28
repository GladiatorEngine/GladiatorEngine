//
//  GNClient.swift
//  
//
//  Created by Pavel Kasila on 11/27/20.
//

import Foundation

/// GNClient is used to connect to GameNetwork server
@objc public class GNClient: NSObject {
    @objc public override init() {
    }
    
    /// Connects GNClient to GameNetwork server
    /// - Parameters:
    ///   - host: host of GN's server
    ///   - port: port of GN's server
    /// - Throws: any exception
    @objc public func connectTo(host: String, port: Int) throws {
    }
}
