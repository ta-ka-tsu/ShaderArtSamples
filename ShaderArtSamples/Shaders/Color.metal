//
//  Color.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/26.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

// 色付きブロックノイズ(RGBランダム)
fragment float4 Color1(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]],
                       constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float2 id = floor(4*uv);
    
    float r = N21(id);
    float g = N21(id + float2(123.34, 32.34));
    float b = N21(id + float2(23.0, 342.0));
    return float4(r, g, b, 1.0);
}

// 色付きブロックノイズ(ビビッド)
fragment float4 Color2(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float2 id = floor(4*uv);
    
    float h = N21(id);
    float3 rgb = hsv2rgb(h, 1.0, 1.0);
    return float4(rgb, 1.0);
}

// 色付きブロックノイズ(おとなしめ)
fragment float4 Color3(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float2 id = floor(4*uv);
    
    float h = N21(id);
    float3 rgb = hsv2rgb(h, 0.7, 1.0);
    return float4(rgb, 1.0);
}

// 色付きブロックノイズ色相変化
fragment float4 Color4(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]],
                       constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float2 id = floor(4*uv);
    
    float h = N21(id);
    float3 rgb = hsv2rgb(fract(h + 0.2*time), 0.7, 1.0);
    return float4(rgb, 1.0);
}

// 色付き円アニメーション
fragment float4 Color5(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]],
                       constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float2 id = floor(4*uv);
    
    float h = N21(id);
    float3 rgb = hsv2rgb(fract(h + 0.2*time), 0.7, 1.0);
    
    uv = fract(4*uv)*2.0 - 1.0;
    return float4(rgb, 1.0) * step(length(uv), 0.5 + 0.5*sin(3*time + 5*h));
}

// 色相環
fragment float4 Color6(float4 pixPos [[position]],
                       constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;

    float l = length(uv);
    float ring = abs(step(0.8, l) - step(1.0, l));
    float phase = atan2(uv.y, uv.x) + M_PI_F;// 0 to 2*PI
    float h = phase/(2.0 * M_PI_F);
    float s = saturate(l);
    float3 rgb = hsv2rgb(h, s, 1.0);
    
    return float4(rgb, 1.0)*ring;
}
