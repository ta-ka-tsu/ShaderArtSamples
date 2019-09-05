//
//  Animation.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/08/31.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

// 回転する星
fragment float4 Animation1(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x) - time;
    float threshold = 0.2*sin(5 * theta) + 0.8;
    return step(length(uv), threshold);
}

// 円<->星
fragment float4 Animation2(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float theta = atan2(uv.y, uv.x);
    float amp = 0.2 * sin(time);
    float threshold = amp*sin(5 * theta) + 0.8;
    return step(length(uv), threshold);
}

// ゆっくり停止
fragment float4 Animation3(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    float y = sin(10.0 * time) * exp(-time);
    
    uv -= float2(0.0, y);
    
    float theta = atan2(uv.y, uv.x);
    float threshold = 0.2*sin(5 * theta) + 0.8;
    return step(length(uv), threshold);
}

// 縦横交互の移動
fragment float4 Animation4(float4 pixPos [[position]],
                           constant float2& res[[buffer(0)]],
                           constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;

    float loop = 2.0 * (fract(time) - 0.5); // -1 〜 1
    float x = 4.0 * loop * loop * loop * step(0.0, sinpi(time));
    float y = 2.0 * loop * loop * loop * step(0.0, sinpi(time + 1));
    
    uv -= float2(x, y);
    float theta = atan2(uv.y, uv.x);
    float threshold = 0.2*sin(5 * theta) + 0.8;
    return step(length(uv), threshold);
}
