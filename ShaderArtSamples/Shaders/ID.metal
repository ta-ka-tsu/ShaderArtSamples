//
//  ID.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/09/03.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

// 複製した円
fragment float4 Id1(float4 pixPos [[position]],
                    constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 2.0;
    uv = fract(uv) * 2.0 - 1.0;
    
    return step(length(uv), 1.0);
}

// グリッド毎にサイズを変えた円
fragment float4 Id2(float4 pixPos [[position]],
                    constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 2.0;
    float2 id = floor(uv);
    uv = fract(uv) * 2.0 - 1.0;
    
    float threshold = exp(-length(id));
    return step(length(uv), threshold);
}

// グリッド毎にサイズを変えた円(中心版)
fragment float4 Id3(float4 pixPos [[position]],
                    constant float2& res[[buffer(0)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv = 2.0 * uv + 0.5;
    float2 id = floor(uv);
    uv = fract(uv) * 2.0 - 1.0;
    
    float threshold = exp(-length(id));
    return step(length(uv), threshold);
}

// グリッド毎にサイズを変えた円(中心版)+アニメーション
fragment float4 Id4(float4 pixPos [[position]],
                    constant float2& res[[buffer(0)]],
                    constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv = rot(time) * uv;
    
    uv = 2.0 * uv + 0.5;
    float2 id = floor(uv);
    uv = fract(uv) * 2.0 - 1.0;
    
    float threshold = exp(-(0.5*sin(2.0*time)+0.5)*length(id));
    return step(length(uv), threshold);
}
