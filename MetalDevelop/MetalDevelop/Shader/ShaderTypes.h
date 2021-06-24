//
//  ShaderTypes.h
//  MetalDevelop
//
//  Created by 柳钰柯 on 2021/6/22.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef struct {
    vector_float3 position;
    vector_float4 color;
} Vertex;

typedef struct
{
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
} Uniforms;

typedef struct __attribute__ ((packed)) TGAHeader
{
    uint8_t  IDSize;         // Size of ID info following header
    uint8_t  colorMapType;   // Whether this is a paletted image
    uint8_t  imageType;      // type of image 0=none, 1=indexed, 2=rgb, 3=grey, +8=rle packed
    
    int16_t  colorMapStart;  // Offset to color map in palette
    int16_t  colorMapLength; // Number of colors in palette
    uint8_t  colorMapBpp;    // Number of bits per palette entry
    
    uint16_t xOrigin;        // X Origin pixel of lower left corner if tile of larger image
    uint16_t yOrigin;        // Y Origin pixel of lower left corner if tile of larger image
    uint16_t width;          // Width in pixels
    uint16_t height;         // Height in pixels
    uint8_t  bitsPerPixel;   // Bits per pixel 8,16,24,32
    union {
        struct
        {
            uint8_t bitsPerAlpha : 4;
            uint8_t topOrigin    : 1;
            uint8_t rightOrigin  : 1;
            uint8_t reserved     : 2;
        };
        uint8_t descriptor;
    };
} TGAHeader;

#endif /* ShaderTypes_h */
