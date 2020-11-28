//
//  GNClient.swift
//  
//
//  Created by Pavel Kasila on 11/27/20.
//

import Foundation
import NIO

/// GNClient is used to connect to GameNetwork server
@objc public class GNClient: NSObject {
    private static let numberOfThreads = 4
    
    private var handler: ServerResponseHandler
    
    private var group: MultiThreadedEventLoopGroup!
    public private(set) var channel: Channel!
    
    @objc public override init() {
        self.handler = ServerResponseHandler()
    }
    
    deinit {
        try! group.syncShutdownGracefully()
    }
    
    /// Connects GNClient to GameNetwork server
    /// - Parameters:
    ///   - host: host of GN's server
    ///   - port: port of GN's server
    /// - Throws: any SwiftNIO exception
    @objc public func connectTo(host: String, port: Int) throws {
        // Initialize connection to server
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: GNClient.numberOfThreads)
        let bootstrap = ClientBootstrap(group: group)
            // Enable SO_REUSEADDR.
            .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer { channel in
                channel.pipeline.addHandler(self.handler)
            }
        self.channel = try bootstrap.connect(host: host, port: port).wait()
    }
}
