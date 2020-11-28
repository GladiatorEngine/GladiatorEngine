import Foundation
import MetalKit

@_exported import Logger
@_exported import AssetManager
@_exported import GameNetwork

/// Main GladiatorEngine class, it controls eveything
@objc public class Engine: NSObject {
    @objc public private(set) var assetManager: AssetManager
    @objc public private(set) var renderer: Renderer
    @objc public private(set) var logger: Logger
    @objc public private(set) var gameNetworkClient: GNClient!
    
    /// Initialize Engine with MTKView
    /// - Parameter mtkView: MTKView where renderer will show rendered frames
    @objc public init(mtkView: MTKView) {
        self.logger = Logger(path: NSTemporaryDirectory().appending("main.log"))
        self.assetManager = AssetManager(logger: logger)
        self.renderer = Renderer(mtkView: mtkView, assetManager: self.assetManager)
    }
    
    /// Sets up network in game
    /// - Parameters:
    ///   - host: game network server's hostname
    ///   - port: game network server's port
    /// - Throws: any SwiftNIO exception
    @objc public func setupNetwork(host: String, port: Int) throws {
        self.gameNetworkClient = GNClient()
        try self.gameNetworkClient.connectTo(host: host, port: port)
    }
}
