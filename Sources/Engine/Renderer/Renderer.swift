//
//  Renderer.swift
//  
//
//  Created by Pavel Kasila on 11/25/20.
//

import Foundation
import AssetManager
import MetalKit

public class Renderer: NSObject, MTKViewDelegate {
    private var assetManager: AssetManager
    
    init(assetManager: AssetManager) {
        self.assetManager = assetManager
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    public func draw(in view: MTKView) {
        
    }
}
