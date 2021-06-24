//
//  VertexShader.metal
//  MetalDevelop
//
//  Created by 柳钰柯 on 2021/6/21.
//

#include <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

struct RasterizerData {
    float4 position [[position]];
    float4 color;
};

vertex RasterizerData vertexShader(uint vertexID [[ vertex_id ]],
                                   constant Vertex *vertices [[ buffer(0) ]],
                                   constant Uniforms &uniform [[ buffer(1) ]]) {
    RasterizerData out;
    float4 position = vector_float4(vertices[vertexID].position,1);
    out.position = uniform.projectionMatrix * uniform.modelViewMatrix * position;
    out.color = vertices[vertexID].color;
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    // Return the interpolated color.
    return in.color;
}

//fragment float4 samplingShader(RasterizerData in [[stage_in]],
//                               texture2d<half> colorTexture [[texture(0)]])
//{
//    constexpr sampler textureSampler (mag_filter::linear,
//                                      min_filter::linear);
//    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);
//
//    return float4(colorSample);
//}

