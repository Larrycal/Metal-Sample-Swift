//
//  Shader.metal
//  AVCaptureSession
//
//  Created by 柳钰柯 on 2021/6/24.
//

#include <metal_stdlib>
#include "ShaderTypes.h"

using namespace metal;

struct RasterizerData
{
    // The [[position]] attribute qualifier of this member indicates this value is
    // the clip space position of the vertex when this structure is returned from
    // the vertex shader
    float4 position [[position]];

    // Since this member does not have a special attribute qualifier, the rasterizer
    // will interpolate its value with values of other vertices making up the triangle
    // and pass that interpolated value to the fragment shader for each fragment in
    // that triangle.
    float2 textureCoordinate;

};

vertex RasterizerData vertexShader(uint vertexID [[ vertex_id ]],
                                   constant Vertex *vertices [[ buffer(0) ]]) {
    RasterizerData out;
    out.position = float4(vertices[vertexID].position,1);
    out.textureCoordinate = vertices[vertexID].textureCoordinate;
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[ stage_in ]],
                               texture2d<half> colorTexture [[ texture(0) ]]) {
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);
    return float4(colorSample);
}
