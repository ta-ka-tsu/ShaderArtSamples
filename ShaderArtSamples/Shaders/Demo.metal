//
//  Demo.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/09/01.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;


fragment float4 Demo1(float4 pixPos [[position]],
                      constant float2& res[[buffer(0)]],
                      constant float& time[[buffer(1)]],
                      constant float& volume[[buffer(2)]],
                      constant float3& accel[[buffer(3)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;

    uv *= 10.0 * clamp(volume, 0.1, 1.0);
    
    float t = 0.2 * sin(5 * atan2(uv.y, uv.x)) + 0.8;
    return step(length(uv), t);
}

fragment float4 Demo2(float4 pixPos [[position]],
                      constant float2& res[[buffer(0)]],
                      constant float2& touch[[buffer(4)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;

    uv *= 2.0;

    float2 t = (2.0 * touch - res)/min(res.x, res.y);
    t.y *= -1.0;
    t *= 2.0;

    float2 uv2 = (uv - t) * (1.0 + 0.1 * (length(uv - t)*length(uv-t)));
    uv2 = 2*fract(uv2) - 1;
    
    float threshold = 0.2 * sin(5*atan2(uv2.y, uv2.x)) + 0.8;
    return step(length(uv2), threshold);//grid(uv2);
}
