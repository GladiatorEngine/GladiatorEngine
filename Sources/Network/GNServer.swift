//
//  GNServer.swift
//  
//
//  Created by Pavel Kasila on 11/28/20.
//

import Foundation
import NIO
import NIOSSL

@objc public class GNServer: NSObject {
    private static let numberOfThreads = 4
    
    private var handler: ServerResponseHandler
    
    private var group: MultiThreadedEventLoopGroup!
    public private(set) var channel: Channel!
    
    private var sslContext: NIOSSLContext
    
    @objc public init(certificatePath: String, privateKeyPath: String) {
        self.handler = ServerResponseHandler()
        
        let certificateChain = try! NIOSSLCertificate.fromPEMFile(certificatePath)
        self.sslContext = try! NIOSSLContext(configuration: TLSConfiguration.forServer(certificateChain: certificateChain.map { .certificate($0) }, privateKey: .file(privateKeyPath)))
    }
    
    deinit {
        try! group.syncShutdownGracefully()
    }
    
    /// Starts GNServer listening to host and port
    /// - Parameters:
    ///   - host: host of GN's server
    ///   - port: port of GN's server
    /// - Throws: any SwiftNIO exception
    @objc public func start(host: String, port: Int) throws {
        // Initialize connection to server
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: GNServer.numberOfThreads)
        let bootstrap = ServerBootstrap(group: group)
            // Specify backlog and enable SO_REUSEADDR for the server itself
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)

            // Set the handlers that are applied to the accepted channels.
            .childChannelInitializer { channel in
                return channel.pipeline.addHandler(NIOSSLServerHandler(context: self.sslContext)).flatMap {
                    channel.pipeline.addHandler(self.handler)
                }
            }

            // Enable TCP_NODELAY and SO_REUSEADDR for the accepted Channels
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        self.channel = try bootstrap.bind(host: host, port: port).wait()
    }
}
