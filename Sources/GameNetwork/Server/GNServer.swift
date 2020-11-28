//
//  GNServer.swift
//  
//
//  Created by Pavel Kasila on 11/28/20.
//

import GRPC
import Foundation
import NIO
import NIOSSL

@objc public class GNServer: NSObject {
    private static let numberOfThreads = 4
    
    private var group: MultiThreadedEventLoopGroup!
    
    private var certificatePath: String
    private var privateKeyPath: String
    
    @objc public init(certificatePath: String, privateKeyPath: String) {
        self.certificatePath = certificatePath
        self.privateKeyPath = privateKeyPath
    }
    
    deinit {
        try! group?.syncShutdownGracefully()
    }
    
    /// Starts GNServer listening to host and port
    /// - Parameters:
    ///   - host: host of GN's server
    ///   - port: port of GN's server
    /// - Throws: any SwiftNIO exception
    @objc public func start(host: String, port: Int) throws {
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: GNServer.numberOfThreads)

        let server = Server.insecure(group: self.group)
            .withServiceProviders([GameNetworkProvider()])
            .bind(host: "localhost", port: 0)

        server.map {
            $0.channel.localAddress
        }.whenSuccess { address in
            print("server started on port \(address!.port!)")
        }
    }
}
