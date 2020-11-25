import Foundation
import AssetManager
import MetalKit

public struct Engine {
    public private(set) var assetManager: AssetManager
    public private(set) var renderer: Renderer
    
    public init(mtkView: MTKView) {
        self.assetManager = AssetManager()
        self.renderer = Renderer(mtkView: mtkView, assetManager: self.assetManager)
    }
}
