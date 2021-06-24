//
//  MetalMath.swift
//  Utility
//
//  Created by 柳钰柯 on 2021/6/23.
//

import Foundation
import Metal
import simd

public struct MetalMath {
    public static func matrixPerspectiveLeftHand(fovyRadians: Float, aspect: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
        let ys = 1 / tanf(fovyRadians * 0.5)
        let xs = ys / aspect
        let zs = farZ / (farZ - nearZ)
        return matrix_float4x4(SIMD4<Float>(xs, 0, 0, 0),
                               SIMD4<Float>(0, ys, 0, 0),
                               SIMD4<Float>(0, 0, zs, -nearZ * zs),
                               SIMD4<Float>(0, 0, 1, 0))
    }
    
    public static func matrixPerspectiveRightHand(fovyRadians: Float, aspect: Float, nearZ: Float, farZ: Float) -> matrix_float4x4 {
        let ys = 1 / tanf(fovyRadians * 0.5)
        let xs = ys / aspect
        let zs = farZ / (nearZ - farZ)
        return matrix_float4x4(SIMD4<Float>(xs, 0, 0, 0),
                               SIMD4<Float>(0, ys, 0, 0),
                               SIMD4<Float>(0, 0, zs, nearZ * zs),
                               SIMD4<Float>(0, 0, -1, 0))
    }
    
    public static func matrix4x4Translation(tx: Float, ty: Float, tz: Float) -> matrix_float4x4 {
        return matrix_float4x4(SIMD4<Float>(1, 0, 0, 0),
                               SIMD4<Float>(0, 1, 0, 0),
                               SIMD4<Float>(0, 0, 1, 0),
                               SIMD4<Float>(tx, ty, tz, 1))
    }
    
    public static func matrix4x4Translation(t: vector_float3) -> matrix_float4x4 {
        return matrix_float4x4(SIMD4<Float>(1, 0, 0, 0),
                               SIMD4<Float>(0, 1, 0, 0),
                               SIMD4<Float>(0, 0, 1, 0),
                               SIMD4<Float>(t.x, t.y, t.z, 1))
    }
    
    public static func matrix4x4Rotation(radians: Float, axis: vector_float3) -> matrix_float4x4 {
        let axis = normalize(axis)
        let ct = cosf(radians);
        let st = sinf(radians);
        let ci = 1 - ct;
        let x = axis.x
        let y = axis.y
        let z = axis.z
        return matrix_float4x4(SIMD4<Float>(ct + x * x * ci, x * y * ci - z * st, x * z * ci + y * st, 0),
                               SIMD4<Float>(y * x * ci + z * st,     ct + y * y * ci, y * z * ci - x * st, 0),
                               SIMD4<Float>(z * x * ci - y * st, z * y * ci + x * st,     ct + z * z * ci, 0),
                               SIMD4<Float>(0, 0, 0, 1))
    }
    
    public static func matrix4x4Rotation(radians: Float, x: Float, y: Float, z: Float) -> matrix_float4x4 {
        return matrix4x4Rotation(radians: radians, axis: vector_float3(x, y, z))
    }
    
    public static func matrix4x4Scale(sx: Float, sy: Float, sz: Float) -> matrix_float4x4 {
        return matrix_float4x4(SIMD4<Float>(sx, 0, 0, 0),
                               SIMD4<Float>(0, sy, 0, 0),
                               SIMD4<Float>(0, 0, sz, 0),
                               SIMD4<Float>(0, 0, 0, 1))
    }
    
    public static func matrix4x4Scale(s: vector_float3) -> matrix_float4x4 {
        return matrix_float4x4(SIMD4<Float>(s.x, 0, 0, 0),
                               SIMD4<Float>(0, s.y, 0, 0),
                               SIMD4<Float>(0, 0, s.z, 0),
                               SIMD4<Float>(0, 0, 0, 1))
    }
}
