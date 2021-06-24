//
//  Renderer.swift
//  MetalDevelop
//
//  Created by 柳钰柯 on 2021/6/21.
//

import Foundation
import MetalKit
import simd
import Utility

class Renderer: NSObject {
    let device: MTLDevice?
    let pipelineState: MTLRenderPipelineState?
    let depthState: MTLDepthStencilState?
    let commandQueue: MTLCommandQueue?
    var texture: MTLTexture?
    var projectionMarix: matrix_float4x4 = matrix_float4x4()
    var uniformBuffer: MTLBuffer?
    var indicesBuffer: MTLBuffer?
    var verticesBuffer: MTLBuffer?
    private(set) var time: TimeInterval = 0
    private(set) var rotationX: Float = 0
    private(set) var rotationY: Float = 0
    private(set) var displayLink: CADisplayLink?
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
        pipelineDescriptor.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
        pipelineState = try? device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .lessEqual
        depthDescriptor.isDepthWriteEnabled = true
        depthState = device?.makeDepthStencilState(descriptor: depthDescriptor)
        
        super.init()
        uniformBuffer = device?.makeBuffer(length: MemoryLayout<Uniforms>.stride, options: .storageModeShared)
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire(_:)))
        displayLink?.add(to: RunLoop.main, forMode: .common)
//        loadTexture()
        loadVertices()
        loadIndices()
    }
    
}

private extension Renderer {
    func loadTexture() {
        guard let imageFileLocation = Bundle.main.url(forResource: "Image", withExtension: "tga"),let metalImage = MetalImage(imageFileLocation) else { return }
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .bgra8Unorm
        textureDescriptor.width = metalImage.width
        textureDescriptor.height = metalImage.height
        texture = device?.makeTexture(descriptor: textureDescriptor)
        let bytesPerRow = 4 * metalImage.width
        let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0), size: MTLSize(width: metalImage.width, height: metalImage.height, depth: 1))
        texture?.replace(region: region, mipmapLevel: 0, withBytes: metalImage.data.withUnsafeBytes({$0.baseAddress!}), bytesPerRow: bytesPerRow)
    }
    
    func loadVertices() {
        let triangleVertices = [
            Vertex(position: vector_float3(-1, 1, 1), color: vector_float4(0, 1, 1, 1)),
            Vertex(position: vector_float3(-1, -1,1), color: vector_float4(0, 0, 1, 1)),
            Vertex(position: vector_float3(1, -1, 1), color: vector_float4(1, 0, 1, 1)),
            Vertex(position: vector_float3(1, 1, 1), color: vector_float4(1, 1, 1, 1)),
            Vertex(position: vector_float3(-1, 1, -1), color: vector_float4(0, 1, 0, 1)),
            Vertex(position: vector_float3(-1, -1,-1), color: vector_float4(0, 0, 0, 1)),
            Vertex(position: vector_float3(1, -1, -1), color: vector_float4(1, 0, 0, 1)),
            Vertex(position: vector_float3(1, 1, -1), color: vector_float4(1, 1, 0, 1))
        ]
        verticesBuffer = device?.makeBuffer(bytes: triangleVertices, length: triangleVertices.count * MemoryLayout<Vertex>.stride, options: .storageModeShared)
    }
    
    func loadIndices() {
        let indices: [UInt16] = [
            3,2,6,6,7,3,
            4,5,1,1,0,4,
            4,0,3,3,7,4,
            1,5,6,6,2,1,
            0,1,2,2,3,0,
            7,6,5,5,4,7
        ]
        indicesBuffer = device?.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.stride, options: .storageModeShared)
    }
    
    func updateCameraState(by duration: TimeInterval) {
        time += duration
        rotationX += Float(duration) * (Float.pi / 2)
        rotationY += Float(duration) * (Float.pi / 3)
        let xAxis = vector_float3(1, 0, 0)
        let yAxis = vector_float3(0, 1, 0)
        let xRot = MetalMath.matrix4x4Rotation(radians: rotationX, axis: xAxis)
        let yRot = MetalMath.matrix4x4Rotation(radians: rotationY, axis: yAxis)
        let modelMatrix = matrix_multiply(xRot, yRot)
        let cameraTranslation = vector_float3(0, 0, -10)
        let viewMatrix = MetalMath.matrix4x4Translation(t: cameraTranslation)
        
        let uniforms = uniformBuffer?.contents().assumingMemoryBound(to: Uniforms.self)
        uniforms?.pointee.projectionMatrix = projectionMarix
        uniforms?.pointee.modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix)
        
    }
    
    @objc func displayLinkDidFire(_ sender: CADisplayLink) {
        
    }
}

// MARK: - MTKViewDelegate
extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let aspect = Float(size.width / size.height)
        let fov = 2 * Float.pi / 5
        let nearPlane:Float = 1
        let farPlane:Float = 100
        projectionMarix = MetalMath.matrixPerspectiveRightHand(fovyRadians: fov, aspect: aspect, nearZ: nearPlane, farZ: farPlane)
    }
    
    func draw(in view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor, let drawable = view.currentDrawable else { return }
        guard let indicesBuffer = indicesBuffer else { return }
        
        updateCameraState(by: displayLink!.duration)
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        encoder?.setRenderPipelineState(pipelineState!)
        encoder?.setDepthStencilState(depthState)
        encoder?.setVertexBuffer(verticesBuffer, offset: 0, index: 0)
        encoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        encoder?.drawIndexedPrimitives(type: .triangle, indexCount: indicesBuffer.length / MemoryLayout<UInt16>.stride, indexType: .uint16, indexBuffer: indicesBuffer, indexBufferOffset: 0)
        encoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
