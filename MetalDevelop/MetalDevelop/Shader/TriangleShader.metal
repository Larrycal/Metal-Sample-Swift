//
//  VertexShader.metal
//  MetalDevelop
//
//  Created by 柳钰柯 on 2021/6/21.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex_Swift {
    float2 position;
    float4 color;
};

struct RasterizerData {
    float4 position [[position]];
    float4 color;
};

vertex RasterizerData vertexShader(uint vertexID [[vertex_id]],
                                    constant Vertex_Swift *vertices [[buffer(0)]],
                                    constant vector_uint2 *viewportSizePointer [[buffer(1)]]) {
    RasterizerData out;
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    out.position = vector_float4(0,0,0,1);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
    out.color = vertices[vertexID].color;
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    // Return the interpolated color.
    return in.color;
}



