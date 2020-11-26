import Foundation
import MetalKit

@_exported import Logger
@_exported import AssetManager

public struct Engine {
    public private(set) var assetManager: AssetManager
    public private(set) var renderer: Renderer
    public private(set) var logger: Logger
    
    public init(mtkView: MTKView) {
        self.logger = Logger(path: NSTemporaryDirectory().appending("main.log"))
        self.assetManager = AssetManager(logger: logger)
        self.renderer = Renderer(mtkView: mtkView, assetManager: self.assetManager)
    }
}
