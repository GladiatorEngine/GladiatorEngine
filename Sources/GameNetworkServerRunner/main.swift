//
//  main.swift
//  
//
//  Created by Pavel Kasila on 11/28/20.
//

import Foundation
import GameNetwork
import ArgumentParser

struct GameNetworkServerRunner: ParsableCommand {
    static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: "Runs GNServer listening on specified address and port with certificate and key (it doesn't rely on game specifics, so universal for all platforms)",

        // Commands can define a version for automatic '--version' support.
        version: "1.0.0")
    
    @Argument(help: "GNServer's host")
    var host: String
    
    @Argument(help: "GNServer's port")
    var port: Int
    
    @Option(name: .long, help: "Path to certificate in PEM format")
    var certificate: String
    
    @Option(name: .long, help: "Path to key in PEM format")
    var key: String
    
    mutating func run() throws {
        let server = GNServer(certificatePath: certificate, privateKeyPath: key)
        
        print("Starting GNServer listening on \(host):\(port)")
        try server.start(host: host, port: port)
        print("Listening...")
        try server.channel.closeFuture.wait()
    }
}

GameNetworkServerRunner.main()
