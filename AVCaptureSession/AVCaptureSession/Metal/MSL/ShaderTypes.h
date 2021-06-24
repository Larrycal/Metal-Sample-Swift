//
//  ShaderTypes.h
//  AVCaptureSession
//
//  Created by 柳钰柯 on 2021/6/24.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef struct {
    vector_float3 position;
    vector_float2 textureCoordinate;
} Vertex;

#endif /* ShaderTypes_h */
