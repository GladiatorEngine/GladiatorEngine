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
    
    public private(set) var channel: Channel!
    
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
        
        let certificates: [NIOSSLCertificate] = try NIOSSLCertificate.fromPEMFile(self.certificatePath)

        #if DEBUG
        let s = Server.insecure(group: self.group)
        #else
        let s = Server.secure(group: self.group,
                              certificateChain: certificates,
                              privateKey: try NIOSSLPrivateKey(file: self.privateKeyPath, format: .pem))
        #endif
        let server = try s.withServiceProviders([GameNetworkProvider()])
            .bind(host: host, port: port)
            .wait()
        self.channel = server.channel
        print("server started on port \(server.channel.localAddress!.port!)")
    }
}
