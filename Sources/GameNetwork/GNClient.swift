//
//  GNClient.swift
//  
//
//  Created by Pavel Kasila on 11/27/20.
//

import Foundation
import NIO
import GRPC

/// GNClient is used to connect to GameNetwork server
@objc public class GNClient: NSObject {
    private static let numberOfThreads = 4
    
    private var group: MultiThreadedEventLoopGroup
    private var greeter: GameNetwork_GreeterClient
    
    /// Creates GNClient connected to host with port
    /// - Parameters:
    ///   - host: host of GN's server
    ///   - port: port of GN's server
    @objc public init(host: String, port: Int) {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: GNClient.numberOfThreads)

        #if DEBUG
        let conn = ClientConnection.insecure(group: self.group)
        #else
        let conn = ClientConnection.secure(group: self.group)
        #endif
        
        let channel = conn
            .connect(host: host, port: port)

        self.greeter = GameNetwork_GreeterClient(channel: channel)
    }
    
    deinit {
        try! group.syncShutdownGracefully()
    }
    
    @objc public func greet(name: String) throws -> String {
        return try greeter.sayHello(GameNetwork_HelloRequest.with {
            $0.name = name
        }).response.wait().message
    }
}
