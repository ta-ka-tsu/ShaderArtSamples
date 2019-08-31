//
//  Noise.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/26.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

fragment float4 Noise1(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    return N11(uv.x);
}

fragment float4 Noise2(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    return N21(uv);
}

fragment float4 Noise3(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 4;
    float2 id = floor(uv);
    
    return N21(id);
}

fragment float4 Noise4(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]],
                       constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 4.0;
    float2 id = floor(uv);
    uv = fract(uv)*2.0 - 1.0;
    
    float r = N21(id);
    
    return step(length(uv), r);
}

fragment float4 Noise5(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]],
                       constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 4.0;
    float2 id = floor(uv);
    uv = fract(uv)*2.0 - 1.0;
    
    float r = N21(id);
    
    return step(length(uv), 0.5 + 0.5*sin(3*time + 5*r));
}
