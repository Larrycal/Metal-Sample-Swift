//
//  MetalAdder.swift
//  MetalDevelop
//
//  Created by 柳钰柯 on 2021/6/21.
//

import Foundation
import Metal

class MetalAdder {
    let device: MTLDevice
    let library: MTLLibrary
    let addFunction: MTLFunction
    let addFunctionPSO: MTLComputePipelineState
    let commandQueue: MTLCommandQueue
    let bufferSize = 1024
    let bufferA: MTLBuffer
    let bufferB: MTLBuffer
    let bufferResult: MTLBuffer
    init?(_ device: MTLDevice) {
        self.device = device
        guard let library = device.makeDefaultLibrary(), let addFunction = library.makeFunction(name: "add_array") else { return nil }
        self.library = library
        self.addFunction = addFunction
        guard let addFunctionPSO = try? device.makeComputePipelineState(function: addFunction),
              let bufferA = device.makeBuffer(length: bufferSize*MemoryLayout<Float>.stride, options: .storageModeShared),
              let bufferB = device.makeBuffer(length: bufferSize*MemoryLayout<Float>.stride, options: .storageModeShared),
              let bufferResult = device.makeBuffer(length: bufferSize*MemoryLayout<Float>.stride, options: .storageModeShared) else { return nil }
        self.bufferA = bufferA
        self.bufferB = bufferB
        self.bufferResult = bufferResult
        self.addFunctionPSO = addFunctionPSO
        guard let commandQueue = device.makeCommandQueue() else { return nil }
        self.commandQueue = commandQueue
        
        let pbA = bufferA.contents().bindMemory(to: Float.self, capacity: bufferSize*MemoryLayout<Float>.stride)
        let pbB = bufferB.contents().bindMemory(to: Float.self, capacity: bufferSize*MemoryLayout<Float>.stride)
        for i in 0 ..< bufferSize {
            pbA.advanced(by: i).pointee = Float(i)
            pbB.advanced(by: i).pointee = Float(i)
        }
        let commandBuffer = commandQueue.makeCommandBuffer()
        let encode = commandBuffer?.makeComputeCommandEncoder()
        encode?.setComputePipelineState(addFunctionPSO)
        encode?.setBuffer(bufferA, offset: 0, index: 0)
        encode?.setBuffer(bufferB, offset: 0, index: 1)
        encode?.setBuffer(bufferResult, offset: 0, index: 2)
        let gridSize = MTLSizeMake(bufferSize, 1, 1)
        let threadGroupSize = MTLSizeMake(addFunctionPSO.maxTotalThreadsPerThreadgroup > bufferSize ? bufferSize:addFunctionPSO.maxTotalThreadsPerThreadgroup, 1, 1)
        encode?.dispatchThreads(gridSize, threadsPerThreadgroup: threadGroupSize)
        encode?.endEncoding()
        commandBuffer?.addCompletedHandler({ buffer in
            self.verifyResult()
        })
        commandBuffer?.commit()
    }
    
    func verifyResult() {
        let pbA = bufferA.contents().bindMemory(to: Float.self, capacity: bufferSize*MemoryLayout<Float>.stride)
        let pbB = bufferB.contents().bindMemory(to: Float.self, capacity: bufferSize*MemoryLayout<Float>.stride)
        let pbR = bufferResult.contents().bindMemory(to: Float.self, capacity: bufferSize*MemoryLayout<Float>.stride)
        for i in 0 ..< bufferSize {
            let fa = pbA.advanced(by: i).pointee
            let fb = pbB.advanced(by: i).pointee
            let fr = pbR.advanced(by: i).pointee
            print("\(fa)+\(fb)=\(fr)")
            if fr != fa + fb  {
                print("Compute Error: index=\(i), result=\(fr) vs \(fa + fb)")
                assert(fr == fa + fb)
            }
        }
        print("Compute results as expected!")
    }
    
}
