//
//  MetalRenderer.swift
//  AVCaptureSession
//
//  Created by 柳钰柯 on 2021/6/24.
//

import Foundation
import simd
import MetalKit

class MetalRenderer: NSObject {
    let device: MTLDevice?
    let commandQueue: MTLCommandQueue?
    let pipelineState: MTLRenderPipelineState?
    var texture: MTLTexture?
    var contentMode: UIView.ContentMode = .scaleAspectFill
    init?(view: MetalCaptureVideoView) {
        self.device = view.device
        lastDrawableSize = view.metalLayer.drawableSize
        lastTextureSize = CGSize(width: CGFloat(texture?.width ?? 0), height: CGFloat(texture?.height ?? 0))
        commandQueue = device?.makeCommandQueue()
        let defaultLib = device?.makeDefaultLibrary()
        let vertexFunc = defaultLib?.makeFunction(name: "vertexShader")
        let fragmentFunc = defaultLib?.makeFunction(name: "fragmentShader")
        let psoDescriptor = MTLRenderPipelineDescriptor()
        psoDescriptor.vertexFunction = vertexFunc
        psoDescriptor.fragmentFunction = fragmentFunc
        psoDescriptor.colorAttachments[0].pixelFormat = view.pixelFormat
        pipelineState = try? device?.makeRenderPipelineState(descriptor: psoDescriptor)
        super.init()
        loadVertexIndices()
        loadVertices()
    }
    private var verticesBuffer: MTLBuffer?
    private var indicesBuffer: MTLBuffer?
    private var lastDrawableSize:CGSize
    private var lastTextureSize:CGSize
}

private extension MetalRenderer {
    func loadVertices() {
        var heightScale:Float = 1
        var widthScale:Float = 1
        switch contentMode {
        case .scaleAspectFill:
            widthScale = Float(lastTextureSize.width / lastDrawableSize.width)
        case .scaleAspectFit:
            break
        default:
            break
        }
        let vertices:[Vertex] = [
            Vertex(position: vector_float3(-widthScale, heightScale, 1), textureCoordinate: vector_float2(0, 0)),
            Vertex(position: vector_float3(-widthScale, -heightScale, 1), textureCoordinate: vector_float2(0, 1)),
            Vertex(position: vector_float3(widthScale, -heightScale, 1), textureCoordinate: vector_float2(1, 1)),
            Vertex(position: vector_float3(widthScale, heightScale, 1), textureCoordinate: vector_float2(1, 0))
        ]
        verticesBuffer = device?.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: .storageModeShared)
    }
    func loadVertexIndices() {
        let indices:[UInt16] = [
            0,1,2,
            0,2,3
        ]
        indicesBuffer = device?.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.stride, options: .storageModeShared)
    }
}

extension MetalRenderer: MetalCaptureVideoViewDelegate {
    func draw(in view: MetalCaptureVideoView) {
        loadVertices()
        guard let pipelineState = pipelineState else { return }
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        guard let indicesBuffer = indicesBuffer else { return }
        guard let texture = texture else { return }
        guard view.currentDrawable != nil else {
            return
        }
        lastTextureSize = CGSize(width: CGFloat(texture.width), height: CGFloat(texture.height))
        lastDrawableSize = view.metalLayer.drawableSize
        print("TextureSize:",CGSize(width: CGFloat(texture.width), height: CGFloat(texture.height)), "drawableSize:\(view.metalLayer.drawableSize)")
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        encoder?.setRenderPipelineState(pipelineState)
        encoder?.setVertexBuffer(verticesBuffer, offset: 0, index: 0)
        encoder?.setFragmentTexture(texture, index: 0)
        encoder?.drawIndexedPrimitives(type: .triangle, indexCount: indicesBuffer.length / MemoryLayout<UInt16>.stride, indexType: .uint16, indexBuffer: indicesBuffer, indexBufferOffset: 0)
        encoder?.endEncoding()
        commandBuffer?.present(view.currentDrawable!)
        commandBuffer?.commit()
    }
}
