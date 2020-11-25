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
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    var mesh: MTKMesh!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    
    var timer: Float = 0
    
    private var assetManager: AssetManager
    
    init(mtkView metalView: MTKView, assetManager: AssetManager) {
        self.assetManager = assetManager
        
        guard let device = MTLCreateSystemDefaultDevice() else {
          fatalError("GPU not available")
        }
        metalView.device = device
        Renderer.device = device
        Renderer.commandQueue = device.makeCommandQueue()!
        
        let mdlMesh = Primitive.makeCube(device: Renderer.device, size: 1)
        do {
          mesh = try MTKMesh(mesh: mdlMesh, device: device)
        } catch let error {
          print(error.localizedDescription)
        }
        
        vertexBuffer = mesh.vertexBuffers[0].buffer
        
        let library = try? device.makeDefaultLibrary(bundle: Bundle.module)
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        super.init()
        
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0,
                                             blue: 0.8, alpha: 1.0)
        metalView.delegate = self
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    public func draw(in view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor,
        let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }

        // 1
        timer += 0.05
        var currentTime = sin(timer)
        // 2
        renderEncoder.setVertexBytes(&currentTime,
                                      length: MemoryLayout<Float>.stride,
                                      index: 1)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: submesh.indexCount,
                                      indexType: submesh.indexType,
                                      indexBuffer: submesh.indexBuffer.buffer,
                                      indexBufferOffset: 0)
        }

        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else { return }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
