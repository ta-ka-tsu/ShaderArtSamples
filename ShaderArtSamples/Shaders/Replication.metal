//
//  Replication.metal
//  ShaderArtSamples
//
//  Created by Youichi Takatsu on 2019/09/03.
//  Copyright © 2019 TakatsuYouichi. All rights reserved.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

// 複製した回転する星
fragment float4 Replication1(float4 pixPos [[position]],
                             constant float2& res[[buffer(0)]],
                             constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 2.0;
    uv = fract(uv) * 2.0 - 1.0;
    
    float theta = atan2(uv.y, uv.x) - time;
    float threshold = 0.2*sin(5 * theta) + 0.8;
    return step(length(uv), threshold);
}

// もっと複製した回転する星
fragment float4 Replication2(float4 pixPos [[position]],
                             constant float2& res[[buffer(0)]],
                             constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 5.0;
    uv = fract(uv) * 2.0 - 1.0;
    
    float theta = atan2(uv.y, uv.x) - time;
    float threshold = 0.2*sin(5 * theta) + 0.8;
    return step(length(uv), threshold);
}

// 複製数が増減する星
fragment float4 Replication3(float4 pixPos [[position]],
                             constant float2& res[[buffer(0)]],
                             constant float& time[[buffer(1)]])
{
    float2 uv = (2.0 * pixPos.xy - res)/min(res.x, res.y);
    uv.y *= -1.0;
    
    uv *= 5.0 + 2.0 * sin(time);
    uv = fract(uv) * 2.0 - 1.0;
    
    float theta = atan2(uv.y, uv.x) - time;
    float threshold = 0.2*sin(5 * theta) + 0.8;
    return step(length(uv), threshold);
}
