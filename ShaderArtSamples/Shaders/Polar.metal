//
//  Polar.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/31.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;


// 花
fragment float4 Polar1(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float threshold = 0.5*sin(5 * theta) + 0.5;
    return step(length(uv), threshold);
}

// 星
fragment float4 Polar2(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float threshold = 0.2*sin(5 * theta) + 0.8;
    return step(length(uv), threshold);
}

// ギア
fragment float4 Polar3(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float threshold = 0.1*step(sin(20 * theta), 0.0) + 0.9;
    return step(length(uv), threshold);
}

// 風車
fragment float4 Polar4(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float threshold = 0.5 * fract(2 * theta/M_PI_F) + 0.5;
    return step(length(uv), threshold);
}

// 花２
fragment float4 Polar5(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float threshold = min(fract(2.5 * theta/M_PI_F), 1.0 - fract(2.5 * theta/M_PI_F)) + 0.5;
    return step(length(uv), threshold);
}

// 極座標をRGにマッピング
fragment float4 Polar6(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float r = length(uv);
    float t = 0.5 * atan2(uv.y, uv.x)/M_PI_F + 0.5;
    
    return float4(r, t, 0.0, 1.0);
}

// polar mod
fragment float4 Polar7(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float angle = M_PI_F/5;
    
    float pid = floor(theta/angle);
    
    uv = rot(-(pid + 0.5) * angle)*uv;
    
    uv *= 5;
    uv.x = fract(uv.x) - 0.5;
    
    return step(length(uv), 0.5);
}

