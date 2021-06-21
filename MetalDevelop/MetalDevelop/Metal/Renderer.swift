//
//  Renderer.swift
//  MetalDevelop
//
//  Created by 柳钰柯 on 2021/6/21.
//

import Foundation
import MetalKit
import simd

class Renderer: NSObject {
    let device: MTLDevice?
    let pipelineState: MTLRenderPipelineState?
    let commandQueue: MTLCommandQueue?
    var viewportSize: vector_uint2 = vector_uint2(0, 0)
    init(with mtkView: MTKView) {
        device = mtkView.device
        commandQueue = device?.makeCommandQueue()
        let defaultLib = device?.makeDefaultLibrary()
        let vertexFunction = defaultLib?.makeFunction(name: "vertexShader")
        let fragmentFunction = defaultLib?.makeFunction(name: "fragmentShader")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        pipelineState = try? device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize.x = UInt32(size.width)
        viewportSize.y = UInt32(size.height)
    }
    
    func draw(in view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable else { return }
        var triangleVertices = [
            Vertex(position: vector_float2(250, -250), color: vector_float4(1, 0, 0, 1)),
            Vertex(position: vector_float2(-250, -250), color: vector_float4(0, 1, 0, 1)),
            Vertex(position: vector_float2(0, 250), color: vector_float4(0, 0, 1, 1))
        ]
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        encoder?.setViewport(MTLViewport(originX: 0, originY: 0, width: Double(viewportSize.x), height: Double(viewportSize.y), znear: 0, zfar: 1))
        encoder?.setRenderPipelineState(pipelineState!)
        encoder?.setVertexBytes(UnsafeRawPointer(&triangleVertices), length: MemoryLayout<[Vertex]>.stride, index: 0)
        encoder?.setVertexBytes(UnsafeRawPointer(&viewportSize), length: MemoryLayout<vector_uint2>.stride, index: 1)
        encoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
