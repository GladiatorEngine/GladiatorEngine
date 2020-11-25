//
//  Renderer.swift
//  
//
//  Created by Pavel Kasila on 11/25/20.
//

import Foundation
import AssetManager
import ShaderHeaders
import Metal
import MetalKit
import simd

// The 256 byte aligned size of our uniform structure
let alignedUniformsSize = (MemoryLayout<Uniforms>.size + 0xFF) & -0x100

let maxBuffersInFlight = 3

enum RendererError: Error {
    case badVertexDescriptor
}

public class Renderer: NSObject, MTKViewDelegate {
    
    var timer: Float = 0

    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    var mesh: MTKMesh!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!

    init(mtkView metalView: MTKView, assetManager: AssetManager) {
        guard let device = MTLCreateSystemDefaultDevice() else {
          fatalError("GPU not available")
        }
        metalView.device = device
        Renderer.device = device
        Renderer.commandQueue = device.makeCommandQueue()!
        
        let mdlMesh = Primitive.makeCube(device: device, size: 1)
        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
        } catch let error {
            print(error.localizedDescription)
        }
        
        vertexBuffer = mesh.vertexBuffers[0].buffer
        
        do {
            let library = try device.makeDefaultLibrary(bundle: Bundle.module)
            let vertexFunction = library.makeFunction(name: "vertex_main")
            let fragmentFunction = library.makeFunction(name: "fragment_main")
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)
            pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
            
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
        let mdlMesh = Primitive.makeCube(device: Renderer.device, size: 1)
        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: Renderer.device)
        } catch let error {
            print(error.localizedDescription)
        }
        
        vertexBuffer = mesh.vertexBuffers[0].buffer
    }
      
    public func draw(in view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor,
        let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
        let renderEncoder =
        commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }

        renderEncoder.setRenderPipelineState(pipelineState)
        
        timer += 0.05
        var currentTime = sin(timer)
        renderEncoder.setVertexBytes(&currentTime,
                                      length: MemoryLayout<Float>.stride,
                                      index: 1)
        
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
