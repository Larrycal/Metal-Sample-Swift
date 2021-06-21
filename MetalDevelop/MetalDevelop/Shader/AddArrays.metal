//
//  AddArrays.metal
//  MetalDevelop
//
//  Created by 柳钰柯 on 2021/6/21.
//

#include <metal_stdlib>
using namespace metal;

kernel void add_array(device const float* arrA,
                      device const float* arrB,
                      device float* result,
                      uint index [[thread_position_in_grid]]) {
    result[index] = arrA[index] + arrB[index];
}

