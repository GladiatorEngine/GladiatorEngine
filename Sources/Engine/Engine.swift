import Foundation
import AssetManager

public struct Engine {
    public private(set) var assetManager: AssetManager
    public private(set) var renderer: Renderer
    
    public init() {
        self.assetManager = AssetManager()
        self.renderer = Renderer(assetManager: self.assetManager)
    }
}
